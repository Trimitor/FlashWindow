local FW = LibStub("AceAddon-3.0"):NewAddon("FlashWindow", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

local FlashWindow = FlashWindow;

local edef = {
    "READY_CHECK",
    "CHAT_MSG_WHISPER",
    "PARTY_INVITE_REQUEST",
    "DUEL_REQUESTED",
    "CONFIRM_BATTLEFIELD_ENTRY",
    "BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE",
    "UPDATE_BATTLEFIELD_STATUS",
    "CONFIRM_SUMMON",
    "GUILD_INVITE_REQUEST",
    "PLAYER_REGEN_DISABLED",
    "LFG_PROPOSAL_SHOW",
    "TRADE_SHOW",
    "PLAYER_DEAD",
    "RESURRECT_REQUEST",
}

local options = {
    name = "Flash Window",
    handler = FW,
    type = "group",
    args = {
        warning = {
            order = 1,
            name = "|cffff0000It looks like the client is missing the API for flashing the window. Make sure you are using the patched wow.exe",
            type = "description",
            hidden = true,
        },
        enabled = {
            order = 2,
            name = "Enable",
            desc = "Enables / disables the addon",
            type = "toggle",
            set = "toggleFW",
            get = "isToggleFW",
            hidden = false,
            disabled = false,
        },
        defaultEvents = {
            order = 3,
            width = "full",
            name = "Event List",
            desc = "Input event trigger",
            type = "input",
            multiline = 17,
            get = "getEventList",
            set = "setEventList",
            hidden = false,
        },
        resetbtn = {
            order = 4,
            name = "Reset to default",
            type = "execute",
            func = "byDefault",
            hidden = false,
        },
    },
}

local defaults = {
    profile = {
        enabled = true,
        defaultEvents = {
            
        },
    },
}

function FW:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("FWDB", defaults, true)
    self.db.profile.defaultEvents = self.db.profile.defaultEvents or edef;

    LibStub("AceConfig-3.0"):RegisterOptionsTable("FlashWindow", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FlashWindow", "FlashWindow")
end

function FW:InitEventList()
    self:UnregisterAllEvents()

    for index=1, #self.db.profile.defaultEvents do
        self:RegisterEvent(self.db.profile.defaultEvents[index], "FlashMyWindow")
    end
end

function FW:getEventList(info)
    local s = "";
    for k, v in pairs(self.db.profile.defaultEvents) do
        s = s .. v .. "\n"
    end

    return s;
end

function FW:setEventList(info, value)
    local array = {}
    for s in string.gmatch(value, "[^\n]+") do
        table.insert(array, s)
    end

    self.db.profile.defaultEvents = array
    self:InitEventList()
    DEFAULT_CHAT_FRAME:AddMessage("[FlashWindow] EventList has been updated!")
end

function FW:byDefault()
    self.db.profile.defaultEvents = edef;
    DEFAULT_CHAT_FRAME:AddMessage("[FlashWindow] EventList has been set to default!")
end

function FW:isToggleFW(info)
    if not self.db.profile.enabled then
        options.args.defaultEvents.disabled = true
    else
        options.args.defaultEvents.disabled = false
    end

    return self.db.profile.enabled
end

function FW:toggleFW(info, value)
    self.db.profile.enabled = value
end

function FW:OnEnable()
    if not FlashWindow then
        DEFAULT_CHAT_FRAME:AddMessage("[FlashWindow] Wow.exe patch not applied!")
        self.db.profile.enabled = false
        options.args.enabled.disabled = true
        options.args.warning.hidden = false
        options.args.enabled.hidden = true
        options.args.defaultEvents.hidden = true
        options.args.resetbtn.hidden = true
    else
        options.args.warning.hidden = true
        self:InitEventList()
    end
end

function FW:FlashMyWindow()
    FlashWindow()
end

function FW:OnDisable()
    self:UnregisterAllEvents()
end
