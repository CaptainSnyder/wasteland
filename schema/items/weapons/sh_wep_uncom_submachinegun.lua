ITEM.name = "Submachine Gun"
ITEM.description = "[UNCOMMON] Chambered in .45"
ITEM.price = 850
ITEM.class = "tfa_fwp_tommygun"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_tommygun.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(-14.59, 722.51, 123.12),
	ang = Angle(9.67, 270.91, 0),
	fov = 2.56
}



ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}