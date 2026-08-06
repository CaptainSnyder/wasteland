ITEM.name = "Painkillers"
ITEM.description = "Relieves pain and grants a temporary boost to physical toughness."
ITEM.model = "models/items/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 75
ITEM.category = "Aid"

local HEAL_AMOUNT = 10

ITEM.functions.UseSelf = {
    name = "Use on Self",
    OnRun = function(item, data)
        local client = item.player
        local character = client:GetCharacter()

        if (!character) then
            return false
        end

        client:SetHealth(math.min(client:Health() + HEAL_AMOUNT, client:GetMaxHealth()))

        if (ApplyCharacterCondition) then
            ApplyCharacterCondition(character, "painkillers")
        end

        client:Notify("You feel a surge of strength as the painkillers kick in.")

        return true -- consumes the item
    end
}

ITEM.functions.UseOnOther = {
    name = "Use on Other",
    OnRun = function(item, data)
        local client = item.player
        local target = GetOtherTreatmentTarget(client)

        if (!target) then
            client:Notify("You aren't aiming at anyone within reach.")
            return false
        end

        local character = target:GetCharacter()

        if (!character) then
            return false
        end

        target:SetHealth(math.min(target:Health() + HEAL_AMOUNT, target:GetMaxHealth()))

        if (ApplyCharacterCondition) then
            ApplyCharacterCondition(character, "painkillers")
        end

        target:Notify("You feel a surge of strength as the painkillers kick in.")
        client:Notify("You give " .. target:Name() .. " a dose of painkillers.")

        return true -- consumes the item
    end
}

-- uncommon medical item: 8-30 tokens when junkified
ITEM.functions.Junkify = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local character = client:GetCharacter()
        character:GiveMoney(ix.config.Get("rationTokens", math.random(8, 30)))
        client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
    end
}
