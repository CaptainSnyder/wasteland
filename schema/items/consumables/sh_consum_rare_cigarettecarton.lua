ITEM.name = "Cigarette Carton"
ITEM.model = Model("models/mosi/fallout4/props/junk/cigarettecarton.mdl")
ITEM.description = "[RARE] A carton of cigarette packs."
ITEM.category = "Consumable"
ITEM.price = 30
ITEM.width = 2
ITEM.height = 1

local MAX_PACKS = 12

-- see sh_consum_uncom_cigarettepack.lua - same reasoning, only ever runs on true first creation
function ITEM:OnInstanced()
	self:SetData("charges", MAX_PACKS)
end

if (CLIENT) then
	-- shows how many packs are left in the bottom-right corner of the inventory icon,
	-- matching Helix's own base ammo item convention
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("charges", MAX_PACKS), "DermaDefault", w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

ITEM.functions.Take = {
	name = "Take a Pack",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		local charges = item:GetData("charges", MAX_PACKS)

		if (charges <= 0) then
			return true -- already empty somehow, just let it get removed
		end

		local added = character:GetInventory():Add("consum_uncom_cigarettepack")

		if (!added) then
			client:Notify("You don't have room for another pack.")
			return false
		end

		charges = charges - 1
		item:SetData("charges", charges)

		client:Notify("You take a pack from the carton. (" .. charges .. " left)")

		return charges <= 0 -- only consume the carton once it's actually empty
	end
}

-- drug item, follows medical junkify rules: rare drug/medical item: 15-50 tokens when junkified
-- at full charges, scaled down by how many packs have already been taken
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		local charges = itemTable:GetData("charges", MAX_PACKS)
		local amount = math.max(1, math.floor(math.random(15, 50) * (charges / MAX_PACKS)))
		character:GiveMoney(ix.config.Get("rationTokens", amount))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
