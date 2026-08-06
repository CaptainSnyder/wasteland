ITEM.name = "Purified Water"
ITEM.model = Model("models/illusion/eftcontainers/waterbottle.mdl")
ITEM.description = "[UNCOMMON] A bottle of properly filtered water. Clean, and worth more for it."
ITEM.width = 1
ITEM.height = 1
ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav"
ITEM.RestoreSaturation = 38
ITEM.price = 20
ITEM.flag = "V"

-- uncommon consumable: 3-7 tokens when junkified
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(3, 7)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
