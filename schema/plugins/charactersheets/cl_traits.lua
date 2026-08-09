local traitList = PLUGIN.traits
local FormatTraitModifiers = PLUGIN.FormatTraitModifiers

local TIER_INFO = {
    [0] = {label = "Negative Traits", color = Color(200, 95, 85)},
    [1] = {label = "Tier 1 - Basic", color = Color(180, 180, 180)},
    [2] = {label = "Tier 2 - Rewarded", color = Color(217, 179, 92)},
    [3] = {label = "Tier 3 - GM/Rare", color = Color(190, 90, 200)}
}

-- tier 0 is numbered below tier 1 (it costs nothing to take) but shown last, since a wall of
-- drawbacks is not what anyone wants at the top of the list. the number is invisible to players -
-- only this order and the label above are - so display order is deliberately not numeric order
local TIER_DISPLAY_ORDER = {1, 2, 3, 0}

local function OpenTraitList()
    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 550)
    frame:Center()
    frame:SetTitle("Available Traits")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local byTier = {}

    for _, trait in ipairs(traitList) do
        local tier = trait.tier or 1
        byTier[tier] = byTier[tier] or {}
        table.insert(byTier[tier], trait)
    end

    for _, tier in ipairs(TIER_DISPLAY_ORDER) do
        local traits = byTier[tier]

        if (traits and #traits > 0) then
            table.SortByMember(traits, "name", true)

            local info = TIER_INFO[tier]
            -- every card in this tier, so the header can hide and show them as a group
            local boxes = {}
            local expanded = true

            local header = scroll:Add("DButton")
            header:SetFont("DermaDefaultBold")
            header:SetTextColor(info.color)
            header:SetContentAlignment(4)
            header:SetTextInset(4, 0)
            header:Dock(TOP)
            header:SetTall(22)
            header:DockMargin(0, 10, 0, 2)
            header.Paint = function() end -- headers stay flat text, not raised buttons

            local function UpdateHeader()
                header:SetText(string.format(
                    "%s %s (%d)", expanded and "-" or "+", info.label, #traits
                ))
            end

            header.DoClick = function()
                expanded = !expanded

                for _, box in ipairs(boxes) do
                    box:SetVisible(expanded)

                    -- each card sizes itself in its own PerformLayout from the wrapped description
                    -- height, and a hidden panel never lays out - so one being re-shown needs its
                    -- height recomputed before the canvas can measure it
                    if (expanded) then
                        box:InvalidateLayout(true)
                    end
                end

                UpdateHeader()

                -- the cards are parented to the scroll panel's *canvas*, not the scroll panel, and
                -- the canvas caches its own height. invalidating only the outer panel left that
                -- cached height untouched, which stranded the collapsed section's space and pushed
                -- every later tier off the bottom of the list. true forces an immediate layout
                local canvas = scroll:GetCanvas()

                if (IsValid(canvas)) then
                    canvas:InvalidateLayout(true)
                end

                scroll:InvalidateLayout(true)
            end

            UpdateHeader()

            for _, trait in ipairs(traits) do
                local box = scroll:Add("DPanel")
                box:Dock(TOP)
                box:DockMargin(0, 0, 0, 6)
                box.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
                end

                boxes[#boxes + 1] = box

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