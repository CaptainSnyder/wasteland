PLUGIN.name = "Scavenging"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Placeable scavenging containers that reward loot based on a Scavenging or Lockpicking skill roll."

-- items eligible to be found while scavenging: junk and medical/aid items only (no crafting
-- materials, no weapons), tiered to match the loot bands in ResolveScavengeResult. the category
-- skill books were added to the rare pool alongside the rare medical items - true skill books are
-- deliberately left out, they stay vendor/reward-only
PLUGIN.lootTable = {
    common = {
        "junk_arcadetoken", "junk_bloodsample", "junk_brokenlaptop", "junk_brokenphone",
        "junk_cameralens", "junk_catfigurine", "junk_controller", "junk_dollarbill",
        "junk_euro", "junk_goldchain", "junk_lightbulb", "junk_lionstatue",
        "junk_noveltycoin", "junk_rolexwatch", "junk_roubles", "junk_skullring",
        "junk_toiletpaper", "junk_toyhorse",
        "com_splint", "com_aspirin", "com_elasticwrap", "com_antinauseameds",
        "com_coldcompress", "medical_com_bandage"
    },
    uncommon = {
        "uncom_ibuprofen", "uncom_hemostaticagent", "uncom_alusplint",
        "uncom_antibiotics", "uncom_painkillers"
    },
    rare = {
        "rare_goldenstarbalm", "rare_traumakit", "rare_ifak", "rare_bloodtransfusionkit",
        "book_cat_combat", "book_cat_general", "book_cat_exploration", "book_cat_social"
    }
}

local lootTable = PLUGIN.lootTable

-- formats a countdown in seconds as "X hour(s) and Y minute(s)" for the "come back later" notice
function FormatSearchCooldown(remainingSeconds)
    local totalMinutes = math.max(1, math.ceil(remainingSeconds / 60))
    local hours = math.floor(totalMinutes / 60)
    local minutes = totalMinutes % 60

    if (hours > 0 and minutes > 0) then
        return string.format("%d hour%s and %d minute%s", hours, hours == 1 and "" or "s", minutes, minutes == 1 and "" or "s")
    elseif (hours > 0) then
        return string.format("%d hour%s", hours, hours == 1 and "" or "s")
    else
        return string.format("%d minute%s", minutes, minutes == 1 and "" or "s")
    end
end

if (SERVER) then
    -- turns a completed PerformSkillCheck() roll (see charactersheets/sh_plugin.lua) into a loot tier
    -- and grants an item from that tier; base 10 to find anything at all, 10-16 common, 17+ uncommon,
    -- and a natural 20 always guarantees a rare regardless of total bonuses
    function ResolveScavengeResult(client, diceRoll, result)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local hasScrapFinder = table.HasValue(character:GetData("traits", {}), "scrapfinder")
        local tier

        if (diceRoll == 20) then
            tier = "rare"
        elseif (result >= 17) then
            tier = "uncommon"
        elseif (result >= 10) then
            tier = "common"
        end

        if (!tier) then
            client:Notify("You search but don't find anything useful.")

            if (hasScrapFinder) then
                local scrap = math.random(1, 20)
                character:GiveMoney(scrap)
                client:Notify("Even so, you scrounge up " .. scrap .. " scrap.")
            end

            return
        end

        local pool = lootTable[tier]
        local uniqueID = pool[math.random(#pool)]
        local itemTable = ix.item.list[uniqueID]

        if (!itemTable) then
            return
        end

        local x = character:GetInventory():Add(uniqueID)

        if (x) then
            client:Notify("You scavenge up: " .. itemTable.name .. "!")
        else
            client:Notify("You find a " .. itemTable.name .. ", but your inventory is full.")
        end

        if (hasScrapFinder) then
            local scrap = math.random(1, 10)
            character:GiveMoney(scrap)
            client:Notify("You also scrounge up " .. scrap .. " scrap.")
        end
    end
end
