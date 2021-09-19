-- RigHandler
-- Diabolica
-- September 10, 2021

--[[
    RigHandler.RigWeapon(Player: Player, Weapon: BasePart) -> Promise
--]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Util.Promise)
local Sentry = require(Knit.ServerModules.Sentry)


local RigHandler = {}

local function _settingsChecker(instance: BasePart, ...: string): boolean
    local args = {...}
    local configuration = instance:FindFirstChildWhichIsA("Configuration")
    if not configuration then return false end
    for _,v in ipairs(args) do
        if not configuration:FindFirstChild(v) then return false end
    end
    return true
end

function RigHandler.RigWeapon(player: Player, weapon: BasePart): Promise
    assert(player, "Player was not provided.")
    assert(weapon, "Weapon was not provided.")
    return Promise.new(function(resolve, reject)
       --Check if settings are correct.
        if not _settingsChecker(weapon, "DefaultC0", "DefaultC1", "DefaultPart0", "DefaultSize", "DefaultAnimationPartName") then
            local err = "Weapon given did not have the appropriate settings."
            warn(err)
            Sentry.captureMessage(err, Sentry.Level.Warning)
            return reject(err)
        end
        local character: Model = player.Character

        if not character then
            local err = "Character can not be found."
            warn(err)
            Sentry.captureMessage(err, Sentry.Level.Warning)
            return reject(err)
        end

        local part0: BasePart = character:FindFirstChild(weapon.Configuration.DefaultPart0.Value)
        if not part0 then
            local err = "Provided part0 is not a part of the player."
            warn(err)
            Sentry.captureMessage(err, Sentry.Level.Warning)
            return reject(err)
        end

        --Check if character has storage folder.
        local characterGameAssetsFolder: Folder = character:FindFirstChild("GameAssets")
        if not characterGameAssetsFolder then Instance.new("Folder", character).Name = "GameAssets" end
        characterGameAssetsFolder = character:FindFirstChild("GameAssets")
        local equipmentFolder: Folder = character.GameAssets:FindFirstChild("Equipment")
        if not equipmentFolder then Instance.new("Folder", characterGameAssetsFolder).Name = "Equipment" end
        equipmentFolder = characterGameAssetsFolder:FindFirstChild("Equipment")

        --Create a weapon copy.
        local weaponCopy: BasePart = weapon:Clone()
        weaponCopy.Name = weapon.Configuration.DefaultAnimationPartName.Value
        weaponCopy.Configuration:Destroy()
        weaponCopy.Size = weapon.Configuration.DefaultSize.Value
        weaponCopy.Parent = equipmentFolder

        --Do the rigging.
        local motor6: Motor6D = Instance.new("Motor6D")
        motor6.Name = weapon.Name
        motor6.Part0 = part0
        motor6.Part1 = weaponCopy
        motor6.C0 = weapon.Configuration.DefaultC0.Value
        motor6.C1 = weapon.Configuration.DefaultC1.Value
        motor6.Parent = weaponCopy

        return resolve("Rigged weapon \""..weapon.Name.."\" successfully.")
    end)
end

return RigHandler