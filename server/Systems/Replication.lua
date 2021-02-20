local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.packages.Maid)

local remotes = require(ReplicatedStorage.shared.remotes)

local packetEntityAdd = remotes.Server:Create("packetEntityAdd")
local packetEntityRemove = remotes.Server:Create("packetEntityRemove")
local packetEntityMove = remotes.Server:Create("packetEntityMove")
local packetEntityControl = remotes.Server:Create("packetEntityControl")

local functionGetEntities = remotes.Server:Create("functionGetEntities")

local ReplicationSystem = {
	priority = 1000,
}
ReplicationSystem.__index = ReplicationSystem

function ReplicationSystem.new(world)
	local self = setmetatable({
		world = world,
	}, ReplicationSystem)

	world.ECS:getComponentAddedSignal("replication"):connect(function(entityId)
		local entity = world.ECS:getEntityWithId(entityId)
		packetEntityAdd:SendToAllPlayers(entityId, entity)
	end)

	world.ECS:getComponentRemovedSignal("replication"):connect(function(entityId)
		packetEntityRemove:SendToAllPlayers(entityId)
	end)

	functionGetEntities:SetCallback(function()
		return world.ECS:getEntitiesWithComponent("replication")
	end)

	self._maid = Maid.new({
		packetEntityMove:Connect(function(player, entityId, packet)
			local entity = world.ECS:getEntityWithId(entityId)

			if entity.replication.owner == player then
				entity.state.position = packet.position
				entity.state.rotation = packet.rotation

				if entity.replication.immediate then
					packetEntityMove:SendToAllPlayersExcept(entity.replication.owner, entityId, packet)
				end
			end
		end),

		packetEntityControl:Connect(function(player, entityId, packet)
			local entity = world.ECS:getEntityWithId(entityId)

			if entity.replication.owner == player then
				entity.control.movement = packet.movement
				entity.control.jumping = packet.jumping
				entity.control.sneaking = packet.sneaking
				entity.control.sprinting = packet.sprinting
				entity.control.flying = packet.flying

				if entity.replication.immediate then
					packetEntityControl:SendToAllPlayersExcept(entity.replication.owner, entityId, packet)
				end
			end
		end),
	})

	return self
end

function ReplicationSystem:tick()
	for entityId, entity in pairs(self.world.ECS:getEntitiesWithComponent("replication")) do
		if not entity.replication.immediate then
			local owner = entity.replication.owner

			local state = entity.state
			if state then
				local packet = {
					position = state.position,
					rotation = state.rotation,
				}

				if owner then
					packetEntityMove:SendToAllPlayersExcept(owner, entityId, packet)
				else
					packetEntityMove:SendToAllPlayers(entityId, packet)
				end
			end

			local control = entity.control
			if control then
				local packet = {
					movement = control.movement,
					jumping = control.jumping,
					sneaking = control.sneaking,
					sprinting = control.sprinting,
					flying = control.flying,
				}

				if owner then
					packetEntityControl:SendToAllPlayersExcept(owner, entityId, packet)
				else
					packetEntityControl:SendToAllPlayers(entityId, packet)
				end
			end
		end
	end
end

function ReplicationSystem:destroy()
	self._maid:clean()
end

return ReplicationSystem