-- Chat tab click boxes: FlareUI lays secure buttons (UIParent children) over its chat tabs and
-- copies the tab bar's strata into them once, when made. Made while the Meter tab had raised
-- the chat header to MEDIUM, they stay MEDIUM at level 210 after a chat tab puts the bar back
-- to LOW, so they sit over MEDIUM windows (bank, merchant, quest) and take their clicks:
-- right-click there opened the chat tab menu. Keep them in the bar's strata. They are
-- protected, so only out of combat; leaving combat catches up.
local chat = FlareUI and FlareUI.Chat
-- FlareUI 7.0.17+ moves the boxes itself, one strata over the bar: ours would pull them back
if not chat or chat.SyncTabHits then return end

local pending = false

local function SyncHits()
    if InCombatLockdown() then
        pending = true
        return
    end
    pending = false
    for _, name in ipairs(CHAT_FRAMES or {}) do
        local frame = _G[name]
        local bar = frame and frame.FlareUI_TabBar
        if bar and bar.FlareUI_Hits then
            local strata, level = bar:GetFrameStrata(), bar:GetFrameLevel() + 10
            for _, hit in pairs(bar.FlareUI_Hits) do
                if hit:GetFrameStrata() ~= strata then hit:SetFrameStrata(strata) end
                if hit:GetFrameLevel() ~= level then hit:SetFrameLevel(level) end
            end
        end
    end
end

if chat.ApplyHeaderStrata then
    hooksecurefunc(chat, "ApplyHeaderStrata", SyncHits)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" and not pending then return end
    C_Timer.After(1, SyncHits)
end)
