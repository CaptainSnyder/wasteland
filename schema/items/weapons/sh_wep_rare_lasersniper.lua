ITEM.name = "Laser Sniper"
ITEM.description = "[RARE] Utilizes MFC"
ITEM.price = 1500
ITEM.class = "tfa_fwp_wattzlasergun"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_wattzlasergun.mdl"
ITEM.width = 5
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(7.23, 717.99, 132.49),
	ang = Angle(10.28, 269.92, 0),
	fov = 4.34
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(125, 500)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}