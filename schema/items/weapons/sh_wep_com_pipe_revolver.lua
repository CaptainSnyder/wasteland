ITEM.name = "Pipe Revolver"
ITEM.description = "[COMMON] Chambered in .38"
ITEM.price = 100
ITEM.class = "tfa_fwp_piperevolver"
ITEM.weaponCategory = "sidearm"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_piperevolver.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(509.64, 427.61, 310.24),
	ang = Angle(25, 220, 0),
	fov = 0.88
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(15, 50)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}