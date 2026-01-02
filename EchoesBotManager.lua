-- Echoes Bot Manager Addon

-- Global variables
PlayerbotManagerDB = PlayerbotManagerDB or { buttonPos = { x = 0, y = 0 } }

-- List of classes and their command names
local classes = {
    { name = "Warrior", command = "warrior" },
    { name = "Paladin", command = "paladin" },
    { name = "Hunter", command = "hunter" },
    { name = "Rogue", command = "rogue" },
    { name = "Priest", command = "priest" },
    { name = "Shaman", command = "shaman" },
    { name = "Mage", command = "mage" },
    { name = "Warlock", command = "warlock" },
    { name = "Druid", command = "druid" },
    { name = "DK", command = "dk" }
}

-- List of formations and their command names
local formations = {
    { name = "Shield", command = "shield" },
    { name = "Chaos", command = "chaos" },
    { name = "Circle", command = "circle" },
    { name = "Line", command = "line" },
    { name = "Melee", command = "melee" },
    { name = "Near", command = "near" },
    { name = "Queue", command = "queue" },
    { name = "Arrow", command = "arrow" }
}

function PlayerbotManager_Init()
    -- Initialize the addon
    PlayerbotManagerFrame:RegisterEvent("PLAYER_LOGIN")
    -- Ensure the frame is hidden on load
    if PlayerbotManagerFrame then
        PlayerbotManagerFrame:Hide()
    end
    -- Initialize class selection
    PlayerbotManagerDB.selectedClass = PlayerbotManagerDB.selectedClass or "Druid"
    PlayerbotManagerDB.selectedClassIndex = PlayerbotManagerDB.selectedClassIndex or 9
    if SelectedClassText then
        SelectedClassText:SetText(PlayerbotManagerDB.selectedClass)
    end
    -- Initialize formation selection
    PlayerbotManagerDB.selectedFormation = PlayerbotManagerDB.selectedFormation or "Shield"
    PlayerbotManagerDB.selectedFormationIndex = PlayerbotManagerDB.selectedFormationIndex or 1
    if SelectedFormationText then
        SelectedFormationText:SetText(PlayerbotManagerDB.selectedFormation)
    end

    -- Restore minimap button position (if it exists)
    if PlayerbotManagerButtonFrame and PlayerbotManagerDB and PlayerbotManagerDB.buttonPos then
        local pos = PlayerbotManagerDB.buttonPos
        if type(pos.x) == "number" and type(pos.y) == "number" then
            PlayerbotManagerButtonFrame:ClearAllPoints()
            PlayerbotManagerButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", pos.x, pos.y)
        end
        PlayerbotManagerButtonFrame:Show()
    end
end

-- Slash command fallback (in case the minimap button is hidden by UI mods)
SLASH_ECHOESBOTMANAGER1 = "/ebm"
SLASH_ECHOESBOTMANAGER2 = "/echoesbotmanager"
SlashCmdList["ECHOESBOTMANAGER"] = function()
    PlayerbotManagerButtonFrame_OnClick()
end

function PlayerbotManagerButtonFrame_BeingDragged()
    local buttonFrame = PlayerbotManagerButtonFrame
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin - xpos / Minimap:GetEffectiveScale() + 70
    ypos = ypos / Minimap:GetEffectiveScale() - ymin - 70

    local angle = math.deg(math.atan2(ypos, xpos))
    local x, y = -80 * cos(angle), 80 * sin(angle)
    buttonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 53 - x, y - 5)
    PlayerbotManagerDB.buttonPos = { x = 53 - x, y = y - 5 }
end

function PlayerbotManagerButtonFrame_OnClick()
    if PlayerbotManagerFrame then
        if PlayerbotManagerFrame:IsVisible() then
            PlayerbotManagerFrame:Hide()
        else
            PlayerbotManagerFrame:Show()
        end
    else
        print("PlayerbotManager: Error - Control frame not found!")
    end
end

function PlayerbotManagerButtonFrame_OnEnter()
    GameTooltip:SetOwner(PlayerbotManagerButtonFrame, "ANCHOR_LEFT")
    GameTooltip:SetText("Echoes Bot Manager\nClick to open bot controls")
    GameTooltip:Show()
end

function PlayerbotManager_PrevClass()
    if not PlayerbotManagerDB.selectedClassIndex then
        PlayerbotManagerDB.selectedClassIndex = 9
    end
    PlayerbotManagerDB.selectedClassIndex = PlayerbotManagerDB.selectedClassIndex - 1
    if PlayerbotManagerDB.selectedClassIndex < 1 then
        PlayerbotManagerDB.selectedClassIndex = #classes
    end
    PlayerbotManagerDB.selectedClass = classes[PlayerbotManagerDB.selectedClassIndex].name
    if SelectedClassText then
        SelectedClassText:SetText(PlayerbotManagerDB.selectedClass)
    end
end

function PlayerbotManager_NextClass()
    if not PlayerbotManagerDB.selectedClassIndex then
        PlayerbotManagerDB.selectedClassIndex = 9
    end
    PlayerbotManagerDB.selectedClassIndex = PlayerbotManagerDB.selectedClassIndex + 1
    if PlayerbotManagerDB.selectedClassIndex > #classes then
        PlayerbotManagerDB.selectedClassIndex = 1
    end
    PlayerbotManagerDB.selectedClass = classes[PlayerbotManagerDB.selectedClassIndex].name
    if SelectedClassText then
        SelectedClassText:SetText(PlayerbotManagerDB.selectedClass)
    end
end

function PlayerbotManager_AddBot(class)
    -- Use the command field from the classes table
    for _, classInfo in ipairs(classes) do
        if classInfo.name == class then
            SendChatMessage(".playerbot bot addclass " .. classInfo.command, "SAY")
            return
        end
    end
end

function PlayerbotManager_PrevFormation()
    if not PlayerbotManagerDB.selectedFormationIndex then
        PlayerbotManagerDB.selectedFormationIndex = 1
    end
    PlayerbotManagerDB.selectedFormationIndex = PlayerbotManagerDB.selectedFormationIndex - 1
    if PlayerbotManagerDB.selectedFormationIndex < 1 then
        PlayerbotManagerDB.selectedFormationIndex = #formations
    end
    PlayerbotManagerDB.selectedFormation = formations[PlayerbotManagerDB.selectedFormationIndex].name
    if SelectedFormationText then
        SelectedFormationText:SetText(PlayerbotManagerDB.selectedFormation)
    end
end

function PlayerbotManager_NextFormation()
    if not PlayerbotManagerDB.selectedFormationIndex then
        PlayerbotManagerDB.selectedFormationIndex = 1
    end
    PlayerbotManagerDB.selectedFormationIndex = PlayerbotManagerDB.selectedFormationIndex + 1
    if PlayerbotManagerDB.selectedFormationIndex > #formations then
        PlayerbotManagerDB.selectedFormationIndex = 1
    end
    PlayerbotManagerDB.selectedFormation = formations[PlayerbotManagerDB.selectedFormationIndex].name
    if SelectedFormationText then
        SelectedFormationText:SetText(PlayerbotManagerDB.selectedFormation)
    end
end

function PlayerbotManager_SetFormation(formation)
    -- Use the command field from the formations table
    for _, formationInfo in ipairs(formations) do
        if formationInfo.name == formation then
            SendChatMessage("formation " .. formationInfo.command, "PARTY")
            return
        end
    end
end

function PlayerbotManager_SetCommand(command)
    -- Send command to party chat without /p prefix
    SendChatMessage(command, "PARTY")
end