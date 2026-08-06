ITEM.name = "10mm Pistol"
ITEM.description = "[COMMON] Chambered in 10mm."
ITEM.price = 250
ITEM.class = "tfa_fwp_10mmpistol"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_10mmpistol.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(0, 200, 0),
	ang = Angle(-0.12, 270, 0),
	fov = 3.5
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25,75)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}