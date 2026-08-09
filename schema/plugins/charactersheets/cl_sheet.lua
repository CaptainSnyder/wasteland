local skillLevelCost = PLUGIN.skillLevelCost
local FormatTraitModifiers = PLUGIN.FormatTraitModifiers

local traitDefsByID = {}

for _, trait in ipairs(PLUGIN.traits) do
    traitDefsByID[trait.id] = trait
end

surface.CreateFont("ixCharQuoteFont", {
    font = "Roboto",
    size = 18,
    weight = 400,
    italic = true
})

local function BuildImageHTML(url)
    if (!url or url == "") then
        return "<html><body style='margin:0;background:#000;'></body></html>"
    end

    return string.format([[<html><body style="margin:0;padding:0;background:#000;">
        <img src="%s" style="width:100%%;height:100%%;object-fit:cover;">
    </body></html>]], url)
end

-- relationship value -> color gradient checkpoints (bold, saturated colors for clear contrast)
local RELATIONSHIP_BREAKPOINTS = {
    {value = 1, color = Color(230, 30, 30)},
    {value = 25, color = Color(235, 110, 20)},
    {value = 50, color = Color(150, 150, 150)},
    {value = 75, color = Color(40, 190, 60)},
    {value = 100, color = Color(40, 110, 230)}
}

