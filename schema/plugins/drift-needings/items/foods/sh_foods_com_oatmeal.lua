ITEM.name = "Bowl of Oatmeal"
ITEM.model = Model("models/illusion/eftcontainers/oatmeal.mdl")
ITEM.description = "[COMMON] A bowl of plain oatmeal. Filling, if bland."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 15
ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav"
ITEM.RestoreSatiety = 10
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
