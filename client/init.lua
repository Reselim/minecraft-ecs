local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.shared.World)

local test = World.new()

test.ECS:registerSystemsIn(script.Systems)
test.ECS:registerSystemsIn(ReplicatedStorage.shared.Systems)

return true