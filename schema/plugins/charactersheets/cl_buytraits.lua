-- the /buytraits shop. only Tier 1 traits are ever sent for purchase - the server decides that, and
-- re-checks it on purchase, so this window never has to police what's buyable. Tier 0/1 traits the
-- character already owns are sent separately for the Remove Traits tab, gated the same way.
-- the server sends ids and owned flags only; names, descriptions and effects are looked up here from
-- the shared trait table, which keeps FormatTraitModifiers clientside where its L() calls work
local FormatTraitModifiers = PLUGIN.FormatTraitModifiers

local traitDefsByID = {}

for _, trait in ipairs(PLUGIN.traits) do
    traitDefsByID[trait.id] = trait
end

local purchaseFrame
local activeTab = "buy"

local function BuildPurchaseWindow(data)
    -- reopening in place after a purchase or removal, rather than stacking a second window on top
    if (IsValid(purchaseFrame)) then
        purchaseFrame:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(460, 640)
    frame:Center()
    frame:SetTitle("Traits")
    frame:MakePopup()

    purchaseFrame = frame

    local header = frame:Add("DLabel")
    header:SetFont("DermaDefaultBold")
    header:SetTextColor(Color(217, 179, 92))
    header:Dock(TOP)
    header:SetTall(20)
    header:DockMargin(10, 8, 10, 0)
    header:SetText("Trait Points: " .. (data.points or 0))

    local tabRow = frame:Add("DPanel")
    tabRow:Dock(TOP)
    tabRow:SetTall(26)
    tabRow:DockMargin(10, 6, 10, 0)
    tabRow.Paint = function() end

    local buyTab = tabRow:Add("DButton")
    buyTab:SetText("Buy Traits")
    buyTab:Dock(LEFT)
    buyTab:SetWide(220)

    local removeTab = tabRow:Add("DButton")
    removeTab:SetText("Remove Traits")
    removeTab:Dock(RIGHT)
    removeTab:SetWide(220)

    local subHeader = frame:Add("DLabel")
    subHeader:SetTextColor(Color(160, 160, 160))
    subHeader:Dock(TOP)
    subHeader:SetTall(18)
    subHeader:DockMargin(10, 6, 10, 6)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)

    -- resolved from the shared table, then sorted here since the server no longer sends names
    local function ResolvedEntries(sentList)
        local entries = {}

        for _, sent in ipairs(sentList or {}) do
            local def = traitDefsByID[sent.id]

            if (def) then
                entries[#entries + 1] = {
                    id = def.id,
                    name = def.name,
                    description = def.description,
                    effect = FormatTraitModifiers(def),
                    tier = def.tier or 1,
                    owned = sent.owned,
                    blockedBy = sent.blockedBy
                }
            end
        end

        table.SortByMember(entries, "name", true)

        return entries
    end

    local function AddRow(trait, buttonText, buttonEnabled, buttonTooltip, onClick)
        local box = scroll:Add("DPanel")
        box:Dock(TOP)
        box:DockMargin(0, 0, 0, 5)
        box.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
        end

        local titleRow = box:Add("DPanel")
        titleRow:Dock(TOP)
        titleRow:SetTall(22)
        titleRow:DockMargin(8, 4, 8, 0)
        titleRow.Paint = function() end

        local nameLabel = titleRow:Add("DLabel")
        nameLabel:SetText(trait.name .. " (Tier " .. trait.tier .. ")")
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetTextColor(Color(217, 179, 92))
        nameLabel:Dock(FILL)

        local actionButton = titleRow:Add("DButton")
        actionButton:Dock(RIGHT)
        actionButton:SetWide(90)
        actionButton:SetText(buttonText)
        actionButton:SetEnabled(buttonEnabled)

        if (buttonTooltip) then
            actionButton:SetTooltip(buttonTooltip)
        end

        if (onClick) then
            actionButton.DoClick = onClick
        end

        local bodyText = trait.description

        if (trait.effect and trait.effect != "") then
            bodyText = bodyText .. "\n\nEffect: " .. trait.effect
        end

        local descLabel = box:Add("DLabel")
        descLabel:SetText(bodyText)
        descLabel:SetWrap(true)
        descLabel:SetAutoStretchVertical(true)
        descLabel:SetTextColor(trait.owned and Color(120, 120, 120) or Color(220, 220, 220))
        descLabel:Dock(TOP)
        descLabel:DockMargin(8, 2, 8, 4)

        -- recalculated every layout pass so it always matches the label's real wrapped height
        box.PerformLayout = function(self, w, h)
            self:SetTall(26 + descLabel:GetTall() + 8)
        end
    end

    local function RefreshList()
        scroll:Clear()

        buyTab:SetTextColor(activeTab == "buy" and Color(255, 255, 255) or Color(160, 160, 160))
        removeTab:SetTextColor(activeTab == "remove" and Color(255, 255, 255) or Color(160, 160, 160))

        if (activeTab == "buy") then
            if (data.nextCost) then
                subHeader:SetText(string.format(
                    "Purchased %d of %d - your next trait costs %d point%s.",
                    data.purchased or 0, data.maxPurchased or 10,
                    data.nextCost, data.nextCost == 1 and "" or "s"
                ))
            else
                subHeader:SetText(string.format(
                    "You've purchased all %d traits you can buy.", data.maxPurchased or 10
                ))
            end

            for _, trait in ipairs(ResolvedEntries(data.traits)) do
                -- three separate reasons a trait can't be bought right now, each worth saying
                -- plainly rather than showing one dead button that doesn't explain itself
                if (trait.owned) then
                    AddRow(trait, "Owned", false)
                elseif (trait.blockedBy) then
                    AddRow(trait, "Blocked", false, "You can't take this while you have '" .. trait.blockedBy .. "'.")
                elseif (!data.nextCost) then
                    AddRow(trait, "Max", false, "You've bought as many traits as you're allowed.")
                elseif ((data.points or 0) < data.nextCost) then
                    AddRow(trait, "Buy (" .. data.nextCost .. ")", false, "You don't have enough trait points.")
                else
                    AddRow(trait, "Buy (" .. data.nextCost .. ")", true, nil, function()
                        Derma_Query(
                            string.format(
                                "Purchase '%s' for %d trait point%s?",
                                trait.name, data.nextCost, data.nextCost == 1 and "" or "s"
                            ),
                            "Confirm Purchase",
                            "Purchase", function()
                                net.Start("ixCharSheetBuyTrait")
                                    net.WriteString(trait.id)
                                net.SendToServer()
                            end,
                            "Cancel", function() end
                        )
                    end)
                end
            end
        else
            local cost = data.removalCost or 1

            subHeader:SetText(string.format(
                "Removing a Tier 0 or Tier 1 trait costs %d trait point%s, however you came by it.",
                cost, cost == 1 and "" or "s"
            ))

            local entries = ResolvedEntries(data.removable)

            if (#entries == 0) then
                local emptyLabel = scroll:Add("DLabel")
                emptyLabel:SetText("You don't have any Tier 0 or Tier 1 traits to remove.")
                emptyLabel:SetTextColor(Color(160, 160, 160))
                emptyLabel:SetWrap(true)
                emptyLabel:Dock(TOP)
                emptyLabel:DockMargin(4, 4, 4, 4)
                emptyLabel:SetTall(36)
            end

            for _, trait in ipairs(entries) do
                if ((data.points or 0) < cost) then
                    AddRow(trait, "Remove (" .. cost .. ")", false, "You don't have enough trait points.")
                else
                    AddRow(trait, "Remove (" .. cost .. ")", true, nil, function()
                        Derma_Query(
                            string.format(
                                "Remove '%s' for %d trait point%s? This can't be undone.",
                                trait.name, cost, cost == 1 and "" or "s"
                            ),
                            "Confirm Removal",
                            "Remove", function()
                                net.Start("ixCharSheetRemoveTrait")
                                    net.WriteString(trait.id)
                                net.SendToServer()
                            end,
                            "Cancel", function() end
                        )
                    end)
                end
            end
        end
    end

    buyTab.DoClick = function()
        activeTab = "buy"
        RefreshList()
    end

    removeTab.DoClick = function()
        activeTab = "remove"
        RefreshList()
    end

    RefreshList()
end

net.Receive("ixOpenTraitPurchase", function()
    BuildPurchaseWindow(net.ReadTable())
end)
