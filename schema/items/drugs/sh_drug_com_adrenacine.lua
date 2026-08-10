ITEM.name = "Adrenacine"
ITEM.model = Model("models/katharsmodels/syringe_out/syringe_out.mdl")
ITEM.description = "[COMMON] A cardiac stimulant. The label warns against use by anyone with a heart condition, in very small print."
ITEM.category = "Drugs"
ITEM.price = 20
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
			ApplyCharacterCondition(character, "adrenacine")
		end

		client:EmitSound("items/medshot4.wav", 70)
		client:Notify("Your heart kicks and the world slows down a step.")

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
