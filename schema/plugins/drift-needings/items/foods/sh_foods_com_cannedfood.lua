ITEM.name = "Unlabeled Canned Food"
ITEM.model = Model("models/hlvr/food/can_1.mdl")
ITEM.description = "[COMMON] A dented can with no label left. Could be anything. Probably fine."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 10
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav"
ITEM.RestoreSatiety = 8
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
