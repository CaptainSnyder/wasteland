ITEM.name = "Bottle of Vodka"
ITEM.model = Model("models/vodka.mdl")
ITEM.description = "[COMMON] A bottle of vodka. A few swigs will get you drunk."
ITEM.category = "Consumable"
ITEM.price = 5
ITEM.width = 1
ITEM.height = 2

local DRINK_SOUNDS = {
	"item_vodka_02_drink.wav",
	"item_vodka_02_drink2.wav",
	"item_vodka_02_drink3.wav"
}

ITEM.functions.Drink = {
	name = "Drink",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		if (ApplyCharacterCondition) then
			ApplyCharacterCondition(character, "drunk")
		end

		client:EmitSound(DRINK_SOUNDS[math.random(#DRINK_SOUNDS)], 70)
		client:Notify("You take a swig and feel the warmth spread through you.")

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
