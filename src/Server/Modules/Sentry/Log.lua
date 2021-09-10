local enabled = false

local Log = {}

function Log.setEnabled(bool)
	enabled = bool
end

function Log.info(message)
	if enabled then
		print("Sentry Info: "..message)
	end
end

function Log.warn(message)
	if enabled then
		warn("Sentry Warn: "..message)
	end
end

function Log.error(message)
	if enabled then
		coroutine.wrap(function()
			error("Sentry Error: "..message, 2)
		end)()
	end
end

return Log
