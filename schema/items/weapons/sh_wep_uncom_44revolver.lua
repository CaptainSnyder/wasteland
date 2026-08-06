ITEM.name = ".44 Revolver"
ITEM.description = "[UNCOMMON] Chambered in .44 Magnum"
ITEM.price = 500
ITEM.class = "tfa_fwp_44magnum"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_44magnum.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(55.75, 727.34, 81.68),
	ang = Angle(6.29, 265.73, 0),
	fov = 1.25
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(50,200)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}