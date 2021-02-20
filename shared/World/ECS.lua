local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.packages.Signal)
local Llama = require(ReplicatedStorage.packages.Llama)

local globalEntityIdCounter = 0
local function createEntityId()
	globalEntityIdCounter += 1
	return tostring(globalEntityIdCounter)
end

local ECS = {}
ECS.__index = ECS

function ECS.new(...)
	return setmetatable({
		_initialArguments = { ... },
		_systems = {},
		_entityToComponents = {},
		_componentToEntities = {},
		_signals = {},
	}, ECS)
end

function ECS:run(methodName, ...)
	for _, system in ipairs(self._systems) do
		local method = system[methodName]
		if method then
			method(system, ...)
		end
	end
end

function ECS:registerSystem(systemClass)
	local newSystem = systemClass.new(unpack(self._initialArguments))

	local index = Llama.List.findWhere(self._systems, function(system)
		return system.priority > newSystem.priority
	end)

	if index then
		table.insert(self._systems, index, newSystem)
	else
		table.insert(self._systems, newSystem)
	end
end

function ECS:registerSystemsIn(container)
	for _, object in ipairs(container:GetChildren()) do
		if object:IsA("ModuleScript") then
			local systemClass = require(object)
			self:registerSystem(systemClass)
		end
	end
end

-- Handle entities

function ECS:addEntity(entityData, entityId)
	entityId = entityId or createEntityId()

	self._entityToComponents[entityId] = entityData

	for componentName, data in pairs(entityData) do
		self:addComponent(entityId, componentName, data)
	end

	return entityId
end

function ECS:removeEntity(entityId)
	local entity = self:getEntityWithId(entityId)

	for componentName in pairs(entity) do
		self:removeComponent(entityId, componentName)
	end

	self._entityToComponents[entityId] = nil
end

-- Manage components

function ECS:addComponent(entityId, componentName, data)
	local entity = self:getEntityWithId(entityId)

	if not self._componentToEntities[componentName] then
		self._componentToEntities[componentName] = {}
	end

	entity[componentName] = data
	self._componentToEntities[componentName][entityId] = entity

	self:_getSignalForComponent("componentAdded", componentName):fire(entityId)
end

function ECS:removeComponent(entityId, componentName)
	local entity = self:getEntityWithId(entityId)

	entity[componentName] = nil
	self._componentToEntities[componentName][entityId] = nil

	self:_getSignalForComponent("componentRemoved", componentName):fire(entityId)
end

-- Fetch entities

function ECS:doesEntityWithIdExist(entityId)
	if self._entityToComponents[entityId] then
		return true
	else
		return false
	end
end

function ECS:getEntityWithId(entityId)
	return assert(self._entityToComponents[entityId], ("Unknown entity with id %s"):format(entityId))
end

function ECS:getEntitiesWithComponent(componentName)
	return self._componentToEntities[componentName] or {}
end

-- Signals

function ECS:_getSignalForComponent(signalName, componentName)
	local signals = self._signals[signalName]
	if not signals then
		signals = {}
		self._signals[signalName] = signals
	end

	local signal = signals[componentName]
	if not signal then
		signal = Signal.new()
		signals[componentName] = signal
	end

	return signal
end

function ECS:getComponentAddedSignal(componentName)
	return self:_getSignalForComponent("componentAdded", componentName)
end

function ECS:getComponentRemovedSignal(componentName)
	return self:_getSignalForComponent("componentRemoved", componentName)
end

return ECS