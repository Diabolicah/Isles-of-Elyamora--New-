local Players = game:GetService("Players")
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

local lplayer = Players.LocalPlayer
local char = lplayer.Character or lplayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")
local Animation = require(Knit.ClientModules.Animation)
local tempAnimation = Animation.new(animator)
tempAnimation:LoadAnimation("Weapon/Scythe"):Then(print):Catch(warn)
wait(5)
local function tempFunction(arg)
    return tempAnimation:PlayAnimation(arg)
end
tempAnimation:PlayAnimation("Weapon/Scythe/Light1"):Then(print):ThenCall(tempFunction, "Weapon/Scythe/Light2"):ThenCall(tempFunction, "Weapon/Scythe/Light3"):ThenCall(tempFunction, "Weapon/Scythe/Heavy"):ThenCall(tempFunction, "Weapon/Scythe/Block")
tempAnimation._keyframeMarkerReached:Connect(function(p, t ,h) print(p,t,h)end)