--[[
  math-no-auto-number.lua — ElegantBook PDF Extension
  Converts unlabeled display math ($$...$$) to LaTeX \[...\] to prevent
  Quarto from auto-numbering every display equation.

  Only display math with an explicit label ({#eq-xxx}) is rendered as
  \begin{equation}...\end{equation} with a number.
--]]

function Math(el)
  if el.mathtype ~= "DisplayMath" then
    return nil  -- not display math, don't touch
  end

  -- Check identifier through multiple access paths (Pandoc version compat)
  local id = el.identifier
  if id == nil and el.attr then
    id = el.attr.identifier
  end

  if id == nil or id == "" then
    -- Unlabeled display math → raw LaTeX \[...\] (no number)
    return pandoc.RawInline("latex", "\\[" .. el.text .. "\\]")
  end

  -- Labeled equation → leave untouched so Quarto crossrefs can find it
  return nil
end
