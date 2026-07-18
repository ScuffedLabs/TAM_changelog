if not LoadedResource then return end

local resourceName <const> = GetCurrentResourceName()

local CONST <const> = {
    EVENTS = {
        REQUEST = ("%s:server:request"):format(resourceName),
        SHOW = ("%s:client:show"):format(resourceName),
        RELOAD = ("%s:client:reload"):format(resourceName)
    },
    COMMANDS = { SHOW = "changelog", PUBLISH = "publishchangelog" },
    ACE = { PUBLISH = "command.publishchangelog" },
    FILES = { CHANGELOG = "CHANGELOG.md", WEBHOOK_CACHE = "data/.webhook-cache" },
    NUI = { OPEN = "changelog:open", CLOSE = "changelog:close" },
    LIMITS = {
        DISCORD_DESCRIPTION = 3900,
        RELEASES = 100,
        SECTIONS = 20,
        ENTRIES = 250,
        TEXT = 500,
        SUMMARY = 1000,
        CATEGORY = 40,
        VERSION = 40
    }
}

return CONST
