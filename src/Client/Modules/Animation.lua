-- AnimationClass
-- Diabolica
-- September 10, 2021

--[[
    Animation.new(Animator: Animator): Animation

    Animation:LoadAnimation(AnimationPath: String): Promise
    Animation:PlayAnimation(AnimationPath: String, FadeTime: Number, Weight: Number, Speed: Number): Promise
    Animation:StopAnimation(AnimationPath: String, FadeTime: Number)


    Weapon/Scythe/Light1 = {
        AnimationTrack = track,
        MarkerList = {"Attack Hitbox Start", "Attack Hitbox End"},
        LastUsed = 123123;
    }
--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Janitor = require(Knit.Util.Janitor)
local Option = require(Knit.Util.Option)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local TableUtil = require(Knit.Util.TableUtil)

local AnimationsList = require(Knit.SharedModules.AnimationsList)

local MAX_ANIMATIONS_LOADED = 200
local PATH_NOT_VALID = "\"%s\" is not a valid path."
local ANIMATION_LOADED = "\"%s\" has/already loaded."


local Animation = {}
Animation.__index = Animation

function Animation.new(animator: Animator)
    assert(animator, "Animator was not provided.")
    local self = setmetatable({}, Animation)
    self._janitor = Janitor.new()
    self._janitor:LinkToInstance(animator)
    self._animator = animator
    self._animationTrackList = {}
    self._animationLoaded = 0
    self._keyframeMarkerReached = Signal.new(self._janitor)
    return self
end

local function _getAnimationFolder(animationPath: string)
    local values: {string} = string.split(animationPath, "/")
    local animationID = AnimationsList
    for _,v in ipairs(values) do
        animationID = animationID[v]
        if not animationID then return Option.None end
    end
    return Option.Some(animationID)
end

function Animation:_findLeastUsedAnimationPath()
    local leastUsed: number = DateTime.now().UnixTimestampMillis
    local keyName = ""
    for k,v in pairs(self._animationTrackList) do
        if v < leastUsed then
            leastUsed = v
            keyName = k
        end
    end
    return keyName
end

function Animation:_loadAnimation(animationPath: string, animationId: string, markerList: table)
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    local animationTrack = self._animator:LoadAnimation(animation)
    self._animationTrackList[animationPath] = {
        ["AnimationTrack"] = animationTrack,
        ["LastUsed"] = DateTime.now().UnixTimestampMillis,
        ["MarkerList"] = markerList,
        ["Active"] = false
    }
    self._animationLoaded = self._animationLoaded + 1
    return true
end

function Animation:_unloadAnimation(animationPath: string)
    self._animationTrackList[animationPath].AnimationTrack:Stop()
    self._animationTrackList[animationPath].AnimationTrack:Destroy()
    self._animationTrackList[animationPath] = nil
    self._animationLoaded = self._animationLoaded - 1
end

function Animation:LoadAnimation(animationPath: string): Promise
    assert(animationPath, "Animation path was not provided.")
    return self._janitor:AddPromise(Promise.new(function(resolve, reject)
        local result = _getAnimationFolder(animationPath)
        if result:IsNone() then return reject(string.format(PATH_NOT_VALID, animationPath)) end
        local animations = result:Unwrap()
        if animations.id then
            local loadedAnimationTracks = TableUtil.Keys(self._animationTrackList)
            if table.find(loadedAnimationTracks,animationPath) then return resolve(string.format(ANIMATION_LOADED, animationPath)) end
            if self._animationLoaded > MAX_ANIMATIONS_LOADED then
                local leastUsedPath = self:_findLeastUsedAnimationPath()
                self:_unloadAnimation(leastUsedPath)
            end
            self:_loadAnimation(animationPath, animations.id, TableUtil.Copy(animations.markerList))
            return resolve(string.format(ANIMATION_LOADED, animationPath))
        end
        for key,_ in pairs(animations) do
            self:LoadAnimation(animationPath.."/"..key):Catch(warn)
        end
        return resolve(string.format(ANIMATION_LOADED, animationPath))
    end))
end

function Animation:PlayAnimation(animationPath: string, fadeTime: number, weight: number, speed: number) --Need to regex

end

function Animation:StopAnimation(animationPath: string, fadeTime: number) --Need to regex

end


function Animation:Destroy()
    for path,_ in pairs(self._animationTrackList) do
        self:_unloadAnimation(path)
    end
    self._janitor:Destroy()
end


return Animation