ITEM.name = "IFAK"
ITEM.description = "A military-grade trauma kit built to stop bleeding and fight off infection in the field."
ITEM.model = "models/illusion/eftcontainers/ifak.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 150

local HEAL_AMOUNT = 10

-- treats every tier of bleeding plus infection, unlike the Hemostatic Agent which can't touch severe bleeding
ITEM.curesConditions = {"lightbleeding", "moderatebleeding", "severebleeding", "infection"}

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
            client:Notify("The kit stops the bleeding and treats the infection.")
        else
            client:Notify("You don't have any injuries this kit can treat.")
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
            target:Notify("The kit stops the bleeding and treats the infection.")
            client:Notify("You treat " .. target:Name() .. " with the IFAK.")
        else
            client:Notify(target:Name() .. " doesn't have any injuries this kit can treat.")
        end

        return true
    end
}

-- rare medical item: 15-50 tokens when junkified
ITEM.functions.Junkify = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local character = client:GetCharacter()
        character:GiveMoney(ix.config.Get("rationTokens", math.random(15, 50)))
        client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
    end
}
