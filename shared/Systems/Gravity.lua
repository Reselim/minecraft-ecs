local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isOwner = require(ReplicatedStorage.shared.isOwner)
local Face = require(ReplicatedStorage.shared.Enumerables.Face)

local GravitySystem = {
	priority = -1,
}
GravitySystem.__index = GravitySystem

function GravitySystem.new(world)
	return setmetatable({
		world = world,
	}, GravitySystem)
end

function GravitySystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("physics")) do
		if not isOwner(entity) then
			continue
		end

		if not entity.physics.touching[Face.Bottom] then
			local velocity = entity.physics.velocity

			local verticalVelocity = velocity.Y
			verticalVelocity -= 0.08
			verticalVelocity *= 0.98

			entity.physics.velocity = Vector3.new(velocity.X, verticalVelocity, velocity.Z)
		end
	end
end

return GravitySystem