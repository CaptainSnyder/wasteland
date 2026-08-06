ITEM.name = "Caravan Shotgun"
ITEM.description = "[COMMON] Chambered in 12g"
ITEM.price = 400
ITEM.class = "tfa_fwp_caravanshotgun"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_caravanshotgun.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(425.99, 505.69, 318.79),
	ang = Angle(25.86, 230.04, 0),
	fov = 2.38
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}