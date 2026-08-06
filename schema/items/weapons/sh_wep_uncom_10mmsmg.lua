ITEM.name = "10mm SMG"
ITEM.description = "[UNCOMMON] Chambered in 10mm"
ITEM.price = 850
ITEM.class = "tfa_fwp_10mmsmg"
ITEM.weaponCategory = "primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_10mmsmg.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(203.9, 654.45, 262.56),
	ang = Angle(20.99, 252.77, 0),
	fov = 1.42
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75,300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}