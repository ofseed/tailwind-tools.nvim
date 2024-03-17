local M = {}

local valid_ft = {
  "html",
  "css",
  "php",
  "vue",
  "svelte",
  "astro",
  "javascriptreact",
  "typescriptreact",
}

local lang_map = {
  javascriptreact = "tsx",
  typescriptreact = "tsx",
}

---@param bufnr number
M.get_class_iter = function(bufnr)
  local ft = vim.bo[bufnr].ft

  if vim.tbl_contains(valid_ft, ft) then
    local lang = lang_map[ft] or ft
    local parser = vim.treesitter.get_parser(bufnr, lang)
    local tree = parser:parse()
    local root = tree[1]:root()
    local query = assert(vim.treesitter.query.get(lang, "class"))
    return query:iter_matches(root, bufnr, root:start(), root:end_(), { all = true })
  end
end

---@param node TSNode
---@param bufnr number
M.get_class_range = function(node, bufnr)
  local start_row, start_col, end_row, end_col = node:range()
  local children = node:named_children()

  if children[1] and vim.treesitter.get_node_text(children[1], bufnr) == "@apply" then
    start_row, start_col, end_row, _ = children[2]:range()
    _, _, _, end_col = children[#children]:range()
  end

  return start_row, start_col, end_row, end_col
end

return M
