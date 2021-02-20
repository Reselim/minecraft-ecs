local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.packages.t)
local Llama = require(ReplicatedStorage.packages.Llama)

local DEFAULT_BLOCK = {
	id = "minecraft:air",
	exists = false,
	state = {},
}

local IBlock = t.strictInterface({
	id = t.string,
	exists = t.boolean,
	state = t.map(t.string, t.string),
})

local Chunk = {}
Chunk.__index = Chunk

function Chunk.new()
	local self = setmetatable({
		_data = {},
	}, Chunk)

	for Y = 0, 256 - 1 do
		local listY = {}

		for X = 0, 16 - 1 do
			local listX = {}
			listY[X] = listX
		end

		self._data[Y] = listY
	end

	return self
end

function Chunk:getBlock(position)
	position = Vector3.new(
		math.floor(position.X),
		math.floor(position.Y),
		math.floor(position.Z)
	)

	if position.Y < 0 or position.Y > 256 - 1 then
		return DEFAULT_BLOCK
	end
	
	return self._data[position.Y][position.X][position.Z] or DEFAULT_BLOCK
end

function Chunk:setBlock(position, data)
	position = Vector3.new(
		math.floor(position.X),
		math.floor(position.Y),
		math.floor(position.Z)
	)
	
	data = Llama.Dictionary.join(data, {
		exists = true,
	})

	assert(IBlock(data))

	self._data[position.Y][position.X][position.Z] = data
end

return Chunk