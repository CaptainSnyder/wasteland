ITEM.name = "Anti-Material Rife"
ITEM.description = "[RARE] Chambered in .50 MG"
ITEM.price = 1500
ITEM.class = "tfa_fwp_amr"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_amr.mdl"
ITEM.width = 5
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(391.93, 573.3, 248.14),
	ang = Angle(19.64, 236.34, 0),
	fov = 3.35
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(125, 500)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}