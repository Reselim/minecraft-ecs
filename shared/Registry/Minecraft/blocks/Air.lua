local Air = {}

Air.name = "air"

function Air.getSlipperiness()
	return 0.6
end

function Air.getJumpVelocityModifier()
	return 1
end

function Air.getShape()
	return Vector3.new(0, 0, 0), Vector3.new(1, 1, 1)
end

return Air