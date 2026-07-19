-- div-environments.lua
-- Maps Quarto fenced divs with custom classes to LaTeX environments.
-- Only active for LaTeX/PDF output.

local env_map = {
  introduction = true,
  example      = true,
  exercise     = true,
  problem      = true,
  note         = true,
  assumption   = true,
  conclusion   = true,
  property     = true,
  problemset   = true,
  proof        = true,
  solution     = true,
  remark       = true,
}

function Div(el)
  -- Only process for LaTeX/PDF output
  if not FORMAT:match("latex") and not FORMAT:match("pdf") then
    return nil
  end
  -- Debug: log all divs
  if #el.classes > 0 then
    io.stderr:write("[DEBUG] Div classes: " .. table.concat(el.classes, ", ") .. "\n")
  end
  -- Look for a class matching one of our environments
  for _, cls in ipairs(el.classes) do
    if env_map[cls] then
      io.stderr:write("[DEBUG] Matched environment: " .. cls .. "\n")
      local begin_block = pandoc.RawBlock("latex", "\\begin{" .. cls .. "}")
      local end_block   = pandoc.RawBlock("latex", "\\end{" .. cls .. "}")
      local blocks = {}
      table.insert(blocks, begin_block)
      for _, b in ipairs(el.content) do
        table.insert(blocks, b)
      end
      table.insert(blocks, end_block)
      return blocks
    end
  end
  return nil
end
