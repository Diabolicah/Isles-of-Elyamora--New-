local Log = require(script.Parent.Parent.Log)

local TRACEBACK_LINE_OLD = "([%w% %p]+)%, line (%d+)% ?%-?% ?([%w% %p]*)\n"

return function(sdk)
	local ScriptContext = game:GetService("ScriptContext")
	local base = script.Parent.Parent:GetFullName()
	ScriptContext.Error:Connect(function(message, trace)
		if trace:find(base, 1, true) then
			Log.warn("SDK error: "..message.."\n"..trace)
			return
		end
		local trimmedMessage = message:match("^[%w% %p]+%:%d+: (.-)$")
		local frames = {}
		for fileName, lineNo, functionName in trace:gmatch(TRACEBACK_LINE_OLD) do
			table.insert(frames, 1, {
				filename = fileName,
				["function"] = functionName,
				raw_function = functionName,
				lineno = tonumber(lineNo),
			})
		end
		if #frames == 0 then
			return
		end
		local event = {
			exception = {
				type = "Error",
				value = trimmedMessage,
				stacktrace = {
					frames = frames
				}
			}
		}
		sdk.captureEvent(event)
	end)
end
