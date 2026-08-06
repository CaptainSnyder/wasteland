ITEM.name = "Handmade Rifle"
ITEM.description = "[COMMON] Chambered in 5.56"
ITEM.price = 400
ITEM.class = "tfa_fwp_hmar"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_hmar.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(375.03, 579.56, 248.4),
	ang = Angle(19.86, 237.27, 0),
	fov = 2.64
}





ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}