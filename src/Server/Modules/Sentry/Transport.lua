local HttpService = game:GetService("HttpService")

local Parse = require(script.Parent.Parse)
local Version = require(script.Parent.Version)
local Log = require(script.Parent.Log)

local Transport = {}
Transport.__index = Transport

function Transport.new(dsn)
	local self = {}
	self._dsn = Parse.dsn(dsn)
	self._queue = {}
	self._closed = false
	setmetatable(self, Transport)
	coroutine.wrap(function()
		while not self._closed do
			for _, callback in ipairs(self._queue) do
				callback()
			end
			self._queue = {}
			wait(1)
		end
	end)()
	return self
end

function Transport:_addToQueue(callback)
	self._queue[#self._queue + 1] = callback
end

function Transport:sendEvent(event)
	if self._closed then
		return
	end
	local dsn = self._dsn
	local baseUri = ("%s://%s"):format(dsn.protocol, dsn.host)
	local url = ("%s/api/%d/store/"):format(baseUri, dsn.projectId)
	local client = ("%s/%s"):format(Version.SDK_NAME, Version.SDK_VERSION)
	local auth = {("Sentry sentry_version=%s"):format(Version.PROTOCOL_VERSION),
		("sentry_timestamp=%d"):format(os.time()),
		("sentry_client=%s"):format(client),
		("sentry_key=%s"):format(dsn.publicKey),
		dsn.pass and ("sentry_secret=%s"):format(dsn.secretKey)
	}
	local request = {
		Url = url,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["X-Sentry-Auth"] = table.concat(auth, ",")
		},
		Body = HttpService:JSONEncode(event)
	}
	self:_addToQueue(function()
		local ok, result = pcall(function()
			return HttpService:RequestAsync(request)
		end)
		if not ok then
			Log.warn(result)
			return
		end
		if not result.Success then
			local message = ("HTTP Error %d: %s\n"):format(result.StatusCode, result.StatusMessage)
			if result.Headers["x-sentry-error"] then
				message = message .. result.Headers["x-sentry-error"]
			end
			Log.warn(message)
			if result.StatusCode == 429 then
				local retryAfter = result.Headers["Retry-After"]
				if retryAfter then
					Log.info("Retrying after "..retryAfter)
					wait(retryAfter)
				end
			end
			return
		end
		Log.info("Event sent successfully")
	end)
	Log.info("Event added to queue")
end

function Transport:close(timeout)
end

return Transport
