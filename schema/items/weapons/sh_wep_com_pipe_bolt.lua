ITEM.name = "Pipe Bolt Action"
ITEM.description = "[COMMON] Chambered in .308"
ITEM.price = 200
ITEM.class = "tfa_fwp_pipeboltscoped"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_pipeboltscoped.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(416.36, 510.66, 323.83),
	ang = Angle(26.09, 230.97, 0),
	fov = 2.25
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(15, 50)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}