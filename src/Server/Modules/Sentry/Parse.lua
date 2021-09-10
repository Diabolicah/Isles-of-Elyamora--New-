local TRACEBACK_LINE_LUAU = "([%w% %p]+)%:(%d+)%s?([%w% %p]*)\n"
local DSN = "(%a+)://(%w+):?(%w*)@(.-)/(%d+)"

local Parse = {}

function Parse.dsn(dsn)
	local protocol, publicKey, secretKey, host, projectId = dsn:match(DSN)
	return {
		protocol = protocol,
		publicKey = publicKey,
		secretKey = secretKey,
		host = host,
		projectId = projectId
	}
end

function Parse.stacktrace(str)
	local frames = {}
	for fileName, lineNo, functionName in str:gmatch(TRACEBACK_LINE_LUAU) do
		table.insert(frames, 1, {
			filename = fileName,
			["function"] = functionName,
			raw_function = functionName,
			lineno = tonumber(lineNo),
		})
	end
	return frames
end

function Parse.exception(str)
	local messageEnd = str:find(TRACEBACK_LINE_LUAU)
	if not messageEnd then
		return {
			type = "Error",
			value = str
		}
	else
		local message = messageEnd > 1 and str:sub(1, messageEnd - 1)
		if message then
			message = message:match("^(.-)%s*$")
		end
		local stackString = str:sub(messageEnd)
		local frames = Parse.stacktrace(stackString)
		local stacktrace
		if #frames > 0 then
			stacktrace = {
				frames = frames
			}
		end
		if message or stacktrace then
			return {
				type = "Error",
				value = message,
				stacktrace = stacktrace
			}
		else
			return {
				type = "Error",
				value = str
			}
		end
	end
end

return Parse
