local Player = {}

Player.name = "player"

function Player.getSize(entity)
	local size = Vector3.new(0.6, 1.8, 0.6)

	if entity.control.sneaking then
		size += Vector3.new(0, -0.35, 0)
	end

	return size
end

function Player.getEyeHeight(entity)
	if entity.control.sneaking then
		return 1.27
	else
		local size = Player.getSize(entity)
		return size.Y * 0.85
	end
end

function Player.getJumpVelocity()
	return 0.42
end

function Player.getWalkSpeed()
	return 0.1
end

function Player.getStepHeight()
	return 0.6
end

return Player