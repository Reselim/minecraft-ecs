local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Llama = require(ReplicatedStorage.packages.Llama)

local InterpolationSystem = {
	priority = 100 - 1,
}
InterpolationSystem.__index = InterpolationSystem

function InterpolationSystem.new(world)
	local self = setmetatable({
		world = world,
	}, InterpolationSystem)

	self._lastEntitiesState = {}
	self._lastTime = os.clock()

	self._entitiesState = self._lastEntitiesState
	self._time = self._lastTime

	world.ECS:getComponentRemovedSignal("interpolation"):connect(function(entityId)
		self._lastEntitiesState[entityId] = nil
	end)

	return self
end

function InterpolationSystem:tick()
	self._lastEntitiesState = self._entitiesState
	self._lastTime = self._time

	self._entitiesState = {}
	self._time = os.clock()

	for entityId, entity in pairs(self.world.ECS:getEntitiesWithComponent("interpolation")) do
		self._entitiesState[entityId] = Llama.Dictionary.copyDeep(entity.state)
	end
end

function InterpolationSystem:render()
	for entityId, entity in pairs(self.world.ECS:getEntitiesWithComponent("interpolation")) do
		local lastState = self._lastEntitiesState[entityId]
		local state = self._entitiesState[entityId]

		if lastState then
			local alpha = (os.clock() - self._time) / (1 / 20)
			alpha = math.clamp(alpha, 0, 1)

			entity.interpolation = {
				position = lastState.position:Lerp(state.position, alpha),
				rotation = lastState.rotation:Lerp(state.rotation, alpha),
			}
		elseif state then
			entity.interpolation = state
		else
			entity.interpolation = entity.state
		end
	end
end

return InterpolationSystem