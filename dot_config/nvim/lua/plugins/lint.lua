-- nvim-lint pipes the buffer to markdownlint-cli2 on stdin, so the tool resolves
-- config from the process cwd and never searches near the file. Point it at a
-- base config explicitly; a repo-local .markdownlint-cli2.jsonc still overrides it.
local markdownlint_config =
  vim.fs.joinpath(vim.fn.stdpath("config"), "markdownlint", ".markdownlint-cli2.jsonc")

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      -- Without the base config the linter would die on a missing --config path,
      -- silently dropping every markdown diagnostic.
      if not vim.uv.fs_stat(markdownlint_config) then
        return
      end
      opts.linters = opts.linters or {}
      -- LazyVim appends prepend_args to the linter's args.
      opts.linters["markdownlint-cli2"] = {
        prepend_args = { "--config", markdownlint_config },
      }
    end,
  },
}
