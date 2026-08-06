ITEM.name = "Cat Figurine"
ITEM.description = "[TRASH] A small ceramic cat figurine, chipped but intact."
ITEM.price = 0
ITEM.model = "models/illusion/eftcontainers/catfigurine.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(1, 3)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
