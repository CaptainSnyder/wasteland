ITEM.name = "Hunting Rifle"
ITEM.description = "[UNCOMMON] Chambered in .308"
ITEM.price = 850
ITEM.class = "tfa_fwp_huntingrifle"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_huntingrifle.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(274.82, 491.91, 475.11),
	ang = Angle(40.22, 241.34, 0),
	fov = 3.17
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}