-- https://docs.sentry.io/development/sdk-dev/unified-api/#static-api
local Hub = require(script.Hub)
local Client = require(script.Client)
local DefaultIntegrations = require(script.DefaultIntegrations)
local Log = require(script.Log)
local Breadcrumb = require(script.Breadcrumb)

local globalOptions
local disabled = true
local dsn = "https://8c9d12494fcf4a7aba69670df78a872b@o370934.ingest.sentry.io/5182346"

local function getDefaultOptions()
	return {
		sampleRate = 1,
		maxBreadcrumbs = 100,
		attachStacktrace = false,
		defaultIntegrations = true,
		shutdownTimeout = 2,
		debug = false
	}
end

local Sentry = {}

Sentry.Level = {
	Fatal = "fatal",
	Error = "error",
	Warning = "warning",
	Info = "info",
	Debug = "debug"
}

function Sentry.init()
	local default = getDefaultOptions()
	default["dsn"] = dsn
	globalOptions = default
	Log.setEnabled(globalOptions.debug)
	Hub.setCurrent(Hub.new(Client.new(globalOptions)))
	disabled = globalOptions.dsn == nil or globalOptions.dsn == ""
	if not disabled then
		for name, integration in pairs(DefaultIntegrations) do
			integration(Sentry)
			Log.info("Integration installed: " .. name)
		end
	end
end

function Sentry.captureEvent(event)
	if not disabled then
		local hint = {
			sourceTrace = debug.traceback("Sentry syntheticException", 2)
		}
		return Hub.getCurrent():captureEvent(event, hint)
	end
end

function Sentry.captureException(exception)
	if not disabled then
		local hint = {
			sourceTrace = debug.traceback("Sentry syntheticException", 2)
		}
		return Hub.getCurrent():captureException(exception, hint)
	end
end

function Sentry.captureMessage(message, level)
	if not disabled then
		local hint = {
			sourceTrace = debug.traceback("Sentry syntheticException", 2)
		}
		return Hub.getCurrent():captureMessage(message, level, hint)
	end
end

function Sentry.addBreadcrumb(crumb)
	if not disabled then
		return Hub.getCurrent():addBreadcrumb(Breadcrumb.new(crumb))
	end
end

function Sentry.configureScope(callback)
	if not disabled then
		return Hub.getCurrent():configureScope(callback)
	end
end

function Sentry.withScope(callback)
	if not disabled then
		return Hub.getCurrent():withScope(callback)
	end
end

function Sentry.getLastEventId()
	if not disabled then
		return Hub.getCurrent():getLastEventId()
	end
end

Sentry.init()

return Sentry
