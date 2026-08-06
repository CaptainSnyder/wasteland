-- Clickable body diagram for the Health tab's silhouette. Front-facing view, so the character's own
-- left renders on the viewer's right - leftarm/leftleg shapes sit at the larger x-coordinate.
-- Each non-head region has a "poly" (a tapered quad, drawn via surface.DrawPoly) so the silhouette
-- reads as limbs rather than uniform rectangles; hit-testing still uses the plain x/y/w/h bounding box.

-- coordinates are chosen so adjacent regions share an exact edge (shoulders/hips/waist all line up) -
-- only the legs have a deliberate small centerline gap, same as a real silhouette
local REGION_SHAPES = {
    {id = "head", x = 0.41, y = 0.05, w = 0.18, h = 0.14},
    {id = "uppertorso", x = 0.30, y = 0.19, w = 0.40, h = 0.13,
        poly = {{0.30, 0.19}, {0.70, 0.19}, {0.67, 0.32}, {0.33, 0.32}}},
    {id = "lowertorso", x = 0.32, y = 0.32, w = 0.36, h = 0.12,
        poly = {{0.33, 0.32}, {0.67, 0.32}, {0.68, 0.44}, {0.32, 0.44}}},
    {id = "upperrightarm", x = 0.14, y = 0.19, w = 0.16, h = 0.15,
        poly = {{0.14, 0.19}, {0.30, 0.19}, {0.27, 0.34}, {0.16, 0.34}}},
    {id = "lowerrightarm", x = 0.16, y = 0.34, w = 0.11, h = 0.16,
        poly = {{0.16, 0.34}, {0.27, 0.34}, {0.25, 0.50}, {0.18, 0.50}}},
    {id = "upperleftarm", x = 0.70, y = 0.19, w = 0.16, h = 0.15,
        poly = {{0.70, 0.19}, {0.86, 0.19}, {0.84, 0.34}, {0.73, 0.34}}},
    {id = "lowerleftarm", x = 0.73, y = 0.34, w = 0.11, h = 0.16,
        poly = {{0.73, 0.34}, {0.84, 0.34}, {0.82, 0.50}, {0.75, 0.50}}},
    {id = "upperrightleg", x = 0.32, y = 0.44, w = 0.17, h = 0.16,
        poly = {{0.32, 0.44}, {0.49, 0.44}, {0.47, 0.60}, {0.34, 0.60}}},
    {id = "lowerrightleg", x = 0.34, y = 0.60, w = 0.13, h = 0.22,
        poly = {{0.34, 0.60}, {0.47, 0.60}, {0.45, 0.82}, {0.36, 0.82}}},
    {id = "upperleftleg", x = 0.51, y = 0.44, w = 0.17, h = 0.16,
        poly = {{0.51, 0.44}, {0.68, 0.44}, {0.66, 0.60}, {0.53, 0.60}}},
    {id = "lowerleftleg", x = 0.53, y = 0.60, w = 0.13, h = 0.22,
        poly = {{0.53, 0.60}, {0.66, 0.60}, {0.64, 0.82}, {0.55, 0.82}}}
}

local REGION_LABELS = {
    head = "Head",
    uppertorso = "Upper Torso",
    lowertorso = "Lower Torso",
    upperleftarm = "Upper Left Arm",
    lowerleftarm = "Lower Left Arm",
    upperrightarm = "Upper Right Arm",
    lowerrightarm = "Lower Right Arm",
    upperleftleg = "Upper Left Leg",
    lowerleftleg = "Lower Left Leg",
    upperrightleg = "Upper Right Leg",
    lowerrightleg = "Lower Right Leg"
}

local COLOR_BG = Color(38, 38, 38)
local COLOR_HEALTHY = Color(210, 210, 210)
local COLOR_INJURED = Color(190, 70, 60)
local WHITE_MATERIAL = Material("vgui/white")

local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self.regionBuckets = {}
    self.isOwner = false
end

