ITEM.name = "Hunting Shotgun"
ITEM.description = "[UNCOMMON] Chambered in 12g"
ITEM.price = 850
ITEM.class = "tfa_fwp_huntingshotgun"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_huntingshotgun.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(43.12, 723.47, 86.17),
	ang = Angle(6.69, 266.97, 0),
	fov = 3.55
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}