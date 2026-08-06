ITEM.name = "Gears"
ITEM.description = "[COMMON] A box containing gears."
ITEM.price = 5
ITEM.flag = "C"
ITEM.model = "models/mosi/fallout4/props/junk/components/gears.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(1, 5)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}