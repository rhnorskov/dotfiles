function ghc --description "Fuzzy search and clone your GitHub repos"
    argparse 'h/help' -- $argv
    or return

    set -l owner $argv[1]
    set -l clone_args $argv[2..]

    set -l cache_dir ~/.cache/ghc
    mkdir -p $cache_dir
    set -l owners_cache $cache_dir/_owners

    if test -z "$owner"
        set -l fetch_owners "gh api user/orgs --jq '.[].login' | begin; gh api user --jq '.login'; cat; end"
        if test -s $owners_cache
            set -l sock /tmp/fzf-ghc-owners-$fish_pid.sock
            command fish -c "
                eval $fetch_owners >$owners_cache.tmp
                and mv $owners_cache.tmp $owners_cache
                and curl -s --unix-socket $sock http -d 'reload(cat $owners_cache)'
                rm -f $owners_cache.tmp
            " &
            disown $last_pid 2>/dev/null
            set owner (cat $owners_cache | fzf --prompt="Owner> " --listen=$sock)
            rm -f $sock
        else
            set owner (eval $fetch_owners | tee $owners_cache | fzf --prompt="Owner> ")
        end
        test -n "$owner"; or return
    end

    set -l cache_file $cache_dir/$owner

    set -l repo
    if test -s $cache_file
        set -l sock /tmp/fzf-ghc-$fish_pid.sock
        command fish -c "
            gh repo list $owner --limit 200 --json nameWithOwner --jq '.[].nameWithOwner' >$cache_file.tmp
            and mv $cache_file.tmp $cache_file
            and curl -s --unix-socket $sock http -d 'reload(cat $cache_file)'
            rm -f $cache_file.tmp
        " &
        disown $last_pid 2>/dev/null
        set repo (cat $cache_file | fzf --prompt="Clone repo> " --listen=$sock)
        rm -f $sock
    else
        set repo (gh repo list $owner --limit 200 --json nameWithOwner --jq '.[].nameWithOwner' | tee $cache_file | fzf --prompt="Clone repo> ")
    end
    test -n "$repo"; or return

    gh repo clone $repo $clone_args
end
