ITEM.name = "Nova"
ITEM.model = Model("models/katharsmodels/syringe_out/syringe_out.mdl")
ITEM.description = "[RARE] Nobody agrees on what is in it. Everyone agrees on what it does, and on what happens after."
ITEM.category = "Drugs"
ITEM.price = 150
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
			ApplyCharacterCondition(character, "nova")
		end

		client:EmitSound("items/medshot4.wav", 70)
		client:Notify("It hits like a door opening onto the sun.")

		return true -- consumes the syringe
	end
}

-- drugs follow the medical junkify table, not the consumable one
ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(15, 50)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
