local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isOwner = require(ReplicatedStorage.shared.isOwner)

local RespawnSystem = {
	priority = 5,
}
RespawnSystem.__index = RespawnSystem

function RespawnSystem.new(world)
	return setmetatable({
		world = world,
	}, RespawnSystem)
end

function RespawnSystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("physics")) do
		if not isOwner(entity) then
			continue
		end

		local position = entity.state.position
		local velocity = entity.physics.velocity

		if position.Y < -20 then
			position = Vector3.new(0, 12, 0)
			velocity = Vector3.new(0, 0, 0)
		end

		entity.state.position = position
		entity.physics.velocity = velocity
	end
end

return RespawnSystem