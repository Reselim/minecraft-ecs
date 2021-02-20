local function merge(...)
	local output = {}

	for index = 1, select("#", ...) do
		local source = select(index, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				output[key] = value
			end
		end
	end

	return output
end

local function clone(source)
	local output = {}

	for key, value in pairs(source) do
		output[key] = value
	end

	return output
end

local SignalConnection = {}
SignalConnection.__index = SignalConnection

function SignalConnection.new(signal, handler, options)
	return setmetatable({
		signal = signal,
		connected = true,
		_handler = handler,
		_options = options or {},
	}, SignalConnection)
end

function SignalConnection:call(...)
	if self._options.disconnectAfterCall then
		self:disconnect()
	end

	self._handler(...)
end

function SignalConnection:disconnect()
	if self.connected then
		self.connected = false
		self.signal:_disconnect(self)
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_threads = {},
		_connections = {},
	}, Signal)
end

function Signal:fire(...)
	local threads = clone(self._threads)
	local connections = clone(self._connections)

	for _, thread in ipairs(threads) do
		coroutine.resume(thread, ...)
	end

	for _, connection in ipairs(connections) do
		connection:call(...)
	end
end

function Signal:connect(handler, options)
	local connection = SignalConnection.new(self, handler, options)
	table.insert(self._connections, connection)
	return connection
end

function Signal:_disconnect(connection)
	local index = table.find(self._connections, connection)

	if index then
		table.remove(self._connections, index)
	end
end

function Signal:once(handler, options)
	return self:connect(handler, merge(options, {
		disconnectAfterCall = true,
	}))
end

function Signal:wait()
	table.insert(self._threads, coroutine.running())
	return coroutine.yield()
end

return Signal