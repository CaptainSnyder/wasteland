ITEM.name = "Ration Pack"
ITEM.model = Model("models/silver/outbreak/items/item_ration.mdl")
ITEM.description = "[UNCOMMON] A full field ration pack. About as close to a real meal as you'll get out here."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 35
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav"
ITEM.RestoreSatiety = 28
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
