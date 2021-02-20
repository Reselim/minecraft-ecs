local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Registry = require(ReplicatedStorage.shared.Registry)
local config = require(ReplicatedStorage.shared.config)

local CameraSystem = {
	priority = 100,
}
CameraSystem.__index = CameraSystem

function CameraSystem.new(world)
	return setmetatable({
		world = world,
		camera = Workspace.CurrentCamera,
		_renderFovMultiplier = 1,
	}, CameraSystem)
end

function CameraSystem:render()
	for _, entity in pairs(self.world.ECS:getEntitiesWithComponent("localPlayer")) do
		if entity.localPlayer.camera then
			local registry = Registry.getEntity(entity.data.type)

			self.camera.FieldOfView = 90

			-- CFrame
			
			local position = entity.interpolation.position
			local rotation = entity.state.rotation

			position += Vector3.new(0, registry.getEyeHeight(entity) / 2, 0)

			local cframe = CFrame.new(position * config.worldScale)
				* CFrame.Angles(0, math.rad(rotation.X), 0)
				* CFrame.Angles(math.rad(rotation.Y), 0, 0)
			
			self.camera.CFrame = cframe
		end
	end
end

return CameraSystem