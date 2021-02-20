local Face = {}
Face.__index = Face

function Face.new(min, max)
	return setmetatable({
		min = min,
		max = max,
	}, Face)
end

function Face:offset(offsetVector)
	return Face.new(
		self.min + offsetVector,
		self.max + offsetVector
	)
end

return Face