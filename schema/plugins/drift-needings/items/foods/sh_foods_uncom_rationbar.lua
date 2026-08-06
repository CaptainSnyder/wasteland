ITEM.name = "Ration Bar"
ITEM.model = Model("models/hlvr/food/ration_bar.mdl")
ITEM.description = "[UNCOMMON] A dense, pre-war ration bar. Not appetizing, but it'll keep you going."
ITEM.width = 1
ITEM.height = 1
ITEM.price = 30
ITEM.useSound = "npc/barnacle/barnacle_crunch3.wav"
ITEM.RestoreSatiety = 22
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
