if not LoadedResource then return end

local CONST <const> = require "shared.const"

local Webhook = {}

local function getWebhookUrl()
    if not Config.webhook.enabled then return end

    local url = GetConvar(Config.webhook.convar, "")
    if url == "" then
        Logger.warn(("Webhook is enabled, but convar '%s' is empty."):format(Config.webhook.convar))
        return
    end

    return url
end

---@param content string
---@return string[]
local function splitMarkdown(content)
    local chunks = {}
    local current = ""

    for line in (content .. "\n"):gmatch("(.-)\n") do
        local candidate = current == "" and line or (current .. "\n" .. line)

        if #candidate > CONST.LIMITS.DISCORD_DESCRIPTION and current ~= "" then
            chunks[#chunks + 1] = current
            current = line
        else
            current = candidate
        end
    end

    if current ~= "" then
        chunks[#chunks + 1] = current
    end

    return chunks
end

---@param url string
---@param chunks string[]
---@param index integer
---@param callback? fun(success: boolean)
local function publishChunk(url, chunks, index, callback)
    local payload = {
        username = Config.webhook.username,
        avatar_url = Config.webhook.avatar ~= "" and Config.webhook.avatar or nil,
        embeds = {
            {
                title = index == 1 and Config.webhook.title or nil,
                description = chunks[index],
                color = Config.webhook.color,
                footer = index == #chunks and { text = Config.webhook.footer } or nil
            }
        },
        allowed_mentions = { parse = {} }
    }

    PerformHttpRequest(url, function(statusCode, responseBody)
        if statusCode < 200 or statusCode >= 300 then
            Logger.error(("Discord webhook failed with HTTP %s: %s"):format(statusCode, responseBody or "no response"))
            if callback then callback(false) end
            return
        end

        if index < #chunks then
            publishChunk(url, chunks, index + 1, callback)
            return
        end

        Logger.info(("Published changelog to Discord in %s message(s)."):format(#chunks))
        if callback then callback(true) end
    end, "POST", json.encode(payload), {
        ["Content-Type"] = "application/json"
    })
end

---@param content string
---@param callback? fun(success: boolean)
function Webhook.publish(content, callback)
    local url = getWebhookUrl()
    if not url then
        if callback then callback(false) end
        return
    end

    local chunks = splitMarkdown(content)
    if #chunks == 0 then
        Logger.warn("Unable to publish an empty changelog.")
        if callback then callback(false) end
        return
    end

    publishChunk(url, chunks, 1, callback)
end

function Webhook.publishIfChanged()
    if not Config.webhook.enabled or not Config.webhook.publishOnChange then
        return
    end

    local content = LoadResourceFile(cache.resource, CONST.FILES.CHANGELOG)
    if not content or content == "" then
        return Logger.warn("Unable to publish an empty changelog.")
    end

    local previous = LoadResourceFile(cache.resource, CONST.FILES.WEBHOOK_CACHE)
    if previous == content then
        return Logger.debug("Changelog has not changed; skipping webhook.")
    end

    Webhook.publish(content, function(success)
        if not success then return end
        SaveResourceFile(cache.resource, CONST.FILES.WEBHOOK_CACHE, content, #content)
    end)
end

return Webhook
