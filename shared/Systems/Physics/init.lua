local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isOwner = require(ReplicatedStorage.shared.isOwner)
local Face = require(ReplicatedStorage.shared.Enumerables.Face)

local Box = require(script.Box)
local Collisions = require(script.Collisions)

local EXAMPLE_COLLIDERS = {
	Box.new(
		Vector3.new(-8, -1, -8),
		Vector3.new(8, 0, 8)
	),
	
	Box.new(
		Vector3.new(7, 0, -8),
		Vector3.new(8, 1, 8)
	),

	Box.new(
		Vector3.new(-8, 0, -8),
		Vector3.new(-7, 1, 8)
	),

	Box.new(
		Vector3.new(-8, 0, 7),
		Vector3.new(8, 1, 8)
	),
	
	Box.new(
		Vector3.new(-8, 0, -8),
		Vector3.new(8, 1, -7)
	),

	Box.new(
		Vector3.new(1, 0, 1),
		Vector3.new(2, 1, 2)
	),

	Box.new(
		Vector3.new(1, 1, 1),
		Vector3.new(2, 2, 2)
	),
}

local PhysicsSystem = {
	priority = 0,
}
PhysicsSystem.__index = PhysicsSystem

function PhysicsSystem.new(world)
	return setmetatable({
		world = world,
	}, PhysicsSystem)
end

function PhysicsSystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("physics")) do
		if not isOwner(entity) then
			continue
		end

		local entityBox

		-- Position

		entityBox = Box.fromEntity(entity)

		local velocity = entity.physics.velocity

		for _, colliderBox in ipairs(EXAMPLE_COLLIDERS) do
			local newVelocity = Collisions.adjustBoxOffsetForCollisions(entityBox, colliderBox, velocity)
			velocity = newVelocity
		end

		entity.state.position += velocity

		-- Touching

		entityBox = Box.fromEntity(entity)

		local touching = {}

		for _, colliderBox in ipairs(EXAMPLE_COLLIDERS) do
			local touchedFace = Collisions.getTouchingFace(entityBox, colliderBox)
			if touchedFace then
				touching[touchedFace] = colliderBox
			end
		end

		if touching[Face.Left] or touching[Face.Right] then
			velocity *= Vector3.new(0, 1, 1)
		end
		if touching[Face.Bottom] or touching[Face.Top] then
			velocity *= Vector3.new(1, 0, 1)
		end
		if touching[Face.Back] or touching[Face.Front] then
			velocity *= Vector3.new(1, 1, 0)
		end
		
		entity.physics.touching = touching
		entity.physics.velocity = velocity
	end
end

return PhysicsSystem