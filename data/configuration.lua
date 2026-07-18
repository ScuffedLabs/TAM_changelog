local config = {}

-- Enables debug mode
config.debug = false -- boolean. Default: false

-- Enables the version check on startup.
config.enableVersionCheck = true -- boolean. Default: true

-- Command configuration
config.command = {
    -- Enables the command.
    enabled = true, -- boolean. Default: true

    -- Restricts the command to admins only.
    restricted = false -- boolean. Default: false
}

-- Display configuration
config.display = {
    -- The title of the changelog window.
    title = "Server Changelog", -- string. Default: "Server Changelog"

    -- The subtitle of the changelog window.
    subtitle = "Updates, fixes, and improvements", -- string. Default: "Updates, fixes, and improvements"

    -- Should the changelog window appear on join?
    onJoin = true, -- boolean. Default: true

    -- The delay before the changelog window appears on join.
    joinDelay = 1500, -- number. Default: 1500

    -- Should the changelog window appear once per version?
    oncePerVersion = true, -- boolean. Default: true

    -- The category to display by default.
    defaultCategory = "All", -- string. Default: "All"

    -- Available themes: "scuffed", "neutral", "blue", "green", "orange", "rose", "violet"
    theme = "scuffed" -- string. Default: "scuffed"
}

-- Webhook configuration
config.webhook = {
    -- Enables the webhook. Be sure to set the webhook using `set scfd_changelog:webhook "<url>"` in the server.cfg
    enabled = false, -- boolean. Default: false

    -- The webhook URL.
    convar = "scfd_changelog:webhook", -- string. Default: "scfd_changelog:webhook"

    -- The username of the webhook.
    username = "Scuffed Labs Changelog", -- string. Default: "Scuffed Labs Changelog"

    -- The avatar of the webhook.
    avatar = "", -- string. Default: ""

    -- The title of the webhook.
    title = "Changelog", -- string. Default: "Changelog"

    -- The color of the webhook.
    color = 9322495, -- number. Default: 9322495

    -- The footer of the webhook.
    footer = "Scuffed Labs", -- string. Default: "Scuffed Labs"

    -- Publishes the webhook on every change.
    publishOnChange = true, -- boolean. Default: true
}

return config
