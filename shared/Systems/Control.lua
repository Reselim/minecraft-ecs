-- ControlSystem takes input and turns it into velocity.
-- REFERENCE: https://www.mcpk.wiki/wiki/Horizontal_Movement_Formulas

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Registry = require(ReplicatedStorage.shared.Registry)
local isOwner = require(ReplicatedStorage.shared.isOwner)
local Face = require(ReplicatedStorage.shared.Enumerables.Face)

local function lerp(A, B, alpha)
	return A + (B - A) * alpha
end

local function rotateVector(vector, angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)

	return Vector2.new(
		vector.X * cos + vector.Y * sin,
		-vector.X * sin + vector.Y * cos
	)
end

local function getMovementMultiplier(entity)
	local movement = entity.control.movement
	local angle = math.atan2(movement.Y, movement.X)
	local strafe = 1 - math.abs(math.deg(angle) % 90 / 45 - 1) -- [0..1]

	local multiplier = 1

	if entity.control.sneaking then
		multiplier = 0.3
	elseif entity.control.sprinting then
		multiplier = 1.3
	end

	if entity.control.sneaking then
		multiplier *= 0.98 * lerp(1, math.sqrt(2), strafe)
	else
		multiplier *= lerp(0.98, 1, strafe)
	end

	return multiplier
end

local function getSlipperinessMultiplier(entity, world)
	if entity.physics.touching[Face.Bottom] then
		local entityRegistry = Registry.getEntity(entity.data.type)

		local floor = entity.state.position - Vector3.new(0, entityRegistry.getSize(entity).Y / 2, 0)
		local block = world:getBlock(floor + Vector3.new(0, -0.5, 0))

		local blockRegistry = Registry.getBlock(block.id)
		return blockRegistry.getSlipperiness(block, entity)
	else
		return 1 -- Airborne
	end
end

local ControlSystem = {
	priority = -10,
}
ControlSystem.__index = ControlSystem

function ControlSystem.new(world)
	return setmetatable({
		world = world,
	}, ControlSystem)
end

function ControlSystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("control")) do
		if not isOwner(entity) then
			continue
		end

		local entityRegistry = Registry.getEntity(entity.data.type)

		local velocity = entity.physics.velocity
		local rotation = entity.state.rotation

		local movement = entity.control.movement
		local jumping = entity.control.jumping
		local sprinting = entity.control.sprinting

		local onGround = not not entity.physics.touching[Face.Bottom]

		-- Moving

		local movementModifier = getMovementMultiplier(entity)
		local slipperinessModifier = getSlipperinessMultiplier(entity, self.world)

		local relativeMovement = rotateVector(movement, math.rad(rotation.X) + math.pi)
		local acceleration = relativeMovement

		if onGround then
			acceleration *= entityRegistry.getWalkSpeed(entity) * movementModifier * (0.6 / slipperinessModifier) ^ 3
		else
			acceleration *= 0.02 * movementModifier
		end

		velocity *= Vector3.new(slipperinessModifier, 1, slipperinessModifier)
		velocity *= Vector3.new(0.91, 1, 0.91)
		velocity += Vector3.new(acceleration.X, 0, acceleration.Y)

		-- Jumping

		if jumping and onGround then
			local jumpVelocity = entityRegistry.getJumpVelocity()
			velocity = Vector3.new(velocity.X, jumpVelocity, velocity.Z)

			if sprinting then
				local sprintJumpAngle = -math.rad(rotation.X)
				local sprintJumpX = math.sin(sprintJumpAngle)
				local sprintJumpY = -math.cos(sprintJumpAngle)
				
				velocity += Vector3.new(sprintJumpX, 0, sprintJumpY) * 0.2
			end
		end

		-- Update velocity

		entity.physics.velocity = velocity
	end
end

return ControlSystem