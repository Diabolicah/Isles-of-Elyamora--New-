local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(Knit.Util.Component)

local RunService = game:GetService("RunService")

Knit.IsStudio = RunService:IsStudio()
Knit.IsServer = false
Knit.IsClient = true

function Knit.OnComponentsLoaded()
    if (Knit.ComponentsLoaded) then
        return Promise.resolve()
    end
    return Promise.new(function(resolve)
        local heartbeat
        heartbeat = game:GetService("RunService").PostSimulation:Connect(function()
            if (Knit.ComponentsLoaded) then
                heartbeat:Disconnect()
                resolve()
            end
        end)
    end)
end

-- Loading Modules :
Knit.SharedModules = game:GetService("ReplicatedStorage").Game.SharedModules
Knit.ClientModules = script.Parent.Modules

--Loading Services :
Knit.AddControllers(script.Parent.Controllers)

Knit.Start():Then(function()
    Component.Auto(script.Parent.Components)
    Knit.ComponenetsLoaded = true
end):Catch(warn)