local traitList = PLUGIN.traits
local FormatTraitModifiers = PLUGIN.FormatTraitModifiers

local TIER_INFO = {
    [1] = {label = "Tier 1 - Basic", color = Color(180, 180, 180)},
    [2] = {label = "Tier 2 - Rewarded", color = Color(217, 179, 92)},
    [3] = {label = "Tier 3 - GM/Rare", color = Color(190, 90, 200)}
}

local function OpenTraitList()
    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 550)
    frame:Center()
    frame:SetTitle("Available Traits")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    -- group traits by tier, 1 through 3
    local byTier = {[1] = {}, [2] = {}, [3] = {}}

    for _, trait in ipairs(traitList) do
        local tier = trait.tier or 1
        byTier[tier] = byTier[tier] or {}
        table.insert(byTier[tier], trait)
    end

    for tier = 1, 3 do
        local traits = byTier[tier]

        if (traits and #traits > 0) then
            table.SortByMember(traits, "name", true)

            local info = TIER_INFO[tier]

            local header = scroll:Add("DLabel")
            header:SetText(info.label)
            header:SetFont("DermaDefaultBold")
            header:SetTextColor(info.color)
            header:Dock(TOP)
            header:SetTall(22)
            header:DockMargin(0, 10, 0, 2)

            for _, trait in ipairs(traits) do
                local box = scroll:Add("DPanel")
                box:Dock(TOP)
                box:DockMargin(0, 0, 0, 6)
                box.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
                end

                local nameLabel = box:Add("DLabel")
                nameLabel:SetText(trait.name)
                nameLabel:SetFont("DermaDefaultBold")
                nameLabel:SetTextColor(Color(217, 179, 92))
                nameLabel:Dock(TOP)
                nameLabel:SetTall(20)
                nameLabel:DockMargin(8, 4, 8, 0)

                local effectText = FormatTraitModifiers(trait)

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
    end
end

net.Receive("ixOpenTraitList", OpenTraitList)