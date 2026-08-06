ITEM.name = "Varmint Rifle"
ITEM.description = "[COMMON] Chambered in 5.56"
ITEM.price = 400
ITEM.class = "tfa_fwp_varmintrifle"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_varmintrifle.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(121.03, 679.27, 253.67),
	ang = Angle(20.09, 260.09, 0),
	fov = 3.01
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}