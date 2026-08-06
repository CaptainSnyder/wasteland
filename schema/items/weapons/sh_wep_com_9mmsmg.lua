ITEM.name = "9mm SMG"
ITEM.description = "[COMMON] Chambered in 9mm."
ITEM.price = 400
ITEM.class = "tfa_fwp_9mmsmg"
ITEM.weaponCategory = "primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_9mmsmg.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(233.85, 674.88, 163.35),
	ang = Angle(13.03, 250.96, 0),
	fov = 1.79
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}