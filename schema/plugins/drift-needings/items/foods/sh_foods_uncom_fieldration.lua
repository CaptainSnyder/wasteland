ITEM.name = "Field Ration"
ITEM.model = Model("models/illusion/eftcontainers/mre.mdl")
ITEM.description = "[UNCOMMON] A self-contained field ration - enough food and water to keep you going for a while."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 30
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav"
ITEM.RestoreSatiety = 20
ITEM.RestoreSaturation = 40
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
