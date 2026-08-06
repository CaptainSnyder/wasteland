ITEM.name = "Golden Star Balm"
ITEM.description = "An old-world remedy that fades even the worst scars with regular use."
ITEM.model = "models/illusion/eftcontainers/goldenstarbalm.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 150

local HEAL_AMOUNT = 10

ITEM.curesConditions = {"disfiguringscar"}

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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "disfiguringscar", region)

        if (cured) then
            client:Notify("The scar fades away.")
        else
            client:Notify("You don't have a scar to treat.")
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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "disfiguringscar", region)

        if (cured) then
            target:Notify("The scar fades away.")
            client:Notify("You treat " .. target:Name() .. "'s scar.")
        else
            client:Notify(target:Name() .. " doesn't have a scar to treat.")
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
