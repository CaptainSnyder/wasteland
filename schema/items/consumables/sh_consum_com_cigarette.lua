ITEM.name = "Cigarette"
ITEM.model = Model("models/mosi/fallout4/props/junk/cigarette.mdl")
ITEM.description = "[COMMON] A hand-rolled cigarette. Won't do your lungs any favors, but it steadies your hands for a bit."
ITEM.category = "Consumable"
ITEM.price = 5
ITEM.width = 1
ITEM.height = 1

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

		client:Notify("You light up and take a long drag.")

		return true -- consumes the item
	end
}

-- drug item, follows medical junkify rules: common drug/medical item: 4-10 tokens when junkified
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
