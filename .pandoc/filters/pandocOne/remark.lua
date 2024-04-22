--- remark.lua – filter to Markdown Remark
---
--- Copyright: © 2024 Ajeep
--- License:   MIT – see LICENSE file for details

PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'

--- Filter function for remark blocks
local transclude
function transclude (cb)
  if not cb.classes:includes 'remark' then
    return
  end

  local blocks = List:new()
  return blocks
end

return {
  { Meta = get_vars },
  { Header = update_last_level, CodeBlock = transclude }
}
