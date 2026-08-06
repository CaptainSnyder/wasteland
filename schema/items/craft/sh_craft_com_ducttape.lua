ITEM.name = "Duct Tape"
ITEM.description = "[COMMON] A roll of duct tape. Fixes almost anything, badly."
ITEM.price = 5
ITEM.flag = "C"
ITEM.model = "models/illusion/eftcontainers/ducttape.mdl"
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
