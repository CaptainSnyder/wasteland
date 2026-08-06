ITEM.name = "Cowboy Repeater"
ITEM.description = "[COMMON] Chambered in .357"
ITEM.price = 400
ITEM.class = "tfa_fwp_cowboyrepeater"
ITEM.weaponCategory = "Primary"
ITEM.flag = "F"
ITEM.model = "models/illusion/fwp/w_cowboyrepeater.mdl"
ITEM.width = 4
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(530.39, 463.21, 199.96),
	ang = Angle(15.83, 221.46, 0),
	fov = 2.38
}




ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(25, 100)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}