-- conditionList entries carry sourceId/name/description/region/category/remainingSeconds (see
-- SendCharacterSheet in sh_plugin.lua); only "health" category entries with a region show up here -
-- "other" category and region-less "general" conditions belong on the other tabs instead
function PANEL:SetConditions(conditionList, isOwner)
    self.isOwner = isOwner
    self.regionBuckets = {}

    for _, cond in ipairs(conditionList or {}) do
        if (cond.region and cond.category == "health" and REGION_LABELS[cond.region]) then
            self.regionBuckets[cond.region] = self.regionBuckets[cond.region] or {}
            table.insert(self.regionBuckets[cond.region], cond)
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, COLOR_BG)

    for _, shape in ipairs(REGION_SHAPES) do
        local bucket = self.regionBuckets[shape.id]
        local color = (bucket and #bucket > 0) and COLOR_INJURED or COLOR_HEALTHY

        if (shape.poly) then
            surface.SetMaterial(WHITE_MATERIAL)
            surface.SetDrawColor(color)

            local verts = {}

            for i, point in ipairs(shape.poly) do
                verts[i] = {x = point[1] * w, y = point[2] * h}
            end

            surface.DrawPoly(verts)
        else
            -- the head has no poly - draw it as a plain circle instead
            draw.RoundedBox(999, shape.x * w, shape.y * h, shape.w * w, shape.h * h, color)
        end
    end
end

-- returns the region id under the given normalized (0-1) point, or nil if outside every region
function PANEL:GetRegionAt(nx, ny)
    for _, shape in ipairs(REGION_SHAPES) do
        if (nx >= shape.x and nx <= shape.x + shape.w and ny >= shape.y and ny <= shape.y + shape.h) then
            return shape.id
        end
    end

    return nil
end

function PANEL:OnMouseReleased(mouseCode)
    local w, h = self:GetSize()
    local x, y = self:LocalCursorPos()
    local regionID = self:GetRegionAt(x / w, y / h)

    if (regionID and mouseCode == MOUSE_RIGHT) then
        self:OpenRegionMenu(regionID)
    end
end

-- builds curesIndex[conditionID] = {uniqueID, ...} from every registered item's ITEM.curesConditions
local function BuildCuresIndex()
    local index = {}

    for uniqueID, itemTable in pairs(ix.item.list) do
        for _, conditionID in ipairs(itemTable.curesConditions or {}) do
            index[conditionID] = index[conditionID] or {}
            table.insert(index[conditionID], uniqueID)
        end
    end

    return index
end

local function SendUseAction(itemID, invID, region)
    net.Start("ixInventoryAction")
        net.WriteString("UseSelf")
        net.WriteUInt(itemID, 32)
        net.WriteUInt(invID, 32)
        net.WriteTable({region = region})
    net.SendToServer()
end

-- right-click menu for a single body part: lists its active conditions and, if you own this sheet,
-- any inventory item that can cure them (reuses the normal "UseSelf" inventory action, just scoped
-- to this region via the data table - see the region-scoped RemoveCharacterCondition in sh_plugin.lua)
function PANEL:OpenRegionMenu(regionID)
    local bucket = self.regionBuckets[regionID] or {}
    local menu = DermaMenu()

    menu:AddOption(REGION_LABELS[regionID] .. ":"):SetEnabled(false)

    if (#bucket == 0) then
        menu:AddOption("No injuries here."):SetEnabled(false)
        menu:Open()
        return
    end

    if (!self.isOwner) then
        for _, cond in ipairs(bucket) do
            menu:AddOption(cond.name):SetEnabled(false)
        end

        menu:Open()
        return
    end

    local character = LocalPlayer():GetCharacter()
    local inventory = character and character:GetInventory()

    if (!inventory) then
        menu:Remove()
        return
    end

    local curesIndex = BuildCuresIndex()
    local invID = inventory:GetID()
    local ownedItems = inventory:GetItems()

    for _, cond in ipairs(bucket) do
        local matchedAny = false
        local curingUniqueIDs = curesIndex[cond.sourceId] or {}

        for _, ownedItem in pairs(ownedItems) do
            if (table.HasValue(curingUniqueIDs, ownedItem.uniqueID)) then
                matchedAny = true
                local itemID = ownedItem.id

                menu:AddOption("Use " .. ownedItem.name .. " on " .. cond.name, function()
                    SendUseAction(itemID, invID, regionID)
                end)
            end
        end

        if (!matchedAny) then
            menu:AddOption(cond.name .. " (no cure in inventory)"):SetEnabled(false)
        end
    end

    menu:Open()
end

vgui.Register("ixBodyDiagram", PANEL, "DPanel")
