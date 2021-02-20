local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Registry = require(ReplicatedStorage.shared.Registry)
local config = require(ReplicatedStorage.shared.config)

local RenderSystem = {
	priority = 100,
}
RenderSystem.__index = RenderSystem

function RenderSystem.new(world)
	local self = setmetatable({
		world = world,
		camera = Workspace.CurrentCamera,
		_objects = {},
	}, RenderSystem)

	self.camera.CameraType = Enum.CameraType.Scriptable

	world.ECS:getComponentAddedSignal("render"):connect(function(entityId)
		local object = Instance.new("Part")
		object.Anchored = true
		object.CanCollide = false
		object.Transparency = 1
		object.Parent = Workspace

		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Color3 = Color3.new(1, 0, 0)
		selectionBox.LineThickness = 0.01
		selectionBox.Transparency = 0
		selectionBox.Adornee = object
		selectionBox.Parent = object

		self._objects[entityId] = object
	end)

	world.ECS:getComponentRemovedSignal("render"):connect(function(entityId)
		self._objects[entityId]:Destroy()
		self._objects[entityId] = nil
	end)

	return self
end

function RenderSystem:render()
	for entityId, entity in pairs(self.world.ECS:getEntitiesWithComponent("render")) do
		local entityRegistry = Registry.getEntity(entity.data.type)

		local physicalObject = self._objects[entityId]
		physicalObject.CFrame = CFrame.new(entity.interpolation.position * config.worldScale)
		physicalObject.Size = entityRegistry.getSize(entity) * config.worldScale
	end
end

return RenderSystem