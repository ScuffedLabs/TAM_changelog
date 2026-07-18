if not LoadedResource then return end

local CONST <const> = require "shared.const"
local Changelog = {}
local cacheData

local SECTION_NAMES <const> = {
    added = "Added", changed = "Changed", deprecated = "Deprecated",
    removed = "Removed", fixed = "Fixed", security = "Security"
}

local function clean(value, limit)
    if type(value) ~= "string" then return "" end
    value = value:gsub("[%z\1-\8\11\12\14-\31]", "")
    value = value:gsub("<", "‹"):gsub(">", "›")
    value = value:match("^%s*(.-)%s*$") or ""
    return value:sub(1, limit)
end

local function parseBoolean(value)
    value = value:lower()
    return value == "true" or value == "yes" or value == "1"
end

local function addUnique(list, seen, value)
    value = clean(value, CONST.LIMITS.CATEGORY)
    if value == "" or seen[value:lower()] then return end
    seen[value:lower()] = true
    list[#list + 1] = value
end

local function parseCategories(value, release)
    for category in value:gmatch("[^,]+") do
        addUnique(release.categories, release._categorySet, category)
    end
end

local function newRelease(version, date)
    return {
        version = clean(version, CONST.LIMITS.VERSION),
        date = clean(date or "", 64),
        title = "",
        summary = "",
        author = "",
        important = false,
        categories = {},
        sections = {},
        _categorySet = {}
    }
end

local function addEntry(release, sectionName, raw)
    if not release or not sectionName then return end
    local category, text = raw:match("^%[([^%]]+)%]%s*(.+)$")
    if not text then text = raw end
    text = clean(text, CONST.LIMITS.TEXT)
    if text == "" then return end
    category = clean(category or "General", CONST.LIMITS.CATEGORY)
    if category == "" then category = "General" end
    addUnique(release.categories, release._categorySet, category)

    local section = release.sections[#release.sections]
    if not section or section.title ~= sectionName then
        if #release.sections >= CONST.LIMITS.SECTIONS then return end
        section = { title = sectionName, entries = {} }
        release.sections[#release.sections + 1] = section
    end
    if #section.entries >= CONST.LIMITS.ENTRIES then return end
    section.entries[#section.entries + 1] = { category = category, text = text }
end

local function parse(content)
    local releases = {}
    local current
    local currentSection
    local inMetadata = false

    content = content:gsub("\r\n", "\n"):gsub("\r", "\n")

    for rawLine in (content .. "\n"):gmatch("(.-)\n") do
        local version, date = rawLine:match("^##%s+%[([^%]]+)%]%s+%-%s+(.+)$")
        if not version then
            version, date = rawLine:match("^##%s+Version%s+([^%s]+)%s+%-%s+(.+)$")
        end
        if not version then
            version, date = rawLine:match("^##%s+Version%s+([^%s]+)%s+—%s+(.+)$")
        end

        if version and #releases < CONST.LIMITS.RELEASES then
            current = newRelease(version, date)
            releases[#releases + 1] = current
            currentSection = nil
            inMetadata = false
        elseif current and rawLine:match("^<!%-%-%s*meta%s*$") then
            inMetadata = true
        elseif current and inMetadata and rawLine:match("^%s*%-%->%s*$") then
            inMetadata = false
        elseif current and inMetadata then
            local key, value = rawLine:match("^%s*([%w_]+)%s*:%s*(.-)%s*$")
            if key and value then
                key = key:lower()
                if key == "title" then current.title = clean(value, 120)
                elseif key == "summary" then current.summary = clean(value, CONST.LIMITS.SUMMARY)
                elseif key == "author" then current.author = clean(value, 80)
                elseif key == "important" then current.important = parseBoolean(value)
                elseif key == "categories" then parseCategories(value, current) end
            end
        elseif current then
            local heading = rawLine:match("^###%s+(.+)$")
            if heading then
                currentSection = SECTION_NAMES[heading:lower()]
            else
                local entry = rawLine:match("^%s*[-*]%s+(.+)$")
                if entry and currentSection then addEntry(current, currentSection, entry) end
            end
        end
    end

    for i = 1, #releases do
        local release = releases[i]
        release._categorySet = nil
        if release.title == "" then release.title = "Version " .. release.version end
    end

    return releases
end

function Changelog.reload()
    local content = LoadResourceFile(cache.resource, CONST.FILES.CHANGELOG)
    if not content or content == "" then
        cacheData = { releases = {}, categories = {} }
        return cacheData
    end

    local releases = parse(content)
    local categories, seen = { "All" }, { all = true }
    for i = 1, #releases do
        for j = 1, #releases[i].categories do
            addUnique(categories, seen, releases[i].categories[j])
        end
    end

    cacheData = {
        title = clean(Config.display.title, 100),
        subtitle = clean(Config.display.subtitle, 180),
        defaultCategory = clean(Config.display.defaultCategory, CONST.LIMITS.CATEGORY),
        theme = ({
            scuffed = true,
            neutral = true,
            blue = true,
            green = true,
            orange = true,
            rose = true,
            violet = true
        })[Config.display.theme] and Config.display.theme or "scuffed",
        releases = releases,
        categories = categories
    }
    return cacheData
end

function Changelog.get()
    return cacheData or Changelog.reload()
end

function Changelog.getRelease(version)
    if type(version) ~= "string" then return end
    local data = Changelog.get()
    for i = 1, #data.releases do
        if data.releases[i].version == version then return data.releases[i] end
    end
end

function Changelog.getMetadata(version)
    local release = Changelog.getRelease(version)
    if not release then return end
    return {
        version = release.version, date = release.date, title = release.title,
        summary = release.summary, author = release.author,
        important = release.important, categories = release.categories
    }
end

return Changelog
