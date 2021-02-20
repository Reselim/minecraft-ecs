local Namespace = {}
Namespace.__index = Namespace

function Namespace.new(name)
	return setmetatable({
		name = name,
		entities = {},
		blocks = {},
	}, Namespace)
end

function Namespace.from(name, container)
	local self = Namespace.new(name)

	for _, module in ipairs(container.entities:GetChildren()) do
		local entityRegistry = require(module)
		self:registerEntity(entityRegistry)
	end

	for _, module in ipairs(container.blocks:GetChildren()) do
		local blockRegistry = require(module)
		self:registerBlock(blockRegistry)
	end

	return self
end

function Namespace:registerEntity(entityRegistry)
	self.entities[entityRegistry.name] = entityRegistry
end

function Namespace:registerBlock(blockRegistry)
	self.blocks[blockRegistry.name] = blockRegistry
end

return Namespace