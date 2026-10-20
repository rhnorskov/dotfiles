function claude-gw --description "Run Claude Code through the local LiteLLM proxy"
    set -l base http://127.0.0.1:4000

    if not command curl -fsS -m 2 -o /dev/null $base/health/liveliness 2>/dev/null
        echo "claude-gw: LiteLLM proxy is not reachable at $base" >&2
        echo "  launchctl print gui/"(id -u)"/local.litellm; tail ~/Library/Logs/litellm.log" >&2
        return 1
    end

    set -l key (command security find-generic-password -s litellm-master-key -w 2>/dev/null)
    if test -z "$key"
        echo "claude-gw: no litellm-master-key in the login Keychain" >&2
        return 1
    end

    # The header carries the proxy key so Authorization stays free for the
    # subscription token; API key variables would replace that login.
    set -lx ANTHROPIC_BASE_URL $base
    set -lx ANTHROPIC_CUSTOM_HEADERS "x-litellm-api-key: Bearer $key"
    env -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN claude $argv
end
