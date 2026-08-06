ITEM.name = "Power Supply Unit"
ITEM.description = "[RARE] A pre-war power supply unit, remarkably still functional."
ITEM.price = 50
ITEM.flag = "C"
ITEM.model = "models/illusion/eftcontainers/powersupplyunit.mdl"
ITEM.width = 2
ITEM.height = 1

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(5, 20)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
