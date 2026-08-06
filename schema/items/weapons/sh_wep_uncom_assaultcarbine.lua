ITEM.name = "Assault Carbine"
ITEM.description = "[UNCOMMON] Chambered in 5mm"
ITEM.price = 850
ITEM.class = "tfa_fwp_assaultcarbine"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_assaultcarbine.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(493.1, 478.44, 257.83),
	ang = Angle(20.51, 224.38, 0),
	fov = 2.25
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}