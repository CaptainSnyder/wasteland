ITEM.name = "Cigarette Pack"
ITEM.model = Model("models/mosi/fallout4/props/junk/cigarettepack.mdl")
ITEM.description = "[UNCOMMON] A pack of cigarettes."
ITEM.category = "Consumable"
ITEM.price = 10
ITEM.width = 1
ITEM.height = 1

local MAX_CIGARETTES = 20

-- fires once, the moment a new instance of this item is created - whether that's an admin spawning
-- it fresh, a vendor stocking it, or a Cigarette Carton handing one out - never on a server restart
-- loading an already-saved (partially smoked) pack back into memory, since that path never touches
-- ix.item.Instance at all
function ITEM:OnInstanced()
	self:SetData("charges", MAX_CIGARETTES)
end

if (CLIENT) then
	-- shows how many cigarettes are left in the bottom-right corner of the inventory icon,
	-- matching Helix's own base ammo item convention
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("charges", MAX_CIGARETTES), "DermaDefault", w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

ITEM.functions.Take = {
	name = "Take a Cigarette",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		local charges = item:GetData("charges", MAX_CIGARETTES)

		if (charges <= 0) then
			return true -- already empty somehow, just let it get removed
		end

		local added = character:GetInventory():Add("consum_com_cigarette")

		if (!added) then
			client:Notify("You don't have room for another cigarette.")
			return false
		end

		charges = charges - 1
		item:SetData("charges", charges)

		client:Notify("You take a cigarette from the pack. (" .. charges .. " left)")

		return charges <= 0 -- only consume the pack once it's actually empty
	end
}

-- drug item, follows medical junkify rules: uncommon drug/medical item: 8-30 tokens when junkified
-- at full charges, scaled down by how many cigarettes have already been taken
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		local charges = itemTable:GetData("charges", MAX_CIGARETTES)
		local amount = math.max(1, math.floor(math.random(8, 30) * (charges / MAX_CIGARETTES)))
		character:GiveMoney(ix.config.Get("rationTokens", amount))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