local function GetRelationshipColor(value)
    value = math.Clamp(value or 50, 1, 100)

    for i = 1, #RELATIONSHIP_BREAKPOINTS - 1 do
        local a = RELATIONSHIP_BREAKPOINTS[i]
        local b = RELATIONSHIP_BREAKPOINTS[i + 1]

        if (value >= a.value and value <= b.value) then
            local frac = (value - a.value) / (b.value - a.value)
            -- eased so the color shifts noticeably even a short way past a checkpoint, instead of staying subtle
            frac = frac ^ 0.6

            return Color(
                Lerp(frac, a.color.r, b.color.r),
                Lerp(frac, a.color.g, b.color.g),
                Lerp(frac, a.color.b, b.color.b)
            )
        end
    end

    return RELATIONSHIP_BREAKPOINTS[#RELATIONSHIP_BREAKPOINTS].color
end

-- small popup used for both adding a new relationship entry and editing an existing one
local function OpenRelationshipEditor(existing, onSave)
    local popup = vgui.Create("DFrame")
    popup:SetSize(320, 270)
    popup:Center()
    popup:SetTitle(existing and "Edit Relationship" or "Add Relationship")
    popup:MakePopup()

    local nameEntry = popup:Add("DTextEntry")
    nameEntry:SetPos(10, 30)
    nameEntry:SetSize(300, 25)
    nameEntry:SetPlaceholderText("Name")

    if (existing) then
        nameEntry:SetText(existing.name)

        if (existing.id == "myself") then
            nameEntry:SetEditable(false)
        end
    end

    local thoughtsEntry = popup:Add("DTextEntry")
    thoughtsEntry:SetPos(10, 65)
    thoughtsEntry:SetSize(300, 100)
    thoughtsEntry:SetMultiline(true)
    thoughtsEntry:SetPlaceholderText("My current thoughts...")

    if (existing) then
        thoughtsEntry:SetText(existing.thoughts)
    end

    local valueSlider = popup:Add("DNumSlider")
    valueSlider:SetPos(10, 175)
    valueSlider:SetSize(300, 30)
    valueSlider:SetText("Value")
    valueSlider:SetMin(1)
    valueSlider:SetMax(100)
    valueSlider:SetDecimals(0)
    valueSlider:SetValue(existing and existing.value or 50)

    local saveButton = popup:Add("DButton")
    saveButton:SetPos(10, 220)
    saveButton:SetSize(300, 30)
    saveButton:SetText("Save")

    saveButton.DoClick = function()
        local payload = {
            name = string.Trim(nameEntry:GetValue()),
            thoughts = thoughtsEntry:GetValue(),
            value = math.Round(valueSlider:GetValue())
        }

        if (existing) then
            payload.id = existing.id
        end

        onSave(payload)
        popup:Close()
    end
end

local function BuildRelationshipsPage(parent, data)
    if (data.isOwner) then
        local addButton = parent:Add("DButton")
        addButton:SetText("Add entry")
        addButton:Dock(TOP)
        addButton:SetTall(25)
        addButton:DockMargin(10, 10, 45, 5)

        addButton.DoClick = function()
            OpenRelationshipEditor(nil, function(payload)
                net.Start("ixCharSheetAddRelationship")
                    net.WriteTable(payload)
                net.SendToServer()
            end)
        end
    end

    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 45, 10)

    -- sorted most-liked to most-hated, highest value first
    local sortedRelationships = {}

    for _, entry in ipairs(data.relationships or {}) do
        sortedRelationships[#sortedRelationships + 1] = entry
    end

    table.SortByMember(sortedRelationships, "value", false)

    for _, entry in ipairs(sortedRelationships) do
        local row = scroll:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(24)
        row:DockMargin(0, 0, 0, 2)
        row.Paint = function() end

        local nameButton = row:Add("DButton")
        nameButton:SetText(entry.name .. " (" .. entry.value .. ")")
        nameButton:SetFont("DermaDefaultBold")
        nameButton:SetTextColor(GetRelationshipColor(entry.value))
        nameButton:Dock(FILL)
        nameButton:SetContentAlignment(4)
        nameButton:SetTextInset(8, 0)

        if (data.isOwner) then
            nameButton.DoClick = function()
                OpenRelationshipEditor(entry, function(payload)
                    net.Start("ixCharSheetEditRelationship")
                        net.WriteTable(payload)
                    net.SendToServer()
                end)
            end

            if (entry.id != "myself") then
                local deleteButton = row:Add("DButton")
                deleteButton:SetText("X")
                deleteButton:Dock(RIGHT)
                deleteButton:SetWide(24)

                deleteButton.DoClick = function()
                    net.Start("ixCharSheetDeleteRelationship")
                        net.WriteString(entry.id)
                    net.SendToServer()
                end
            end
        end
    end
end

-- the four ways a roll can be made. "Standard Roll" sends no mode at all, leaving the server to work
-- out advantage/disadvantage from traits and conditions exactly as it always has; the three Guaranteed
-- options override that entirely for the one roll and get called out by name in chat
local ROLL_MODE_OPTIONS = {
    {
        label = "Standard Roll",
        tooltip = "Uses whatever advantage or disadvantage your traits and conditions give you."
    },
    {
        label = "Guaranteed Advantage",
        mode = "advantage",
        tooltip = "Roll twice and take the higher, no matter what your traits or conditions say."
    },
    {
        label = "Guaranteed Neutral",
        mode = "neutral",
        tooltip = "Roll a single die, ignoring any advantage or disadvantage you would normally have."
    },
    {
        label = "Guaranteed Disadvantage",
        mode = "disadvantage",
        tooltip = "Roll twice and take the lower, no matter what your traits or conditions say."
    }
}

local function PromptRoll(commandName, subjectName)
    local popup = vgui.Create("DFrame")
    popup:SetSize(300, 220)
    popup:Center()
    popup:SetTitle("Roll " .. subjectName)
    popup:MakePopup()

    local label = popup:Add("DLabel")
    label:SetPos(10, 32)
    label:SetSize(280, 18)
    label:SetText("Modifier (optional, e.g. 3 or -2):")

    local modifierEntry = popup:Add("DTextEntry")
    modifierEntry:SetPos(10, 52)
    modifierEntry:SetSize(280, 24)
    -- deliberately not SetNumeric(true) - that blocks the minus sign, so negative modifiers
    -- couldn't be typed at all
    modifierEntry:RequestFocus()

    local function SendRoll(mode)
        -- always send an explicit number rather than omitting it. Helix collapses a nil optional
        -- argument out of the argument list instead of leaving a gap (sh_command.lua's
        -- `result[#result + 1] = value`), so skipping the modifier would slide the mode into its slot
        local modifier = tonumber(string.Trim(modifierEntry:GetValue())) or 0

        if (mode) then
            ix.command.Send(commandName, subjectName, modifier, mode)
        else
            ix.command.Send(commandName, subjectName, modifier)
        end

        popup:Close()
    end

    local y = 86

    for _, option in ipairs(ROLL_MODE_OPTIONS) do
        local button = popup:Add("DButton")
        button:SetPos(10, y)
        button:SetSize(280, 26)
        button:SetText(option.label)
        button:SetTooltip(option.tooltip)

        button.DoClick = function()
            SendRoll(option.mode)
        end

        y = y + 30
    end

    -- enter still rolls straight away, matching how the old single-field prompt behaved
    modifierEntry.OnEnter = function()
        SendRoll(nil)
    end
end

local INFO_FIELDS = {
    {key = "height", label = "Height", width = 80},
    {key = "weight", label = "Weight", width = 80},
    {key = "sex", label = "Sex", width = 80},
    {key = "age", label = "Age", width = 80},
    {key = "reputation", label = "Reputation", width = 150},
    {key = "faction", label = "Faction", width = 150},
    {key = "alignment", label = "Alignment", width = 150}
}

local function BuildCharacterPage(parent, data)
    -- top row: picture on the left, detailed description filling the rest
    local topRow = parent:Add("DPanel")
    topRow:Dock(TOP)
    topRow:SetTall(180)
    topRow:DockMargin(10, 10, 45, 10)
    topRow.Paint = function() end

    local picSize = 180
    local picBox = vgui.Create("DHTML", topRow)
    picBox:Dock(LEFT)
    picBox:SetWide(picSize)
    picBox:SetHTML(BuildImageHTML(data.picURL))

    local descBox
    local isEditingBio = false

    descBox = topRow:Add("DTextEntry")
    descBox:SetMultiline(true)
    descBox:SetEditable(false)
    descBox:SetText(data.bio)
    descBox:Dock(FILL)
    descBox:DockMargin(10, 0, 0, 0)

    -- stat row: attributes on the left, info fields filling the rest
    local statRow = parent:Add("DPanel")
    statRow:Dock(TOP)
    statRow:SetTall(160)
    statRow:DockMargin(10, 0, 45, 10)
    statRow.Paint = function() end

    local attribList = statRow:Add("DPanel")
    attribList:Dock(LEFT)
    attribList:SetWide(260)
    attribList.Paint = function() end

    local sortedAttribs = {}

    for _, info in pairs(data.attributes) do
        sortedAttribs[#sortedAttribs + 1] = info
    end

    table.SortByMember(sortedAttribs, "name", true)

    for _, info in ipairs(sortedAttribs) do
        local button = attribList:Add("DButton")
        button:SetText(info.name .. ": " .. info.value)
        button:SetFont("DermaDefaultBold")
        button:Dock(TOP)
        button:SetTall(20)
        button:DockMargin(0, 0, 0, 2)

        button.DoClick = function()
            PromptRoll("RollAttribute", info.name)
        end
    end

    -- small info fields: Height, Weight, Sex, Age, Reputation, Faction, Alignment
    local infoPanel = statRow:Add("DPanel")
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(10, 0, 0, 0)
    infoPanel.Paint = function() end

    local infoEntries = {}
    local existingInfo = data.info or {}

    for _, fieldDef in ipairs(INFO_FIELDS) do
        local row = infoPanel:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(20)
        row:DockMargin(0, 0, 0, 2)
        row.Paint = function() end

        local label = row:Add("DLabel")
        label:SetText(fieldDef.label .. ":")
        label:SetFont("DermaDefaultBold")
        label:SetWide(80)
        label:Dock(LEFT)
        label:SetContentAlignment(4)

        local entry = row:Add("DTextEntry")
        entry:SetText(existingInfo[fieldDef.key] or "")
        entry:SetEditable(false)
        entry:Dock(LEFT)
        entry:SetWide(fieldDef.width)

        infoEntries[fieldDef.key] = entry
    end

    local isEditingInfo = false

    if (data.isOwner) then
        local infoEditButton = parent:Add("DButton")
        infoEditButton:SetText("Edit info")
        infoEditButton:Dock(TOP)
        infoEditButton:SetTall(22)
        infoEditButton:DockMargin(10, 0, 45, 10)

        infoEditButton.DoClick = function(self)
            if (isEditingInfo) then
                local payload = {}

                for key, entry in pairs(infoEntries) do
                    payload[key] = entry:GetValue()
                    entry:SetEditable(false)
                end

                net.Start("ixCharSheetSetInfo")
                    net.WriteTable(payload)
                net.SendToServer()

                self:SetText("Edit info")
            else
                for _, entry in pairs(infoEntries) do
                    entry:SetEditable(true)
                end

                self:SetText("Save info")
            end

            isEditingInfo = !isEditingInfo
        end

        local controls = parent:Add("DPanel")
        controls:Dock(TOP)
        controls:SetTall(60)
        controls:DockMargin(10, 0, 45, 10)
        controls.Paint = function() end

        local editButton = controls:Add("DButton")
        editButton:SetText("Edit detailed description")
        editButton:Dock(TOP)
        editButton:SetTall(25)
        editButton:DockMargin(0, 0, 0, 5)

        editButton.DoClick = function(self)
            if (isEditingBio) then
                local text = descBox:GetValue()

                net.Start("ixCharSheetSetBio")
                    net.WriteString(text)
                net.SendToServer()

                descBox:SetEditable(false)
                self:SetText("Edit detailed description")
            else
                descBox:SetEditable(true)
                descBox:RequestFocus()
                self:SetText("Save detailed description")
            end

            isEditingBio = !isEditingBio
        end

        local picRow = controls:Add("DPanel")
        picRow:Dock(TOP)
        picRow:SetTall(25)
        picRow.Paint = function() end

        local picButton = picRow:Add("DButton")
        picButton:SetText("Set image")
        picButton:Dock(RIGHT)
        picButton:SetWide(80)

        local picEntry = picRow:Add("DTextEntry")
        picEntry:Dock(FILL)
        picEntry:SetPlaceholderText("Imgur direct image link (i.imgur.com/xxxx.png)")
        picEntry:SetText(data.picURL or "")
        picEntry:DockMargin(0, 0, 5, 0)

        picButton.DoClick = function()
            local url = string.Trim(picEntry:GetValue())

            net.Start("ixCharSheetSetPic")
                net.WriteString(url)
            net.SendToServer()

            picBox:SetHTML(BuildImageHTML(url))
        end
    end
end

local function BuildSkillsPage(parent, data)
    if (data.isOwner) then
        local poolLabel = parent:Add("DLabel")
        poolLabel:SetText("Skill points remaining: " .. (data.skillPoints or 0))
        poolLabel:SetFont("DermaDefaultBold")
        poolLabel:SetTextColor(Color(217, 179, 92))
        poolLabel:Dock(TOP)
        poolLabel:SetTall(22)
        poolLabel:DockMargin(10, 10, 10, 0)
    end

    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 45, 10)

    for _, category in ipairs(data.skillCategories) do
        local header = scroll:Add("DLabel")
        header:SetText(category.name)
        header:SetFont("DermaDefaultBold")
        header:SetTextColor(Color(217, 179, 92))
        header:Dock(TOP)
        header:SetTall(22)
        header:DockMargin(0, 10, 0, 2)

        for _, skill in ipairs(category.skills) do
            local row = scroll:Add("DPanel")
            row:Dock(TOP)
            row:SetTall(22)
            row:DockMargin(0, 0, 0, 2)
            row.Paint = function() end

            local button = row:Add("DButton")
            -- the bracketed modifier carries its own sign, so a negative one reads "[-1]" instead of
            -- the "[+-1]" a hardcoded "+" produces. the attribute brackets stay unsigned - those are
            -- raw values rather than bonuses, so "[-1]" and "[1]" already read correctly
            button:SetText(string.format("%s = %d [%s%d] (%s[%d] + %s[%d])",
                skill.name, skill.points,
                skill.modifier >= 0 and "+" or "-", math.abs(skill.modifier),
                skill.attribOne.name, skill.attribOne.value,
                skill.attribTwo.name, skill.attribTwo.value
            ))
            button:SetContentAlignment(4)
            button:SetTextInset(8, 0)
            button:Dock(FILL)

            button.DoClick = function()
                PromptRoll("RollSkill", skill.name)
            end

            if (data.isOwner) then
                local spendButton = row:Add("DButton")
                spendButton:Dock(RIGHT)
                spendButton:SetWide(55)
                spendButton:DockMargin(2, 0, 0, 0)

                if (skill.points >= 10) then
                    spendButton:SetText("MAX")
                    spendButton:SetEnabled(false)
                else
                    local cost = skillLevelCost[skill.points + 1]
                    spendButton:SetText(string.format("+1 (%d)", cost))

                    spendButton.DoClick = function()
                        net.Start("ixCharSheetSpendSkill")
                            net.WriteString(skill.id)
                        net.SendToServer()
                    end
                end
            end
        end
    end
end

local TRAIT_TIER_INFO = {
    [1] = {label = "Tier 1", color = Color(180, 180, 180)},
    [2] = {label = "Tier 2", color = Color(217, 179, 92)},
    [3] = {label = "Tier 3", color = Color(190, 90, 200)}
}

local function BuildTraitsPage(parent, data)
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 45, 10)

    if (#(data.traits or {}) == 0) then
        local emptyLabel = scroll:Add("DLabel")
        emptyLabel:SetText("No traits.")
        emptyLabel:Dock(TOP)
        emptyLabel:SetTall(20)
    end

    -- sorted by tier first, then alphabetically within each tier
    local sortedTraits = {}

    for _, trait in ipairs(data.traits or {}) do
        sortedTraits[#sortedTraits + 1] = trait
    end

    table.sort(sortedTraits, function(a, b)
        local tierA, tierB = a.tier or 1, b.tier or 1

        if (tierA != tierB) then
            return tierA < tierB
        end

        return a.name < b.name
    end)

    for _, trait in ipairs(sortedTraits) do
        local tierInfo = TRAIT_TIER_INFO[trait.tier or 1]

        local box = scroll:Add("DPanel")
        box:Dock(TOP)
        box:DockMargin(0, 0, 0, 5)
        box.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
        end

        local titleRow = box:Add("DPanel")
        titleRow:Dock(TOP)
        titleRow:SetTall(20)
        titleRow:DockMargin(8, 4, 8, 0)
        titleRow.Paint = function() end

        local nameLabel = titleRow:Add("DLabel")
        nameLabel:SetText(trait.name)
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetTextColor(Color(217, 179, 92))
        nameLabel:Dock(FILL)

        local tierLabel = titleRow:Add("DLabel")
        tierLabel:SetText(tierInfo.label)
        tierLabel:SetFont("DermaDefaultBold")
        tierLabel:SetTextColor(tierInfo.color)
        tierLabel:Dock(RIGHT)
        tierLabel:SetWide(45)
        tierLabel:SetContentAlignment(6)

        local fullTraitDef = traitDefsByID[trait.id]
        local effectText = fullTraitDef and FormatTraitModifiers(fullTraitDef) or ""

        if (effectText == "") then
            effectText = "This is a roleplay trait!"
        end

        local fullText = trait.description .. "\n\nEffect: " .. effectText

        local descLabel = box:Add("DLabel")
        descLabel:SetText(fullText)
        descLabel:SetWrap(true)
        descLabel:SetAutoStretchVertical(true)
        descLabel:Dock(TOP)
        descLabel:DockMargin(8, 0, 8, 4)

        -- recalculated every layout pass so it always matches the label's real wrapped height
        box.PerformLayout = function(self, w, h)
            self:SetTall(24 + descLabel:GetTall() + 8)
        end
    end
end

local function FormatConditionDuration(seconds)
    if (seconds == nil or seconds <= 0) then
        return "expiring"
    end

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)

    if (hours > 0) then
        return string.format("%dh %dm remaining", hours, minutes)
    end

    return string.format("%dm remaining", minutes)
end

-- shared card renderer used by both the Conditions tab (full list) and the Health tab's "General" list
local function AddConditionCard(scroll, cond)
    local box = scroll:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, 0, 0, 5)
    box.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
    end

    local titleRow = box:Add("DPanel")
    titleRow:Dock(TOP)
    titleRow:SetTall(20)
    titleRow:DockMargin(8, 4, 8, 0)
    titleRow.Paint = function() end

    local nameLabel = titleRow:Add("DLabel")
    nameLabel:SetText(cond.name)
    nameLabel:SetFont("DermaDefaultBold")
    nameLabel:SetTextColor(Color(217, 179, 92))
    nameLabel:Dock(FILL)

    local timeLabel = titleRow:Add("DLabel")
    timeLabel:SetText(FormatConditionDuration(cond.remainingSeconds))
    timeLabel:SetFont("DermaDefaultBold")
    timeLabel:SetTextColor(Color(180, 180, 180))
    timeLabel:Dock(RIGHT)
    timeLabel:SetWide(120)
    timeLabel:SetContentAlignment(6)

    local descLabel = box:Add("DLabel")
    descLabel:SetText(cond.description)
    descLabel:SetWrap(true)
    descLabel:SetAutoStretchVertical(true)
    descLabel:Dock(TOP)
    descLabel:DockMargin(8, 0, 8, 4)

    -- separate label (not appended into descLabel) since a single DLabel with embedded paragraph
    -- breaks unreliably undercounts its own height and clips - see the charsetup intro page fix
    local effectText = FormatTraitModifiers(cond)

    if (effectText == "") then
        effectText = "This has no mechanical effect."
    end

    local effectLabel = box:Add("DLabel")
    effectLabel:SetText("Effect: " .. effectText)
    effectLabel:SetWrap(true)
    effectLabel:SetAutoStretchVertical(true)
    effectLabel:SetTextColor(Color(150, 190, 150))
    effectLabel:Dock(TOP)
    effectLabel:DockMargin(8, 0, 8, 4)

    box.PerformLayout = function(self, w, h)
        self:SetTall(24 + descLabel:GetTall() + effectLabel:GetTall() + 8)
    end
