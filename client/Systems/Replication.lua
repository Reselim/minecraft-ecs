local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Maid = require(ReplicatedStorage.packages.Maid)
local Llama = require(ReplicatedStorage.packages.Llama)

local remotes = require(ReplicatedStorage.shared.remotes)

local functionGetEntities = remotes.Client:Get("functionGetEntities")

local packetEntityAdd = remotes.Client:Get("packetEntityAdd")
local packetEntityRemove = remotes.Client:Get("packetEntityRemove")
local packetEntityMove = remotes.Client:Get("packetEntityMove")
local packetEntityControl = remotes.Client:Get("packetEntityControl")

local localPlayer = Players.LocalPlayer

local ReplicationSystem = {
	priority = 1000,
}
ReplicationSystem.__index = ReplicationSystem

function ReplicationSystem.new(world)
	local self = setmetatable({
		world = world,
	}, ReplicationSystem)

	local function addEntity(entityId, entity)
		if world.ECS:doesEntityWithIdExist(entityId) then
			return
		end

		entity = Llama.Dictionary.join(entity, {
			render = {},
			interpolation = Llama.Dictionary.copy(entity.state),
		})

		if entity.replication.owner == localPlayer and entity.data.type == "minecraft:player" then
			-- TODO: make this better

			entity = Llama.Dictionary.join(entity, {
				control = {
					movement = Vector2.new(0, 0),
					speed = 0.1,
					flying = false,
					jumping = false,
					sprinting = false,
					sneaking = false,
				},

				localPlayer = {
					camera = true,
					control = true,
				},

				physics = {
					velocity = Vector3.new(0, 0, 0),
					touching = {},
				},
			})
		end

		world.ECS:addEntity(entity, entityId)
	end

	functionGetEntities:CallServerAsync():andThen(function(entities)
		for id, entity in pairs(entities) do
			addEntity(id, entity)
		end
	end)

	self._maid = Maid.new({
		packetEntityAdd:Connect(addEntity),

		packetEntityRemove:Connect(function(entityId)
			print("got remove", entityId)
			world.ECS:removeEntity(entityId)
		end),

		packetEntityMove:Connect(function(entityId, packet)
			local entity = world.ECS:getEntityWithId(entityId)
			entity.state.position = packet.position
			entity.state.rotation = packet.rotation
		end),

		packetEntityControl:Connect(function(entityId, packet)
			local entity = world.ECS:getEntityWithId(entityId)
			entity.control.movement = packet.movement
			entity.control.jumping = packet.jumping
			entity.control.sneaking = packet.sneaking
			entity.control.sprinting = packet.sprinting
			entity.control.flying = packet.flying
		end),
	})

	return self
end

function ReplicationSystem:tick()
	for entityId, entity in pairs(self.world.ECS:getEntitiesWithComponent("replication")) do
		if entity.replication.owner == localPlayer then
			local state = entity.state
			if state then
				packetEntityMove:SendToServer(entityId, {
					position = state.position,
					rotation = state.rotation,
				})
			end

			local control = entity.control
			if control then
				packetEntityControl:SendToServer(entityId, {
					movement = control.movement,
					jumping = control.jumping,
					sneaking = control.sneaking,
					sprinting = control.sprinting,
					flying = control.flying,
				})
			end
		end
	end
end

function ReplicationSystem:destroy()
	self._maid:clean()
end

return ReplicationSystem