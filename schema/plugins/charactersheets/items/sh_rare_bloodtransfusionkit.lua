ITEM.name = "Blood Transfusion Kit"
ITEM.description = "A bagged unit of blood and the tubing to get it into you before it's too late."
ITEM.model = "models/silver/outbreak/items/item_bloodbag.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 150

local HEAL_AMOUNT = 10

ITEM.curesConditions = {"bloodloss"}

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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "bloodloss", region)

        if (cured) then
            client:Notify("Color returns to your face as the transfusion takes hold.")
        else
            client:Notify("You haven't lost enough blood to need this.")
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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "bloodloss", region)

        if (cured) then
            target:Notify("Color returns to your face as the transfusion takes hold.")
            client:Notify("You give " .. target:Name() .. " a transfusion.")
        else
            client:Notify(target:Name() .. " doesn't need a transfusion.")
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
