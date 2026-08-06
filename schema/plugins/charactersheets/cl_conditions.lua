local conditionList = PLUGIN.conditions
local bodyRegions = PLUGIN.bodyRegions
local FormatTraitModifiers = PLUGIN.FormatTraitModifiers

-- shared card renderer for both the Other Conditions list and the Health Conditions list
local function AddConditionBox(parent, cond)
    local box = parent:Add("DPanel")
    box:Dock(TOP)
    box:DockMargin(0, 0, 0, 6)
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

    local durationLabel = titleRow:Add("DLabel")
    durationLabel:SetText(string.format("%g hour(s)", cond.durationHours or 1))
    durationLabel:SetFont("DermaDefaultBold")
    durationLabel:SetTextColor(Color(180, 180, 180))
    durationLabel:Dock(RIGHT)
    durationLabel:SetWide(90)
    durationLabel:SetContentAlignment(6)

    local effectText = FormatTraitModifiers(cond)

    if (effectText == "") then
        effectText = "This has no mechanical effect."
    end

    local fullText = cond.description .. "\n\nEffect: " .. effectText

    local descLabel = box:Add("DLabel")
    descLabel:SetText(fullText)
    descLabel:SetWrap(true)
    descLabel:SetAutoStretchVertical(true)
    descLabel:Dock(TOP)
    descLabel:DockMargin(8, 0, 8, 4)

    box.PerformLayout = function(self, w, h)
        self:SetTall(24 + descLabel:GetTall() + 8)
    end
end

local function AddGroupHeader(parent, text, color)
    local header = parent:Add("DLabel")
    header:SetText(text)
    header:SetFont("DermaDefaultBold")
    header:SetTextColor(color)
    header:Dock(TOP)
    header:SetTall(22)
    header:DockMargin(0, 10, 0, 2)
end

-- "Other Conditions" tab reference list: non-physical effects only (drug highs, withdrawal, etc) -
-- anything tagged category == "health" belongs in OpenHealthConditionList below instead
local function OpenConditionList()
    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 500)
    frame:Center()
    frame:SetTitle("Available Other Conditions")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local otherConditions = {}

    for _, cond in ipairs(conditionList) do
        if (cond.category == "other" and !cond.hideFromList) then
            otherConditions[#otherConditions + 1] = cond
        end
    end

    table.SortByMember(otherConditions, "name", true)

    if (#otherConditions == 0) then
        local emptyLabel = scroll:Add("DLabel")
        emptyLabel:SetText("No other conditions are defined yet.")
        emptyLabel:Dock(TOP)
        emptyLabel:SetTall(20)
    end

    for _, cond in ipairs(otherConditions) do
        AddConditionBox(scroll, cond)
    end
end

-- Health tab reference list: grouped by body region (like the trait list groups by tier), plus two
-- catch-all groups for conditions that aren't tied to one fixed spot
local function OpenHealthConditionList()
    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 550)
    frame:Center()
    frame:SetTitle("Available Health Conditions")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local healthConditions = {}

    for _, cond in ipairs(conditionList) do
        if (cond.category == "health" and !cond.hideFromList) then
            healthConditions[#healthConditions + 1] = cond
        end
    end

    -- one group per body region: conditions fixed there, or choosable there
    for _, region in ipairs(bodyRegions) do
        local matches = {}

        for _, cond in ipairs(healthConditions) do
            local scope = cond.regionScope

            if ((scope == "fixed" and cond.region == region.id) or
                (scope == "choice" and table.HasValue(cond.regionOptions, region.id))) then
                matches[#matches + 1] = cond
            end
        end

        if (#matches > 0) then
            table.SortByMember(matches, "name", true)
            AddGroupHeader(scroll, region.label, Color(190, 80, 70))

            for _, cond in ipairs(matches) do
                AddConditionBox(scroll, cond)
            end
        end
    end

    -- wound-type conditions that can occur on any region
    local anyConditions = {}

    for _, cond in ipairs(healthConditions) do
        if (cond.regionScope == "any") then
            anyConditions[#anyConditions + 1] = cond
        end
    end

    if (#anyConditions > 0) then
        table.SortByMember(anyConditions, "name", true)
        AddGroupHeader(scroll, "Any Region", Color(140, 140, 140))

        for _, cond in ipairs(anyConditions) do
            AddConditionBox(scroll, cond)
        end
    end

    -- whole-body conditions with no specific location
    local generalConditions = {}

    for _, cond in ipairs(healthConditions) do
        if ((cond.regionScope or "general") == "general") then
            generalConditions[#generalConditions + 1] = cond
        end
    end

    if (#generalConditions > 0) then
        table.SortByMember(generalConditions, "name", true)
        AddGroupHeader(scroll, "General (No Location)", Color(140, 140, 140))

        for _, cond in ipairs(generalConditions) do
            AddConditionBox(scroll, cond)
        end
    end
end

net.Receive("ixOpenConditionList", OpenConditionList)
net.Receive("ixOpenHealthConditionList", OpenHealthConditionList)
