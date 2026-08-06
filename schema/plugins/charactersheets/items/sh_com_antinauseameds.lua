ITEM.name = "Anti-Nausea Meds"
ITEM.description = "Settles a rough stomach and stops the nausea in its tracks."
ITEM.model = "models/items/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 20

local HEAL_AMOUNT = 10

ITEM.curesConditions = {"foodpoisoning"}

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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "foodpoisoning", region)

        if (cured) then
            client:Notify("Your stomach settles down.")
        else
            client:Notify("You don't feel sick.")
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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "foodpoisoning", region)

        if (cured) then
            target:Notify("Your stomach settles down.")
            client:Notify("You settle " .. target:Name() .. "'s stomach.")
        else
            client:Notify(target:Name() .. " doesn't feel sick.")
        end

        return true
    end
}

-- common medical item: 4-10 tokens when junkified
ITEM.functions.Junkify = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local character = client:GetCharacter()
        character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
        client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
    end
}
