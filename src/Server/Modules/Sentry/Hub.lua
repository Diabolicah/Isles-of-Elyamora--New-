local Scope = require(script.Parent.Scope)
local Client = require(script.Parent.Client)
local generateUUID = require(script.Parent.generateUUID)
local Parse = require(script.Parent.Parse)

local globalHub

local Hub = {}
Hub.__index = Hub

function Hub.new(client, scope)
	local self = {}
	self._client = client
	self._scopes = {scope or Scope.new()}
	self._lastEventId = nil
	setmetatable(self, Hub)
	return self
end

function Hub.setCurrent(hub)
	globalHub = hub
end

function Hub.getCurrent()
	return globalHub
end

function Hub:getTopScope()
	return self._scopes[#self._scopes]
end

function Hub:captureEvent(event, hint)
	local final = event

	final.event_id = generateUUID()

	local options = self:getClient():getOptions()
	if options.attachStacktrace and hint.sourceTrace and not final.exception then
		final.exception = Parse.exception(hint.sourceTrace)
	end

	local eventId = self:getClient():captureEvent(final, self:getTopScope())
	self._lastEventId = eventId
	return eventId
end

function Hub:captureMessage(message, level, hint)
	local final = {
		event_id = generateUUID(),
		level = level,
		message = {
			formatted = message
		}
	}

	local options = self:getClient():getOptions()
	if options.attachStacktrace and hint.sourceTrace then
		final.exception = Parse.exception(hint.sourceTrace)
	end

	local eventId = self:getClient():captureEvent(final, self:getTopScope())
	self._lastEventId = eventId
	return eventId
end

function Hub:captureException(exception, hint)
	local final = {
		event_id = generateUUID(),
		exception = Parse.exception(exception)
	}

	local options = self:getClient():getOptions()
	if options.attachStacktrace and hint.sourceTrace and not final.exception.stacktrace then
		final.exception.stacktrace = Parse.exception(hint.sourceTrace).stacktrace
	end

	local eventId = self:getClient():captureEvent(final, self:getTopScope())
	self._lastEventId = eventId
	return eventId
end

function Hub:pushScope(scope)
	scope = scope or self:getTopScope():clone()
	self._scopes[#self._scopes + 1] = scope
	return function()
		for i, v in pairs(self._scopes) do
			if v == scope then
				table.remove(self._scopes, i)
			end
		end
	end
end

function Hub:configureScope(callback)
	callback(self:getTopScope())
end

function Hub:withScope(callback)
	local scope = self:getTopScope():clone()
	local pop = self:pushScope(scope)
	callback(scope)
	pop()
end

function Hub:addBreadcrumb(crumb)
	self:getTopScope():addBreadcrumb(crumb, self:getClient():getOptions().maxBreadcrumbs)
end

function Hub:getClient()
	return self._client
end

function Hub:getLastEventId()
	return self._lastEventId
end

return Hub