end

-- "Other Conditions" covers non-physical effects (drug highs, withdrawal, etc) - anything tagged
-- category == "health" belongs on the Health tab instead (see BuildHealthPage below)
local function BuildConditionsPage(parent, data)
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 45, 10)

    local otherConditions = {}

    for _, cond in ipairs(data.conditions or {}) do
        if (cond.category == "other") then
            otherConditions[#otherConditions + 1] = cond
        end
    end

    if (#otherConditions == 0) then
        local emptyLabel = scroll:Add("DLabel")
        emptyLabel:SetText("No active conditions.")
        emptyLabel:Dock(TOP)
        emptyLabel:SetTall(20)
    end

    for _, cond in ipairs(otherConditions) do
        AddConditionCard(scroll, cond)
    end
end

-- left side: clickable body diagram; right side: an HP gradient bar plus a full text list of every
-- active health condition (region-specific ones included, not just the region-less "general" ones -
-- the diagram only shows color, this list is where you actually read what's wrong)
local function BuildHealthPage(parent, data)
    local diagram = vgui.Create("ixBodyDiagram", parent)
    diagram:Dock(LEFT)
    diagram:SetWide(220)
    diagram:DockMargin(10, 10, 10, 10)
    diagram:SetConditions(data.conditions, data.isOwner)

    local barContainer = parent:Add("DPanel")
    barContainer:Dock(LEFT)
    barContainer:SetWide(40)
    barContainer:DockMargin(0, 10, 10, 10)
    barContainer.Paint = function() end

    local maxHealth = (data.maxHealth and data.maxHealth > 0) and data.maxHealth or 100
    local fraction = math.Clamp((data.health or 0) / maxHealth, 0, 1)

    local bar = barContainer:Add("DPanel")
    bar:Dock(TOP)
    bar:SetTall(180)
    bar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(10, 10, 10))

        local fillHeight = h * fraction
        surface.SetDrawColor(230, 230, 230)
        surface.DrawRect(0, h - fillHeight, w, fillHeight)
    end

    local hpLabel = barContainer:Add("DLabel")
    hpLabel:SetText(string.format("%d/%d", data.health or 0, maxHealth))
    hpLabel:SetFont("DermaDefaultBold")
    hpLabel:SetTextColor(Color(217, 179, 92))
    hpLabel:SetContentAlignment(5)
    hpLabel:Dock(TOP)
    hpLabel:SetTall(20)
    hpLabel:DockMargin(0, 5, 0, 0)

    local healthScroll = vgui.Create("DScrollPanel", parent)
    healthScroll:Dock(FILL)
    healthScroll:DockMargin(0, 10, 45, 10)

    local healthTitle = healthScroll:Add("DLabel")
    healthTitle:SetText("List of Current Health Conditions")
    healthTitle:SetFont("DermaDefaultBold")
    healthTitle:SetTextColor(Color(217, 179, 92))
    healthTitle:Dock(TOP)
    healthTitle:SetTall(20)

    local healthConditions = {}

    for _, cond in ipairs(data.conditions or {}) do
        if (cond.category == "health") then
            healthConditions[#healthConditions + 1] = cond
        end
    end

    if (#healthConditions == 0) then
        local emptyLabel = healthScroll:Add("DLabel")
        emptyLabel:SetText("No active health conditions.")
        emptyLabel:Dock(TOP)
        emptyLabel:SetTall(20)
    end

    for _, cond in ipairs(healthConditions) do
        AddConditionCard(healthScroll, cond)
    end
end

local function BuildBiographyPage(parent, data)
    local bioBox
    local isEditing = false

    if (data.isOwner) then
        local controls = parent:Add("DPanel")
        controls:Dock(BOTTOM)
        controls:SetTall(30)
        controls:DockMargin(10, 0, 10, 10)
        controls.Paint = function() end

        local editButton = controls:Add("DButton")
        editButton:SetText("Edit biography")
        editButton:Dock(FILL)

        editButton.DoClick = function(self)
            if (isEditing) then
                local text = bioBox:GetValue()

                net.Start("ixCharSheetSetBiography")
                    net.WriteString(text)
                net.SendToServer()

                bioBox:SetEditable(false)
                self:SetText("Edit biography")
            else
                bioBox:SetEditable(true)
                bioBox:RequestFocus()
                self:SetText("Save biography")
            end

            isEditing = !isEditing
        end
    end

    bioBox = parent:Add("DTextEntry")
    bioBox:SetMultiline(true)
    bioBox:SetEditable(false)
    bioBox:SetText(data.biography or "")
    bioBox:Dock(FILL)
    bioBox:DockMargin(10, 10, 10, 10)
end

local function BuildNotesPage(parent, data)
    local notesBox
    local isEditing = false

    local controls = parent:Add("DPanel")
    controls:Dock(BOTTOM)
    controls:SetTall(30)
    controls:DockMargin(10, 0, 10, 10)
    controls.Paint = function() end

    local editButton = controls:Add("DButton")
    editButton:SetText("Edit notes")
    editButton:Dock(FILL)

    editButton.DoClick = function(self)
        if (isEditing) then
            local text = notesBox:GetValue()

            net.Start("ixCharSheetSetNotes")
                net.WriteString(text)
            net.SendToServer()

            notesBox:SetEditable(false)
            self:SetText("Edit notes")
        else
            notesBox:SetEditable(true)
            notesBox:RequestFocus()
            self:SetText("Save notes")
        end

        isEditing = !isEditing
    end

    notesBox = parent:Add("DTextEntry")
    notesBox:SetMultiline(true)
    notesBox:SetEditable(false)
    notesBox:SetText(data.privateNotes or "")
    notesBox:Dock(FILL)
    notesBox:DockMargin(10, 10, 10, 0)
end

local lastActiveTab = "character"

local function OpenCharacterSheet(length)
    local data = net.ReadTable()

    if (!data) then
        return
    end

    if (IsValid(ix.gui.characterSheet)) then
        ix.gui.characterSheet:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(650, 600)
    frame:SetSizable(true)
    frame:SetMinWidth(500)
    frame:SetMinHeight(560)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    ix.gui.characterSheet = frame

    local nameLabel = frame:Add("DLabel")
    nameLabel:SetText(data.name)
    nameLabel:SetFont("DermaLarge")
    nameLabel:SetTextColor(Color(217, 179, 92))
    nameLabel:Dock(TOP)
    nameLabel:DockMargin(10, 10, 10, 0)
    nameLabel:SetContentAlignment(5)

    local quoteRow = frame:Add("DPanel")
    quoteRow:Dock(TOP)
    quoteRow:SetTall(52)
    quoteRow:DockMargin(10, 2, 10, 5)
    quoteRow.Paint = function() end

    local quoteLabel = quoteRow:Add("DLabel")
    quoteLabel:SetFont("ixCharQuoteFont")
    quoteLabel:SetTextColor(Color(217, 179, 92))
    quoteLabel:SetContentAlignment(5)
    quoteLabel:Dock(TOP)
    quoteLabel:SetTall(24)

    local function UpdateQuoteLabel(text)
        if (text and text != "") then
            quoteLabel:SetText("\"" .. text .. "\"")
        else
            quoteLabel:SetText("")
        end
    end

    UpdateQuoteLabel(data.quote)

    if (data.isOwner) then
        local quoteButton = quoteRow:Add("DButton")
        quoteButton:SetText("Change quote")
        quoteButton:SetSize(100, 20)

        quoteRow.PerformLayout = function(self, w, h)
            quoteButton:SetPos((w - quoteButton:GetWide()) / 2, 26)
        end

        quoteButton.DoClick = function()
            Derma_StringRequest(
                "Change Quote",
                "Enter a new quote for your character:",
                data.quote or "",
                function(text)
                    text = string.Trim(text)

                    net.Start("ixCharSheetSetQuote")
                        net.WriteString(text)
                    net.SendToServer()

                    data.quote = text
                    UpdateQuoteLabel(text)
                end,
                nil,
                "Save",
                "Cancel"
            )
        end
    end

    local body = frame:Add("DPanel")
    body:Dock(FILL)
    body.Paint = function() end

    -- pageContainer is created BEFORE tabColumn so the tabs paint on top of the content
    local pageContainer = body:Add("DPanel")
    pageContainer:Dock(FILL)
    pageContainer:DockMargin(10, 10, 0, 10)
    pageContainer.Paint = function() end

    local tabColumn = body:Add("DPanel")
    tabColumn:Dock(RIGHT)
    tabColumn:SetWide(55)
    tabColumn:DockMargin(0, 10, 0, 10)
    tabColumn.Paint = function() end

    -- each page: unique id, tab label, tab color, and the function that builds its content
    local pageDefs = {
        {id = "character", label = "Character", color = Color(230, 195, 90), build = BuildCharacterPage},
        {id = "health", label = "Health", color = Color(190, 80, 70), build = BuildHealthPage},
        {id = "skills", label = "Skills", color = Color(220, 130, 70), build = BuildSkillsPage},
        {id = "traits", label = "Traits", color = Color(90, 150, 170), build = BuildTraitsPage},
        {id = "conditions", label = "Other Conditions", color = Color(200, 140, 60), build = BuildConditionsPage},
        {id = "biography", label = "Biography", color = Color(90, 160, 90), build = BuildBiographyPage},
        {id = "relationships", label = "Relationships", color = Color(170, 80, 80), build = BuildRelationshipsPage}
    }

    if (data.isOwner) then
        pageDefs[#pageDefs + 1] = {id = "notes", label = "Private Notes", color = Color(150, 90, 200), build = BuildNotesPage}
    end

    local pages = {}
    local tabButtons = {}

    local function SwitchTab(activeID)
        for id, panel in pairs(pages) do
            panel:SetVisible(id == activeID)
        end

        for id, button in pairs(tabButtons) do
            button.ixActive = (id == activeID)
        end

        lastActiveTab = activeID
    end

    for _, def in ipairs(pageDefs) do
        local page = pageContainer:Add("DPanel")
        page:Dock(FILL)
        page.Paint = function() end
        def.build(page, data)
        pages[def.id] = page

        local tab = tabColumn:Add("DButton")
        tab:SetText("")
        tab:Dock(TOP)
        tab:SetTall(28)
        tab:DockMargin(0, 0, 0, 4)
        tab.ixActive = false

        tab.Paint = function(self, w, h)
            local color = def.color

            if (!self.ixActive) then
                color = Color(color.r * 0.6, color.g * 0.6, color.b * 0.6)
            end

            local leftOverlap = 40
            local rightOverlap = 40

            DisableClipping(true)
            draw.RoundedBoxEx(8, -leftOverlap, 0, w + leftOverlap + rightOverlap, h, color, false, true, false, true)
            draw.SimpleText(def.label, "DermaDefaultBold", (w - leftOverlap + rightOverlap) / 2, h / 2, Color(40, 30, 15), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            DisableClipping(false)
        end

        tab.DoClick = function()
            SwitchTab(def.id)
        end

        tabButtons[def.id] = tab
    end

    SwitchTab(pages[lastActiveTab] and lastActiveTab or "character")
end

net.Receive("ixOpenCharSheet", OpenCharacterSheet)