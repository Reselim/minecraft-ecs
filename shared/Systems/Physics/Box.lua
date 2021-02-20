local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Registry = require(ReplicatedStorage.shared.Registry)
local Face = require(script.Parent.Face)
local Axis = require(ReplicatedStorage.shared.Enumerables.Axis)

local function getOtherAxes(axis)
	if axis == Axis.X then
		return Axis.Y, Axis.Z
	elseif axis == Axis.Y then
		return Axis.X, Axis.Z
	elseif axis == Axis.Z then
		return Axis.X, Axis.Y
	end
end

local Box = {}
Box.__index = Box

function Box.new(min, max)
	return setmetatable({
		min = min,
		max = max,
	}, Box)
end

function Box.fromBlock(block)
	local blockRegistry = Registry.getBlock(block.id)
	return Box.new(blockRegistry.getShape())
end

function Box.fromEntity(entity)
	local entityRegistry = Registry.getEntity(entity.data.type)

	local position = entity.state.position
	local size = entityRegistry.getSize(entity)

	return Box.new(
		position - size / 2,
		position + size / 2
	)
end

function Box:offset(offsetVector)
	return Box.new(
		self.min + offsetVector,
		self.max + offsetVector
	)
end

function Box:project(axis)
	local otherAxis1, otherAxis2 = getOtherAxes(axis)

	local min = self.min
	local max = self.max
	
	return Face.new(
		Vector2.new(min[otherAxis1], min[otherAxis2]),
		Vector2.new(max[otherAxis1], max[otherAxis2])
	)
end

return Box