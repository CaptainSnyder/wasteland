ITEM.name = "Aluminum Splint"
ITEM.description = "Rigid enough to pop a dislocated joint back where it belongs."
ITEM.model = "models/silver/outbreak/items/item_alusplint.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Aid"
ITEM.price = 75

local HEAL_AMOUNT = 10

ITEM.curesConditions = {"dislocatedshoulder"}

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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "dislocatedshoulder", region)

        if (cured) then
            client:Notify("You pop the joint back into place.")
        else
            client:Notify("Nothing feels out of place.")
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

        local cured = RemoveCharacterCondition and RemoveCharacterCondition(character, "dislocatedshoulder", region)

        if (cured) then
            target:Notify("You pop the joint back into place.")
            client:Notify("You pop " .. target:Name() .. "'s shoulder back into place.")
        else
            client:Notify(target:Name() .. "'s shoulder isn't dislocated.")
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
