function iwt --description "Fuzzy pick git worktrees, then delete them"
    argparse h/help f/force -- $argv
    or return

    if set -q _flag_help
        echo "Usage: iwt [-f|--force]"
        echo "  Pick worktrees of the current repo with fzf, then delete them via git wt."
        echo "  Safe by default: a dirty worktree is refused, an unmerged branch is kept."
        echo "  -f, --force  delete regardless of local changes, and drop the branch too"
        return 0
    end

    if not command git rev-parse --git-dir >/dev/null 2>&1
        echo "iwt: not a git repository" >&2
        return 1
    end

    # git lists the main worktree first, and neither it nor the one holding $PWD
    # can be removed, so both are dropped before anything reaches the picker.
    # Fields are joined with US (0x1f) because a path may legally contain a tab.
    set -l records (command git wt --json | jq -j '
        .[0].path as $main
        | .[]
        | select(.bare != true and .current != true and .path != $main)
        | .path + "\u001f" + (.branch // "") + "\u0000"' | string split0)

    set -l here (pwd -P)/
    set -l paths
    set -l labels
    set -l branches
    set -l width 0
    set -l stale 0
    for record in $records
        set -l fields (string split \x1f -- $record)
        # A worktree whose directory is gone is listed until it is pruned, but
        # git wt cannot resolve it; one that contains $PWD would take the shell
        # down with it, and git-wt only marks the innermost worktree as current.
        if not test -d $fields[1]
            set stale 1
            continue
        end
        if string match -q -- "$fields[1]/*" $here
            continue
        end
        set -a paths $fields[1]
        set -a labels (string replace -- $HOME '~' $fields[1])
        set -a branches $fields[2]
        set -l len (string length --visible -- $labels[-1])
        test $len -gt $width; and set width $len
    end

    test $stale -eq 1; and echo "iwt: ignoring worktrees whose directory is gone, run git worktree prune" >&2

    if test (count $paths) -eq 0
        echo "iwt: no other worktrees in this repository" >&2
        return 1
    end

    set -l rows
    for i in (seq (count $paths))
        set -a rows $paths[$i]\x1f(string pad -r -w $width -- $labels[$i])"  "$branches[$i]
    end

    # split0 must stay inside the substitution: it is what makes fish split on
    # NUL rather than newlines.
    set -l targets (printf '%s\0' $rows |
        fzf --read0 --print0 --multi --reverse --height 60% \
            --delimiter \x1f --with-nth 2 --accept-nth 1 \
            --prompt "delete worktree> " \
            --header "tab: mark   enter: confirm" \
            --preview 'command git -C {1} status --short --branch 2>/dev/null | head -n 30; command git -C {1} log -1 --oneline 2>/dev/null' |
        string split0)
    test (count $targets) -eq 0; and return

    printf '  %s\n' (string replace -- $HOME '~' $targets)
    set -l prompt "Delete "(count $targets)" worktree(s), plus any merged branch? [y/N] "
    set -q _flag_force; and set prompt "Force delete "(count $targets)" worktree(s) AND their branches? [y/N] "

    read -l -P $prompt confirm
    string match -qri '^y(es)?$' -- $confirm; or return

    set -l delete -d
    set -q _flag_force; and set delete -D

    set -l failed 0
    for target in $targets
        command git wt $delete $target; or set failed 1
    end
    test $failed -eq 0
end
