ITEM.name = "Car Battery"
ITEM.description = "[UNCOMMON] A heavy lead-acid battery, probably still got some charge left."
ITEM.price = 20
ITEM.flag = "C"
ITEM.model = "models/illusion/eftcontainers/carbattery.mdl"
ITEM.width = 2
ITEM.height = 1

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
