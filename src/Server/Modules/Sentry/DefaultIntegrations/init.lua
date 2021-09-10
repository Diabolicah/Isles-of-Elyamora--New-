local integrations = {}

for _, v in pairs(script:GetChildren()) do
	integrations[v.Name] = require(v)
end

return integrations
