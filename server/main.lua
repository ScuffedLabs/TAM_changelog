if not LoadedResource then return end

local CONST <const> = require "shared.const"
local Changelog <const> = require "server.modules.changelog"
local Webhook <const> = require "server.modules.webhook"

local function sendToPlayer(source, force, version)
    local data = Changelog.get()
    TriggerClientEvent(CONST.EVENTS.SHOW, source, data, force == true, version)
end

RegisterNetEvent(CONST.EVENTS.REQUEST, function(force, version)
    local source = source
    if source <= 0 then return end
    sendToPlayer(source, force == true, type(version) == "string" and version or nil)
end)

RegisterCommand(CONST.COMMANDS.PUBLISH, function(source)
    if source ~= 0 and not IsPlayerAceAllowed(source, CONST.ACE.PUBLISH) then return end
    local content = LoadResourceFile(cache.resource, CONST.FILES.CHANGELOG)
    if not content or content == "" then return Logger.warn("CHANGELOG.md is empty or could not be loaded.") end
    Changelog.reload()
    TriggerClientEvent(CONST.EVENTS.RELOAD, -1)
    if Config.webhook.enabled then
        Webhook.publish(content, function(success)
            if success then SaveResourceFile(cache.resource, CONST.FILES.WEBHOOK_CACHE, content, #content) end
        end)
    end
end, false)

exports("getChangelog", function() return Changelog.get() end)
exports("getRelease", function(version) return Changelog.getRelease(version) end)
exports("getReleaseMetadata", function(version) return Changelog.getMetadata(version) end)
exports("getCategories", function() return Changelog.get().categories end)
exports("reloadChangelog", function() return Changelog.reload() end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= cache.resource then return end
    Changelog.reload()
    Webhook.publishIfChanged()
end)
