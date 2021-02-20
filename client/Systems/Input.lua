local UserInputService = game:GetService("UserInputService")

local SENSITIVITY = 0.5

local movementKeys = {
	[Enum.KeyCode.W] = Vector2.new(0, 1),
	[Enum.KeyCode.A] = Vector2.new(1, 0),
	[Enum.KeyCode.S] = Vector2.new(0, -1),
	[Enum.KeyCode.D] = Vector2.new(-1, 0),
}

local function getMovementVector()
	local vector = Vector2.new(0, 0)

	for keyCode, offset in pairs(movementKeys) do
		if UserInputService:IsKeyDown(keyCode) then
			vector += offset
		end
	end

	if vector.Magnitude > 0 then
		return vector.Unit
	else
		return Vector2.new(0, 0)
	end
end

local function isJumping()
	return UserInputService:IsKeyDown(Enum.KeyCode.Space)
end

local function isSprinting()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
end

local function isSneaking()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
end

local InputSystem = {
	priority = -100,
}
InputSystem.__index = InputSystem

function InputSystem.new(world)
	return setmetatable({
		world = world,
		_mouseDelta = Vector2.new(),
	}, InputSystem)
end

function InputSystem:tick()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("localPlayer")) do
		if entity.localPlayer.control then
			local movement = getMovementVector()

			local jumping = isJumping()
			local sprinting = isSprinting()
			local sneaking = isSneaking()

			entity.control.movement = movement
			entity.control.jumping = jumping
			--entity.control.sneaking = sneaking

			local movementAngle = math.deg(math.atan2(movement.X, movement.Y))
			if math.abs(movementAngle) <= 45 and not sneaking then
				if sprinting then
					entity.control.sprinting = true
				end
			else
				entity.control.sprinting = false
			end
		end
	end
end

function InputSystem:render()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("localPlayer")) do
		if entity.localPlayer.control then
			local rotation = entity.state.rotation

			local delta = -UserInputService:GetMouseDelta()
			delta *= (0.6 * SENSITIVITY + 0.2) ^ 3 * 1.2
			
			rotation += delta
			rotation = Vector2.new(rotation.X % 360, math.clamp(rotation.Y, -90, 90))

			entity.state.rotation = rotation
		end
	end
end

function InputSystem:destroy()
	self._mouseListener:Disconnect()
end

return InputSystem