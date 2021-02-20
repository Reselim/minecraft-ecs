local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isOwner = require(ReplicatedStorage.shared.isOwner)

local TerminalVelocitySystem = {
	priority = -15,
}
TerminalVelocitySystem.__index = TerminalVelocitySystem

function TerminalVelocitySystem.new(world)
	return setmetatable({
		world = world,
	}, TerminalVelocitySystem)
end

function TerminalVelocitySystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("physics")) do
		if not isOwner(entity) then
			continue
		end

		local velocity = entity.physics.velocity

		if math.abs(velocity.X) < 0.005 then
			velocity *= Vector3.new(0, 1, 1)
		end
		if math.abs(velocity.Y) < 0.005 then
			velocity *= Vector3.new(1, 0, 1)
		end
		if math.abs(velocity.Z) < 0.005 then
			velocity *= Vector3.new(1, 1, 0)
		end

		entity.physics.velocity = velocity
	end
end

return TerminalVelocitySystem