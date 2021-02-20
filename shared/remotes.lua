local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.packages.Net)

local remotes = Net.Definitions.Create({
	packetEntityAdd = Net.Definitions.Event(),
	packetEntityRemove = Net.Definitions.Event(),
	packetEntityMove = Net.Definitions.Event(),
	packetEntityControl = Net.Definitions.Event(),

	functionGetEntities = Net.Definitions.AsyncFunction(),
})

return remotes