ITEM.name = "9mm Pistol"
ITEM.description = "[COMMON] Chambered in 9mm."
ITEM.price = 250
ITEM.class = "tfa_fwp_9mmpistol"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_9mmpistol.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(509.58, 427.69, 310.24),
	ang = Angle(24.89, 219.95, 0),
	fov = 0.59
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25,75)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}