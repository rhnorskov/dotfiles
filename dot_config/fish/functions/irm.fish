function irm --description "Fuzzy pick files/dirs, then move them to the trash"
    argparse h/help r/rm -- $argv
    or return

    if set -q _flag_help
        echo "Usage: irm [-r|--rm]"
        echo "  Pick files/dirs in the current directory with fzf, then trash them."
        echo "  -r, --rm  permanently rm -rf instead of moving to the Trash"
        return 0
    end

    set -l entries * .*
    if test (count $entries) -eq 0
        echo "irm: directory is empty" >&2
        return 1
    end

    # split0 must stay inside the substitution: it is what makes fish split on
    # NUL rather than newlines, so filenames containing newlines survive.
    set -l targets (printf '%s\0' $entries |
        fzf --read0 --print0 --multi --reverse --height 60% \
            --prompt "delete> " \
            --header "tab: mark   enter: confirm" \
            --preview 'test -d {} && ls -lAhF {} || head -n 200 {} 2>/dev/null || file {}' |
        string split0)
    test (count $targets) -eq 0; and return

    set -l permanent
    if set -q _flag_rm; or not command -q trash
        set permanent yes
    end

    printf '  %s\n' (string replace -a -- \n '\\n' $targets)
    set -l prompt "Move "(count $targets)" item(s) to the Trash? [y/N] "
    set -q permanent[1]; and set prompt "Permanently delete "(count $targets)" item(s)? [y/N] "

    read -l -P $prompt confirm
    string match -qri '^y(es)?$' -- $confirm; or return

    # ./ prefix keeps names that start with a dash from being read as flags
    if set -q permanent[1]
        command rm -rf -- ./$targets
    else
        command trash ./$targets
    end
end
