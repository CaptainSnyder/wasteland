ITEM.name = "Pipe Rifle"
ITEM.description = "[COMMON] Chambered in .38"
ITEM.price = 400
ITEM.class = "tfa_fwp_piperiflesemi"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_piperiflesemi.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(317.28, 610.53, 256.75),
	ang = Angle(20.44, 242.36, 0),
	fov = 2.59
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(15, 50)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}