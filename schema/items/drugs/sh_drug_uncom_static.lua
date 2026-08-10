ITEM.name = "Static"
ITEM.model = Model("models/katharsmodels/syringe_out/syringe_out.mdl")
ITEM.description = "[UNCOMMON] Cooked out of leaking cells by someone who should not have survived doing it."
ITEM.category = "Drugs"
ITEM.price = 75
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Inject = {
	name = "Inject",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		if (ApplyCharacterCondition) then
			ApplyCharacterCondition(character, "static")
		end

		client:EmitSound("items/medshot4.wav", 70)
		client:Notify("You can hear the charge humming in your teeth.")

		return true -- consumes the syringe
	end
}

-- drugs follow the medical junkify table, not the consumable one
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(8, 30)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
