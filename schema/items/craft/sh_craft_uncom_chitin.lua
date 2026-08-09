ITEM.name = "Chitin"
ITEM.description = "[UNCOMMON] A curved plate of antlion shell, still faintly warm. Tougher than it looks and light enough to be worth carrying."
ITEM.price = 20
ITEM.flag = "C"
-- stock HL2 antlion gib, so it's guaranteed present without any addon. swap this for a proper
-- fallout-style component model if you'd rather it matched Leather's look
ITEM.model = "models/gibs/antlion_gib_large_1.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
