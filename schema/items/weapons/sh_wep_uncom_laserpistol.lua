ITEM.name = "Laser Pistol"
ITEM.description = "[UNCOMMON] Utilizes MFC"
ITEM.price = 850
ITEM.class = "tfa_fwp_laserpistol"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_laserpistol.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(-67.11, 721.3, 119.09),
	ang = Angle(9.24, 275.6, 0),
	fov = 1.6
}



ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(50, 200)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}