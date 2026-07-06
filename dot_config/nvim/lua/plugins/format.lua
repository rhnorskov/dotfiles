-- Per-project formatter choice: biome config -> biome-check, prettier config ->
-- prettier, neither -> biome-check with defaults. Nearest config wins.
local prettier_configs = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.toml",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
}

local function prettier_package_json_root(path)
  local pkgs = vim.fs.find("package.json", { upward = true, path = path, limit = math.huge })
  for _, pkg in ipairs(pkgs) do
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
    if ok and type(data) == "table" and data.prettier ~= nil then
      return vim.fs.dirname(pkg)
    end
  end
  return nil
end

local function choose(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local biome_root = vim.fs.root(bufnr, { "biome.json", "biome.jsonc" })
  local prettier_root = vim.fs.root(bufnr, prettier_configs) or prettier_package_json_root(dir)
  if biome_root and prettier_root then
    -- Both are ancestors of the buffer, so the longer path is the nearer root.
    return #biome_root >= #prettier_root and { "biome-check" } or { "prettier" }
  end
  if prettier_root then
    return { "prettier" }
  end
  return { "biome-check" }
end

local filetypes = {
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "typescript",
  "typescriptreact",
}

local formatters_by_ft = {}
for _, ft in ipairs(filetypes) do
  formatters_by_ft[ft] = choose
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = formatters_by_ft,
      formatters = {
        ["biome-check"] = {
          require_cwd = false,
          args = { "check", "--write", "--format-with-errors=true", "--stdin-file-path", "$FILENAME" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettier" } },
  },
}
