-- KeybindClass
-- Diabolica
-- September 10, 2021

--[[

--]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local Promise = require(Knit.Util.Promise)

local BlacklistedKeycodes = {119, 97, 115, 100, 32} -- W,A,S,D,Space
local BlacklistedActions = {}

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(KeyCode: Enum.KeyCode, Action: string)
    local self = setmetatable({}, Keybind)
    self._janitor = Janitor.new()
    self._keyCode = KeyCode or Enum.KeyCode.Unknown
    self._action = Action or ""
    return self
end

function Keybind:_setKeyCode(KeyCode: Enum.KeyCode)
    return Promise.new(function(resolve, reject)
        if table.find(BlacklistedKeycodes, KeyCode.Value) then
            reject("Provided keybind code is blacklisted.")
        end
        self._keyCode = KeyCode
        resolve()
    end)
end

function Keybind:_setAction(Action: string)
    return Promise.new(function(resolve, reject)
        if table.find(BlacklistedActions, Action) then
            reject("Provided action is blacklisted.")
        end
        self._action = Action
        resolve()
    end)
end


function Keybind:Destroy()
    self._janitor:Destroy()
end


return Keybind