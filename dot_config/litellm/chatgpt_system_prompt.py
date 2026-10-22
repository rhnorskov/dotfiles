"""Folds all system text into one plain-string system prompt for chatgpt/* requests.

The ChatGPT Codex backend accepts system text only as `instructions`, and
LiteLLM's Anthropic-to-Responses bridge fills that only from a plain-string
system prompt. Claude Code sends system text as a block list and again as
role=system messages inside `messages`; both are merged here. Non-text blocks
such as tool_addition are dropped.
"""

from litellm.integrations.custom_logger import CustomLogger


def _text_of(content):
    if isinstance(content, str):
        return content
    return "\n\n".join(
        block["text"]
        for block in content
        if isinstance(block, dict) and block.get("type") == "text"
    )


class FoldSystemPrompt(CustomLogger):
    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        if not str(data.get("model", "")).startswith("chatgpt/"):
            return data

        parts = [_text_of(data["system"])] if data.get("system") else []
        kept = []
        for message in data.get("messages", []):
            if message.get("role") == "system":
                parts.append(_text_of(message.get("content", "")))
            else:
                kept.append(message)

        data["messages"] = kept
        text = "\n\n".join(part for part in parts if part)
        if text:
            data["system"] = text
        return data


proxy_handler_instance = FoldSystemPrompt()
