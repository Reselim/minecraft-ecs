local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Llama = require(ReplicatedStorage.packages.Llama)

local Side = require(ReplicatedStorage.shared.Enumerables.Side)
local Face = require(ReplicatedStorage.shared.Enumerables.Face)
local Axis = require(ReplicatedStorage.shared.Enumerables.Axis)

local function pick(dictionary, value)
	if value == nil then
		return nil
	end

	return dictionary[value]
end

local function sortVector3(vector)
	local axes = { Axis.X, Axis.Y, Axis.Z }

	table.sort(axes, function(axis1, axis2)
		return vector[axis1] > vector[axis2]
	end)

	return axes
end

local Collisions = {}

-- Axis (1D)

function Collisions.doesAxisCollide(axis, collider1, collider2)
	local min1 = collider1.min[axis]
	local max1 = collider1.max[axis]

	local min2 = collider2.min[axis]
	local max2 = collider2.max[axis]

	return (min1 >= min2 and min1 < max2)
		or (max1 > min2 and max1 <= max2)
		or (min1 < min2 and max1 > max2)
end

function Collisions.adjustAxisOffsetForCollisions(axis, colliderMoving, colliderStatic, offset)
	local minMoving = colliderMoving.min[axis]
	local maxMoving = colliderMoving.max[axis]

	local minStatic = colliderStatic.min[axis]
	local maxStatic = colliderStatic.max[axis]

	local offsetAxis = offset[axis]

	-- Lower
	local newMinMoving = minMoving + offsetAxis
	if minMoving >= maxStatic and newMinMoving < maxStatic then
		offsetAxis = maxStatic - minMoving
	end

	-- Upper
	local newMaxMoving = maxMoving + offsetAxis
	if maxMoving <= minStatic and newMaxMoving > minStatic then
		offsetAxis = minStatic - maxMoving
	end

	return offsetAxis
end

function Collisions.getTouchingSide(axis, collider1, collider2)
	if collider1.min[axis] == collider2.max[axis] then
		return Side.Lower
	end

	if collider1.max[axis] == collider2.min[axis] then
		return Side.Upper
	end

	return nil
end

-- Face (2D)

function Collisions.doFacesCollide(face1, face2)
	return Collisions.doesAxisCollide(Axis.X, face1, face2)
		and Collisions.doesAxisCollide(Axis.Y, face1, face2)
end

-- Box (3D)

function Collisions.doBoxesCollide(box1, box2)
	return Collisions.doesAxisCollide(Axis.X, box1, box2)
		and Collisions.doesAxisCollide(Axis.Y, box1, box2)
		and Collisions.doesAxisCollide(Axis.Z, box1, box2)
end

function Collisions.adjustBoxOffsetForCollisions(boxMoving, boxStatic, offset)
	if Collisions.doBoxesCollide(boxMoving, boxStatic) then
		return offset
	end

	local axes = sortVector3(offset)

	local offsetLookup = {
		[Axis.X] = offset.X,
		[Axis.Y] = offset.Y,
		[Axis.Z] = offset.Z,
	}

	for _, axis in ipairs(axes) do
		local newBox = boxMoving:offset(offset)
		
		if Collisions.doFacesCollide(newBox:project(axis), boxStatic:project(axis)) then
			offsetLookup[axis] = Collisions.adjustAxisOffsetForCollisions(axis, boxMoving, boxStatic, offset)
		end

		offset = Vector3.new(
			offsetLookup[Axis.X],
			offsetLookup[Axis.Y],
			offsetLookup[Axis.Z]
		)
	end

	return offset
end

function Collisions.getTouchingFace(box1, box2)
	if Collisions.doFacesCollide(box1:project(Axis.X), box2:project(Axis.X)) then
		return pick({
			[Side.Lower] = Face.Left,
			[Side.Upper] = Face.Right,
		}, Collisions.getTouchingSide(Axis.X, box1, box2))
	end
	if Collisions.doFacesCollide(box1:project(Axis.Y), box2:project(Axis.Y)) then
		return pick({
			[Side.Lower] = Face.Bottom,
			[Side.Upper] = Face.Top,
		}, Collisions.getTouchingSide(Axis.Y, box1, box2))
	end
	if Collisions.doFacesCollide(box1:project(Axis.Z), box2:project(Axis.Z)) then
		return pick({
			[Side.Lower] = Face.Back,
			[Side.Upper] = Face.Front,
		}, Collisions.getTouchingSide(Axis.Z, box1, box2))
	end

	return nil
end

return Collisions