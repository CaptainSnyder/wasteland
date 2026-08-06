ITEM.name = "Combat Rifle"
ITEM.description = "[UNCOMMON] Chambered in .45"
ITEM.price = 850
ITEM.class = "tfa_fwp_combatrifle"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_combatrifle.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(341.25, 554.55, 338.97),
	ang = Angle(27.59, 238.78, 0),
	fov = 1.69
}


ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}