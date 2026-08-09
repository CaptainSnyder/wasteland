-- the /buytraits shop. only Tier 1 traits are ever sent here - the server decides that, and re-checks
-- it on purchase, so this window never has to police what's buyable
local purchaseFrame

local function BuildPurchaseWindow(data)
    -- reopening in place after a purchase, rather than stacking a second window on top of the first
    if (IsValid(purchaseFrame)) then
        purchaseFrame:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(460, 600)
    frame:Center()
    frame:SetTitle("Purchase Traits")
    frame:MakePopup()

    purchaseFrame = frame

    local header = frame:Add("DLabel")
    header:SetFont("DermaDefaultBold")
    header:SetTextColor(Color(217, 179, 92))
    header:Dock(TOP)
    header:SetTall(20)
    header:DockMargin(10, 8, 10, 0)
    header:SetText("Trait Points: " .. (data.points or 0))

    local subHeader = frame:Add("DLabel")
    subHeader:SetTextColor(Color(160, 160, 160))
    subHeader:Dock(TOP)
    subHeader:SetTall(18)
    subHeader:DockMargin(10, 2, 10, 6)

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

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)

    for _, trait in ipairs(data.traits or {}) do
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
        nameLabel:SetText(trait.name)
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetTextColor(Color(217, 179, 92))
        nameLabel:Dock(FILL)

        local buyButton = titleRow:Add("DButton")
        buyButton:Dock(RIGHT)
        buyButton:SetWide(70)

        -- three separate reasons a trait can't be bought right now, each worth saying plainly rather
        -- than showing one dead button that doesn't explain itself
        if (trait.owned) then
            buyButton:SetText("Owned")
            buyButton:SetEnabled(false)
        elseif (!data.nextCost) then
            buyButton:SetText("Max")
            buyButton:SetEnabled(false)
            buyButton:SetTooltip("You've bought as many traits as you're allowed.")
        elseif ((data.points or 0) < data.nextCost) then
            buyButton:SetText("Buy (" .. data.nextCost .. ")")
            buyButton:SetEnabled(false)
            buyButton:SetTooltip("You don't have enough trait points.")
        else
            buyButton:SetText("Buy (" .. data.nextCost .. ")")

            buyButton.DoClick = function()
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
            end
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
end

net.Receive("ixOpenTraitPurchase", function()
    BuildPurchaseWindow(net.ReadTable())
end)
