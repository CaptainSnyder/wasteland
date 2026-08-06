ITEM.name = "Glass of Juice"
ITEM.model = Model("models/illusion/eftcontainers/juice.mdl")
ITEM.description = "[COMMON] A glass of fruit juice. Surprisingly good, given everything."
ITEM.width = 1
ITEM.height = 1
ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav"
ITEM.RestoreSaturation = 12
ITEM.price = 12
ITEM.flag = "V"

-- common consumable: 1-5 tokens when junkified
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(1, 5)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
