local HttpService = game:GetService("HttpService")

local function generateUUID()
	return HttpService:GenerateGUID(false):gsub("-", "")
end

return generateUUID
