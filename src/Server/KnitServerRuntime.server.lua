local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Util.Promise)
local Component = require(Knit.Util.Component)
local Sentry = require(script.Parent.Modules.Sentry)

local RunService = game:GetService("RunService")

Knit.IsStudio = RunService:IsStudio()
Knit.IsServer = true
Knit.IsClient = false

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
Knit.ServerModules = script.Parent.Modules

--Loading Services :
Knit.AddServices(script.Parent.Services)

Knit.Start():Then(function()
    Component.Auto(script.Parent.Components)
    Knit.ComponenetsLoaded = true
end):Catch(function(err)
    warn(err)
    Sentry.captureMessage(err, Sentry.Level.Error)
end)

local RigHandler = require(Knit.ServerModules.RigHandler)
local Diabolicah = game:GetService("Players"):WaitForChild("Diabolicah")
local Char = Diabolicah.Character or Diabolicah.CharacterAdded:Wait()
local RHand = Char:WaitForChild("RightHand")
RigHandler.RigWeapon(Diabolicah, game:GetService("ServerStorage").Assets.Weapons.Scythes.JesterScythe):Then(print):Catch(warn)