local Air = require(script.Parent.Air)

local Test = setmetatable({}, { __index = Air })

Test.name = "Test"

return Test