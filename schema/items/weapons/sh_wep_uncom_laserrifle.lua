ITEM.name = "Laser Rifle"
ITEM.description = "[UNCOMMON] Utilizes MFC"
ITEM.price = 850
ITEM.class = "tfa_fwp_laserrifle"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_laserrifle.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(29.97, 728.43, 107.47),
	ang = Angle(8.42, 267.53, 0),
	fov = 3
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}