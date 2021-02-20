local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.shared.World)

local test = World.new()
test.ECS:registerSystemsIn(script.Systems)

local playerEntityIds = {}

Players.PlayerAdded:Connect(function(player)
	playerEntityIds[player] = test.ECS:addEntity({
		state = {
			position = Vector3.new(0, 16, 0),
			rotation = Vector2.new(0, 0),
		},

		control = {
			movement = Vector2.new(0, 0),
			jumping = false,
			flying = false,
			sprinting = false,
			sneaking = false,
		},

		data = {
			type = "minecraft:player",
		},
		
		replication = {
			owner = player,
			ignore = { player },
			immediate = true,
		},
	})
end)

Players.PlayerRemoving:Connect(function(player)
	test.ECS:removeEntity(playerEntityIds[player])
	playerEntityIds[player] = nil
end)

return true