ITEM.name = "Cigarette"
ITEM.model = Model("models/mosi/fallout4/props/junk/cigarette.mdl")
ITEM.description = "[COMMON] A hand-rolled cigarette. Won't do your lungs any favors, but it steadies your hands for a bit."
ITEM.category = "Consumable"
ITEM.price = 5
ITEM.width = 1
ITEM.height = 1
-- smoked far more often than a bottle gets drunk, so kept to the lowest chance in the game
ITEM.addictionChance = 1

ITEM.functions.Smoke = {
	name = "Smoke",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		if (ApplyCharacterCondition) then
			ApplyCharacterCondition(character, "cigarette")
		end

		if (RollForAddiction) then
			RollForAddiction(client, item.addictionChance)
		end

		client:Notify("You light up and take a long drag.")

		return true -- consumes the item
	end
}

-- cigarettes are on their own scale rather than the medical one, because packs and cartons are
-- worth exactly what they contain (a pack = 20 cigarettes, a carton = 8 packs = 160 cigarettes).
-- keeping the per-cigarette value this low is what stops those containers running away entirely
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(1, 3)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
