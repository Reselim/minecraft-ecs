local Namespace = require(script.Namespace)

local INVALID_ID_ERROR = "Invalid namespaced id \"%s\""
local NIL_ID_ERROR = "Namespace id cannot be nil"
local UNKNOWN_NAMESPACE_ERROR = "Unknown namespace %s"
local UNKNOWN_BLOCK_ERROR = "Unknown block %s"
local UNKNOWN_ENTITY_ERROR = "Unknown entity %s"

local function decomposeNamespacedId(id)
	assert(id, NIL_ID_ERROR)
	local namespaceName, name = id:match("^([%w%d_-%.]+):([%w%d_-%.]+)$")
	assert(namespaceName and name, INVALID_ID_ERROR:format(id))
	return namespaceName, name
end

local Registry = {
	_namespaces = {
		minecraft = Namespace.from("minecraft", script.Minecraft),
	},
}

function Registry._getNamespace(namespaceName)
	return assert(Registry._namespaces[namespaceName], UNKNOWN_NAMESPACE_ERROR:format(namespaceName))
end

function Registry.getEntity(id)
	local namespaceName, entityName = decomposeNamespacedId(id)
	local namespace = Registry._getNamespace(namespaceName)
	return assert(namespace.entities[entityName], UNKNOWN_ENTITY_ERROR:format(entityName))
end

function Registry.getBlock(id)
	local namespaceName, blockName = decomposeNamespacedId(id)
	local namespace = Registry._getNamespace(namespaceName)
	return assert(namespace.blocks[blockName], UNKNOWN_BLOCK_ERROR:format(blockName))
end

return Registry