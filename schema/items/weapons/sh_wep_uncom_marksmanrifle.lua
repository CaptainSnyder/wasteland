ITEM.name = "Marksman Rifle"
ITEM.description = "[UNCOMMON] Chambered in 5.56"
ITEM.price = 850
ITEM.class = "tfa_fwp_marksmancarbine"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_marksmancarbine.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(466.87, 483.65, 294.59),
	ang = Angle(23.53, 226, 0),
	fov = 2.1
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(75, 300)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}