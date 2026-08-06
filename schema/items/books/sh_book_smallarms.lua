ITEM.name = "Small Arms Book"
ITEM.description = "A field guide to handguns and rifles, covering everything from stance to trigger discipline."
ITEM.model = "models/props_interiors/books01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Skill Books"
ITEM.price = 1500

ITEM.functions.Read = {
	name = "Read",
	OnRun = function(item)
		return GrantSkillLevel(item.player, "smallarms")
	end
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(200, 400)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
