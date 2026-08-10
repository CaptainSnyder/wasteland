ITEM.name = "Ratchet"
ITEM.model = Model("models/katharsmodels/syringe_out/syringe_out.mdl")
ITEM.description = "[COMMON] Popular with mechanics and people who open things that belong to other people."
ITEM.category = "Drugs"
ITEM.price = 20
ITEM.width = 1
ITEM.height = 1
-- percent chance per injection of picking up the Drug Addict trait
ITEM.addictionChance = 5

ITEM.functions.Inject = {
	name = "Inject",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()

		if (!character) then
			return false
		end

		if (ApplyCharacterCondition) then
			ApplyCharacterCondition(character, "ratchet")
		end

		if (RollForAddiction) then
			RollForAddiction(client, item.addictionChance)
		end

		client:EmitSound("items/medshot4.wav", 70)
		client:Notify("The world narrows to whatever is in front of your hands.")

		return true -- consumes the syringe
	end
}

-- drugs follow the medical junkify table, not the consumable one
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
