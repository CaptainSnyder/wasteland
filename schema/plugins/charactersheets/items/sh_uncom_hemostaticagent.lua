ITEM.name = "Hemostatic Agent"
ITEM.description = "A fast-acting powder that clots a wound before you bleed out."
ITEM.model = "models/silver/outbreak/items/item_hemostatic.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 75

local HEAL_AMOUNT = 10

-- treats light and moderate bleeding; severe bleeding needs the IFAK
ITEM.curesConditions = {"lightbleeding", "moderatebleeding"}

ITEM.functions.UseSelf = {
    name = "Use on Self",
    OnRun = function(item, data)
        local client = item.player
        local region = data and data.region
        local character = client:GetCharacter()

        if (!character) then
            return false
        end

        client:SetHealth(math.min(client:Health() + HEAL_AMOUNT, client:GetMaxHealth()))

        local curedAny = false

        for _, conditionID in ipairs(item.curesConditions) do
            if (RemoveCharacterCondition and RemoveCharacterCondition(character, conditionID, region)) then
                curedAny = true
            end
        end

        if (curedAny) then
            client:Notify("The bleeding stops.")
        else
            client:Notify("You aren't bleeding.")
        end

        return true
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

        local region = data and data.region
        local character = target:GetCharacter()

        if (!character) then
            return false
        end

        target:SetHealth(math.min(target:Health() + HEAL_AMOUNT, target:GetMaxHealth()))

        local curedAny = false

        for _, conditionID in ipairs(item.curesConditions) do
            if (RemoveCharacterCondition and RemoveCharacterCondition(character, conditionID, region)) then
                curedAny = true
            end
        end

        if (curedAny) then
            target:Notify("The bleeding stops.")
            client:Notify("You stop " .. target:Name() .. "'s bleeding.")
        else
            client:Notify(target:Name() .. " isn't bleeding.")
        end

        return true
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
