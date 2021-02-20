local RunService = game:GetService("RunService")

local ECS = require(script.ECS)
local Chunk = require(script.Chunk)

local World = {}
World.__index = World

function World.new()
	local self = setmetatable({
		_chunks = {
			[-1] = {
				[-1] = Chunk.new(),
				[0] = Chunk.new(),
			},
			[0] = {
				[-1] = Chunk.new(),
				[0] = Chunk.new(),
			},
		},
	}, World)

	self.ECS = ECS.new(self)

	if RunService:IsClient() then
		RunService.RenderStepped:Connect(function(...)
			self.ECS:run("render", ...)
		end)
	end

	local counter = 0
	RunService.Stepped:Connect(function()
		counter += 1
		if counter >= 3 then
			counter = 0
			self.ECS:run("tick")
		end
	end)

	return self
end

function World:getChunk(position)
	return self._chunks[position.X][position.Y]
end

function World:getBlock(position)
	local chunkPosition = Vector2.new(
		math.floor(position.X / 16),
		math.floor(position.Z / 16)
	)

	local relativeBlockPosition = Vector3.new(
		position.X % 16,
		position.Y,
		position.Z % 16
	)

	local chunk = self:getChunk(chunkPosition)
	local block = chunk:getBlock(relativeBlockPosition)

	return block
end

return World