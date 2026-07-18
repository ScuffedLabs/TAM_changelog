if not LoadedResource then return end

local CONST <const> = require "shared.const"
local resourceVersion <const> = GetResourceMetadata(cache.resource, "version", 0) or "unknown"
local versionKvp <const> = ("%s:lastSeenVersion"):format(cache.resource)

local enabled = true
local uiOpen = false
local pendingForce = false
local pendingVersion

local function validString(value, max)
    return type(value) == "string" and #value <= max
end

local function validatePayload(data)
    if type(data) ~= "table" or type(data.releases) ~= "table" or type(data.categories) ~= "table" then return false end
    local validThemes = {
        scuffed = true,
        neutral = true,
        blue = true,
        green = true,
        orange = true,
        rose = true,
        violet = true
    }
    if not validThemes[data.theme] then return false end
    if #data.releases > CONST.LIMITS.RELEASES then return false end
    for i = 1, #data.releases do
        local release = data.releases[i]
        if type(release) ~= "table" or not validString(release.version, CONST.LIMITS.VERSION) or type(release.sections) ~= "table" then return false end
        if #release.sections > CONST.LIMITS.SECTIONS then return false end
        for j = 1, #release.sections do
            local section = release.sections[j]
            if type(section) ~= "table" or type(section.entries) ~= "table" or #section.entries > CONST.LIMITS.ENTRIES then return false end
            for k = 1, #section.entries do
                local entry = section.entries[k]
                if type(entry) ~= "table" or not validString(entry.text, CONST.LIMITS.TEXT) or not validString(entry.category, CONST.LIMITS.CATEGORY) then return false end
            end
        end
    end
    return true
end

local function requestChangelog(force, version)
    if uiOpen or (not enabled and not force) then return false end
    pendingForce = force == true
    pendingVersion = type(version) == "string" and version or nil
    TriggerServerEvent(CONST.EVENTS.REQUEST, pendingForce, pendingVersion)
    return true
end

RegisterNetEvent(CONST.EVENTS.SHOW, function(data, force, version)
    if not validatePayload(data) or (not enabled and not force) then return end
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = CONST.NUI.OPEN,
        data = {
            data = data,
            selectedVersion = type(version) == "string" and version or nil
        }
    })
end)

RegisterNetEvent(CONST.EVENTS.RELOAD, function()
    if uiOpen then
        uiOpen = false
        SetNuiFocus(false, false)
    end
    requestChangelog(true)
end)

RegisterNUICallback("close", function(_, cb)
    if uiOpen then
        uiOpen = false
        SetNuiFocus(false, false)
        SetResourceKvp(versionKvp, resourceVersion)
    end
    cb({ ok = true })
end)

if Config.command.enabled then
    RegisterCommand(CONST.COMMANDS.SHOW, function() requestChangelog(true) end, Config.command.restricted)
    TriggerEvent("chat:addSuggestion", "/" .. CONST.COMMANDS.SHOW, locale("command.show_help"))
end

exports("showChangelog", requestChangelog)

exports("showRelease", function(version)
    return requestChangelog(true, version)
end)

exports("setEnabled", function(value)
    if type(value) ~= "boolean" then return false end

    enabled = value
    return true
end)

exports("isOpen", function()
    return uiOpen
end)

exports("hasUnreadChangelog", function()
    return GetResourceKvpString(versionKvp) ~= resourceVersion
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
    if not Config.display.onJoin or not enabled then return end
    if Config.display.oncePerVersion and GetResourceKvpString(versionKvp) == resourceVersion then return end
    Wait(math.max(0, Config.display.joinDelay))
    requestChangelog(false)
end)
