local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)

local BlacklistedKeycodes = {119, 97, 115, 100, 32} -- W,A,S,D,Space

local Keybind = {}
Keybind.__index = Keybind

local Keycode: Enum.KeyCode
local Activation: string

Keybind.Keycode = Keycode
Keybind.Activation = Activation

function Keybind.new()
    local self = setmetatable({}, Keybind)
    self._janitor = Janitor.new()
    return self
end

function Keybind:_setKeyCode(Keycode: Enum.KeyCode)
    
end

function Keybind:_setActivation(Activation: string)

end


function Keybind:Destroy()
    self._janitor:Destroy()
end


return Keybind