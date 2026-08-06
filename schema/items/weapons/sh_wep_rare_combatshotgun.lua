ITEM.name = "Combat Shotgun"
ITEM.description = "[RARE] Chambered in 12g"
ITEM.price = 1500
ITEM.class = "tfa_fwp_combatshotgun"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_combatshotgun.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(17.07, 707.19, 156.53),
	ang = Angle(12.55, 268.83, 0),
	fov = 2.83
}



ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}