local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local function isOwner(entity)
	local owner = entity.replication.owner
	if owner then
		return owner == localPlayer
	else
		return RunService:IsServer()
	end
end

return isOwner