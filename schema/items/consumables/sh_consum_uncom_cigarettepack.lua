ITEM.name = "Cigarette Pack"
ITEM.model = Model("models/mosi/fallout4/props/junk/cigarettepack.mdl")
ITEM.description = "[UNCOMMON] A pack of cigarettes."
ITEM.category = "Consumable"
-- priced above the 60 a full pack can junkify for, so selling always beats scrapping
ITEM.price = 75
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

-- a pack is worth exactly the cigarettes still inside it - one 1-3 roll per remaining cigarette,
-- so a full pack lands 20-60 and a nearly empty one is worth almost nothing. this replaces the old
-- percentage-scaling approach, since counting the actual contents is both simpler and exact
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		local charges = itemTable:GetData("charges", MAX_CIGARETTES)
		local amount = 0

		for i = 1, charges do
			amount = amount + math.random(1, 3)
		end

		character:GiveMoney(ix.config.Get("rationTokens", math.max(1, amount)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
