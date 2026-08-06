ITEM.name = "12.7mm Pistol"
ITEM.description = "[RARE] Chambered in 12.7mm"
ITEM.price = 1000
ITEM.class = "tfa_fwp_127pistol"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_127mmpistol.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(450.44, 496.1, 299.67),
	ang = Angle(24.04, 227.76, 0),
	fov = 0.83
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(100,400)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}