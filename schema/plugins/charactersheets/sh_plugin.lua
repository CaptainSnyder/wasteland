PLUGIN.name = "Character Sheets"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Displays a character sheet interface for players, and handles attribute/skill dice rolling."

ix.util.Include("sh_skills.lua")
ix.util.Include("sh_traits.lua")
ix.util.Include("sh_conditions.lua")
ix.util.Include("sh_charsetup.lua")
ix.util.Include("cl_bodydiagram.lua")
ix.util.Include("cl_charsheet_tab.lua")
ix.util.Include("cl_sheet.lua")
ix.util.Include("cl_traits.lua")
ix.util.Include("cl_buytraits.lua")
ix.util.Include("cl_pickpocket.lua")
ix.util.Include("cl_conditions.lua")
ix.util.Include("cl_charsetup.lua")

local charSetupStages = PLUGIN.charSetupStages

local skillList = PLUGIN.skills
local skillLevelCost = PLUGIN.skillLevelCost
local traitList = PLUGIN.traits

-- trait purchasing. buying a trait costs more the more you've already bought, on exactly the curve
-- skills use: the Nth trait you buy costs skillLevelCost[N]. only traits actually *bought* escalate
-- the price - origin traits from character setup and GM-rewarded ones are free of this entirely
local MAX_PURCHASED_TRAITS = 10
local MAX_TRAIT_POINTS = 0

for i = 1, MAX_PURCHASED_TRAITS do
    MAX_TRAIT_POINTS = MAX_TRAIT_POINTS + (skillLevelCost[i] or 0)
end

PLUGIN.maxPurchasedTraits = MAX_PURCHASED_TRAITS
PLUGIN.maxTraitPoints = MAX_TRAIT_POINTS

-- how a character came by a trait. anything with no recorded source predates this system, and is
-- treated as an origin trait since character setup is where nearly all of them came from
local TRAIT_SOURCE_LABELS = {
    origin = "Origin Trait",
    purchased = "Purchased Trait",
    rewarded = "Rewarded Trait"
}

local function GetTraitSource(character, traitID)
    return character:GetData("traitSources", {})[traitID] or "origin"
end

local function SetTraitSource(character, traitID, source)
    local sources = character:GetData("traitSources", {})

    sources[traitID] = source
    character:SetData("traitSources", sources)
end

-- counted off the live trait list rather than the source table directly, so a leftover entry from a
-- trait that was later removed can never keep inflating the price of the next purchase
local function GetPurchasedTraitCount(character)
    local sources = character:GetData("traitSources", {})
    local count = 0

    for _, tid in ipairs(character:GetData("traits", {})) do
        if (sources[tid] == "purchased") then
            count = count + 1
        end
    end

    return count
end

-- nil once the cap is reached, meaning there is no next purchase left to put a price on
local function GetNextTraitCost(character)
    local purchased = GetPurchasedTraitCount(character)

    if (purchased >= MAX_PURCHASED_TRAITS) then
        return nil
    end

    return skillLevelCost[purchased + 1]
end
local conditionList = PLUGIN.conditions
local bodyRegions = PLUGIN.bodyRegions
local bleedingTiers = PLUGIN.bleedingTiers

local traitsByID = {}

for _, trait in ipairs(traitList) do
    traitsByID[trait.id] = trait
end

-- returns the trait a character already has that clashes with one they're trying to take, or nil.
-- checked in both directions, so only one side of a conflicting pair has to declare it - Holy Healer
-- lists Atheist, and Atheist doesn't need to know Holy Healer exists
local function GetConflictingTrait(character, trait)
    for _, tid in ipairs(character:GetData("traits", {})) do
        if (tid != trait.id) then
            if (trait.conflictsWith and table.HasValue(trait.conflictsWith, tid)) then
                return traitsByID[tid]
            end

            local ownedTrait = traitsByID[tid]

            if (ownedTrait and ownedTrait.conflictsWith and table.HasValue(ownedTrait.conflictsWith, trait.id)) then
                return ownedTrait
            end
        end
    end

    return nil
end

local conditionsByID = {}

for _, condition in ipairs(conditionList) do
    conditionsByID[condition.id] = condition
end

local bodyRegionIDs = {}

for _, region in ipairs(bodyRegions) do
    bodyRegionIDs[#bodyRegionIDs + 1] = region.id
end

local skillsByID = {}
local skillsByCategory = {}

for _, skill in ipairs(skillList) do
    skillsByID[skill.id] = skill
    skillsByCategory[skill.category] = skillsByCategory[skill.category] or {}
    table.insert(skillsByCategory[skill.category], skill)
end

-- shared accessors so item files (which run long after PLUGIN has moved on to other plugins) can
-- safely look up skill data without touching PLUGIN.skills directly
function FindSkillByID(id)
    return skillsByID[id]
end

function GetSkillsInCategory(category)
    return skillsByCategory[category] or {}
end

-- checks whether a specific body region is a legal location for a given condition template
local function IsRegionValidForCondition(conditionDef, region)
    local scope = conditionDef.regionScope or "general"

    if (scope == "fixed") then
        return conditionDef.region == region
    elseif (scope == "choice") then
        return table.HasValue(conditionDef.regionOptions, region)
    elseif (scope == "any") then
        return table.HasValue(bodyRegionIDs, region)
    end

    return false -- "general" conditions are never claimed by a specific-region cure
end

-- returns a character's currently active (non-expired) conditions, pruning any expired ones from storage,
-- and synthesizing "Withdrawal" on the fly for anyone with the Drug Addict trait who doesn't currently
-- have a condition active that's flagged suppressesWithdrawal (Drunk, High, and any future drug/medicine
-- condition that should count as "got their fix" just needs that flag set - see sh_conditions.lua)
local function GetActiveConditions(character)
    local conditions = character:GetData("conditions", {})
    local now = os.time()
    local active = {}
    local withdrawalSuppressed = false

    for _, cond in ipairs(conditions) do
        -- a missing expiresAt means corrupt/legacy data - treat it as expired so it gets pruned
        -- below instead of crashing every skill check for this character
        if (cond.expiresAt and cond.expiresAt > now) then
            active[#active + 1] = cond

            local conditionDef = conditionsByID[cond.sourceId]

            if (conditionDef and conditionDef.suppressesWithdrawal) then
                withdrawalSuppressed = true
            end
        end
    end

    if (#active != #conditions) then
        character:SetData("conditions", active)
    end

    if (!withdrawalSuppressed) then
        local traitIDs = character:GetData("traits", {})

        if (table.HasValue(traitIDs, "drugaddict")) then
            local withdrawalDef = conditionsByID["withdrawal"]

            if (withdrawalDef) then
                active[#active + 1] = {
                    sourceId = "withdrawal",
                    name = withdrawalDef.name,
                    description = withdrawalDef.description,
                    modifiers = withdrawalDef.modifiers
                    -- deliberately no expiresAt - this is an ongoing derived state, not a timed condition
                }
            end
        end
    end

    return active
end

-- applies (or refreshes, if already active) a condition template to a character; called by consumable items
-- removes an active condition (by its template id) from a character, if present; returns true if one was actually removed
-- region is optional: omitted (nil) removes every instance of this condition regardless of location (used by
-- the normal item "Use on Self/Other" path); given, removes at most one instance - the one at that exact region,
-- or a legacy region-less instance if that region is a legal location for this condition (used by the Health
-- tab's per-region treatment menu)
function RemoveCharacterCondition(character, conditionID, region)
    local conditions = character:GetData("conditions", {})
    local removed = false
    local remaining = {}

    if (region == nil) then
        for _, cond in ipairs(conditions) do
            if (cond.sourceId == conditionID) then
                removed = true
            else
                remaining[#remaining + 1] = cond
            end
        end
    else
        local conditionDef = conditionsByID[conditionID]
        local matchedOne = false

        for _, cond in ipairs(conditions) do
            local isMatch = (!matchedOne) and (cond.sourceId == conditionID) and (
                cond.region == region or
                (cond.region == nil and conditionDef and IsRegionValidForCondition(conditionDef, region))
            )

            if (isMatch) then
                removed = true
                matchedOne = true
            else
                remaining[#remaining + 1] = cond
            end
        end
    end

    if (removed) then
        character:SetData("conditions", remaining)
    end

    return removed
end

-- durationHoursOverride optionally overrides the condition's own default duration (used by /CharGiveCondition)
-- region is optional and only meaningful for "choice"/"any" scope conditions - see IsRegionValidForCondition
-- modifiersOverride lets a caller supply per-instance modifiers instead of the template's static ones -
-- used by /pray, since which skill it boosts (and by how much) varies by use and by the Religious trait
-- `extra` carries per-instance overrides for conditions whose effect is decided at the moment they're
-- applied rather than fixed on the template:
--   effectText      - /athletics rolls a different speed percentage every time
--   advantageSkills - /rally grants advantage on whichever skill the leader called
-- both travel with the instance, so two characters can hold the same condition doing different things
function ApplyCharacterCondition(character, conditionID, durationHoursOverride, region, modifiersOverride, extra)
    local conditionDef = conditionsByID[conditionID]

    if (!conditionDef) then
        return false
    end

    local scope = conditionDef.regionScope or "general"
    local resolvedRegion

    if (scope == "fixed") then
        resolvedRegion = conditionDef.region
    elseif (scope == "choice") then
        if (region and table.HasValue(conditionDef.regionOptions, region)) then
            resolvedRegion = region
        else
            resolvedRegion = conditionDef.regionOptions[math.random(#conditionDef.regionOptions)]
        end
    elseif (scope == "any") then
        if (region and table.HasValue(bodyRegionIDs, region)) then
            resolvedRegion = region
        else
            resolvedRegion = "uppertorso"
        end
    end
    -- "general" scope leaves resolvedRegion as nil

    local conditions = character:GetData("conditions", {})
    local now = os.time()
    local durationSeconds = (durationHoursOverride or conditionDef.durationHours or 1) * 3600
    local existing

    for _, cond in ipairs(conditions) do
        if (cond.sourceId == conditionID) then
            if (scope == "fixed" or scope == "general" or cond.region == resolvedRegion) then
                existing = cond
                break
            end
        end
    end

    extra = extra or {}

    if (existing) then
        existing.expiresAt = now + durationSeconds
        existing.region = resolvedRegion
        existing.modifiers = modifiersOverride or existing.modifiers
        existing.effectText = extra.effectText or existing.effectText
        existing.advantageSkills = extra.advantageSkills or existing.advantageSkills
    else
        table.insert(conditions, {
            id = tostring(now) .. "_" .. tostring(math.random(1000, 9999)),
            sourceId = conditionID,
            name = conditionDef.name,
            description = conditionDef.description,
            expiresAt = now + durationSeconds,
            modifiers = modifiersOverride or conditionDef.modifiers,
            effectText = extra.effectText,
            advantageSkills = extra.advantageSkills,
            region = resolvedRegion
        })
    end

    character:SetData("conditions", conditions)

    return true
end

-- returns the player within arm's reach of the user's aim, or nil if nobody's there - used by each item's explicit "Use on Other" option
function GetOtherTreatmentTarget(client)
    local startPos = client:GetShootPos()
    local trace = util.TraceLine({
        start = startPos,
        endpos = startPos + client:GetAimVector() * 96,
        filter = client,
        mask = MASK_SHOT
    })

    if (IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity != client) then
        return trace.Entity
    end

    return nil
end

if (SERVER) then
    util.AddNetworkString("ixOpenCharSheet")
    util.AddNetworkString("ixCharSheetSetBio")
    util.AddNetworkString("ixCharSheetSetPic")
    util.AddNetworkString("ixCharSheetSetNotes")
    util.AddNetworkString("ixCharSheetSpendSkill")
    util.AddNetworkString("ixCharSheetSetInfo")
    util.AddNetworkString("ixCharSheetSetBiography")
    util.AddNetworkString("ixCharSheetSetQuote")
    util.AddNetworkString("ixCharSheetAddRelationship")
    util.AddNetworkString("ixCharSheetEditRelationship")
    util.AddNetworkString("ixCharSheetDeleteRelationship")
    util.AddNetworkString("ixOpenTraitList")
    util.AddNetworkString("ixOpenTraitPurchase")
    util.AddNetworkString("ixPickpocketRequest")
    util.AddNetworkString("ixPickpocketResponse")
    util.AddNetworkString("ixPickpocketWaiting")
    util.AddNetworkString("ixPickpocketCancel")
    util.AddNetworkString("ixPickpocketDismiss")
    util.AddNetworkString("ixCharSheetBuyTrait")
    util.AddNetworkString("ixOpenConditionList")
    util.AddNetworkString("ixOpenHealthConditionList")
    util.AddNetworkString("ixOpenCharSetup")
    util.AddNetworkString("ixSubmitCharSetup")
    util.AddNetworkString("ixCharSetupReminder")

    -- pops up a "you haven't run /charsetup yet" reminder that has to be dismissed with its close
    -- button, every time a player loads into a character that hasn't finished it
    function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
        if (character and !character:GetData("charSetupDone", false)) then
            net.Start("ixCharSetupReminder")
            net.Send(client)
        end
    end
end

hook.Add("InitializedChatClasses", "ixAttributeRollChat", function()
    ix.chat.Register("attribroll", {
        format = "",
        color = Color(217, 179, 92),
        CanHear = ix.config.Get("chatRange", 280),
        deadCanChat = true,
        -- fully custom rendering so a single line can contain multiple colored segments
        -- (e.g. one die colored green because it was the one used with advantage, another grayed out as unused)
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local segments = {Color(255, 255, 255), "** ", speaker, " rolled "}

            if (info and info.diceSegments) then
                for _, seg in ipairs(info.diceSegments) do
                    table.insert(segments, seg.color)
                    table.insert(segments, seg.text)
                end
            else
                table.insert(segments, self.color)
                table.insert(segments, text)
            end

            table.insert(segments, Color(255, 255, 255))
            table.insert(segments, ".")

            chat.AddText(unpack(segments))
        end
    })
end)

-- returns an attribute's value plus any trait-based or active-condition-based bonuses/penalties to that attribute
local function GetEffectiveAttribute(character, attribID)
    local value = character:GetAttribute(attribID, 0)
    local traitIDs = character:GetData("traits", {})

    for _, tid in ipairs(traitIDs) do
        local trait = traitsByID[tid]

        if (trait) then
            for _, mod in ipairs(trait.modifiers or {}) do
                if (mod.type == "attribute" and mod.target == attribID) then
                    value = value + mod.amount
                elseif (mod.type == "allAttributes") then
                    value = value + mod.amount
                end
            end
        end
    end

    for _, cond in ipairs(GetActiveConditions(character)) do
        for _, mod in ipairs(cond.modifiers or {}) do
            if (mod.type == "attribute" and mod.target == attribID) then
                value = value + mod.amount
            elseif (mod.type == "allAttributes") then
                value = value + mod.amount
            end
        end
    end

    return value
end

-- returns "advantage", "disadvantage", or "normal" for rolling a specific attribute, based on the
-- character's traits and active conditions (e.g. Dying of Starvation forcing disadvantage on everything)
local function GetAttributeRollMode(character, attribID)
    local traitIDs = character:GetData("traits", {})
    local hasAdvantage = false
    local hasDisadvantage = false

    for _, tid in ipairs(traitIDs) do
        local trait = traitsByID[tid]

        if (trait) then
            if (trait.advantageAllAttributes) then
                hasAdvantage = true
            end

            if (trait.advantageAttributes and table.HasValue(trait.advantageAttributes, attribID)) then
                hasAdvantage = true
            end

            if (trait.disadvantageAttributes and table.HasValue(trait.disadvantageAttributes, attribID)) then
                hasDisadvantage = true
            end

            if (trait.disadvantageAllAttributes) then
                hasDisadvantage = true
            end
        end
    end

    for _, cond in ipairs(GetActiveConditions(character)) do
        local conditionDef = conditionsByID[cond.sourceId]

        if (conditionDef) then
            if (conditionDef.advantageAllAttributes) then
                hasAdvantage = true
            end

            if (conditionDef.advantageAttributes and table.HasValue(conditionDef.advantageAttributes, attribID)) then
                hasAdvantage = true
            end

            if (conditionDef.disadvantageAttributes and table.HasValue(conditionDef.disadvantageAttributes, attribID)) then
                hasDisadvantage = true
            end

            if (conditionDef.disadvantageAllAttributes) then
                hasDisadvantage = true
            end
        end
    end

    if (hasAdvantage and hasDisadvantage) then
        return "normal"
    elseif (hasAdvantage) then
        return "advantage"
    elseif (hasDisadvantage) then
        return "disadvantage"
    end

    return "normal"
end

-- a player can deliberately force a single roll's mode from the character sheet, overriding whatever
-- advantage or disadvantage their traits and conditions would normally produce. the roll commands
-- carry this as a string; anything unrecognized (or absent) falls through to the usual behavior, so
-- every existing caller that passes no mode at all keeps working exactly as before
local forcedRollModes = {
    advantage = "advantage",
    neutral = "normal",
    normal = "normal",
    disadvantage = "disadvantage"
}

-- keyed by the resolved mode rather than the input word, so "neutral" and "normal" both land here
local forcedRollLabels = {
    advantage = " (Guaranteed Advantage)",
    normal = " (Guaranteed Neutral)",
    disadvantage = " (Guaranteed Disadvantage)"
}

-- formats one signed term of the roll readout, e.g. " + 5 (Modifier)" or " - 2 (Automatic Weapons)".
-- negative values print as a subtraction rather than "+ -2", which is what you get from a hardcoded
-- " + %d". applies to skill and attribute totals as much as to modifiers - a character with enough
-- trait or condition penalties can easily end up with a negative total in either
local function FormatRollTerm(amount, label)
    return string.format(" %s %d (%s)", amount >= 0 and "+" or "-", math.abs(amount), label)
end

local function ResolveForcedRollMode(forceMode)
    if (!isstring(forceMode)) then
        return nil
    end

    return forcedRollModes[string.lower(string.Trim(forceMode))]
end

local function PerformAttributeRoll(client, attribID, attribName, modifier, forceMode)
    local character = client:GetCharacter()

    if (!character) then
        return
    end

    -- now uses the effective (trait-adjusted) attribute value, so attribute traits actually affect rolls, not just the sheet's display
    local value = GetEffectiveAttribute(character, attribID)

    -- a forced mode wins outright - GetAttributeRollMode isn't even consulted, so a player who picks
    -- Guaranteed Advantage gets it even when every trait they have says otherwise
    local forcedMode = ResolveForcedRollMode(forceMode)
    local rollMode = forcedMode or GetAttributeRollMode(character, attribID)
    local rollA, rollB, diceRoll

    if (rollMode == "advantage") then
        rollA = math.random(1, 20)
        rollB = math.random(1, 20)
        diceRoll = math.max(rollA, rollB)
    elseif (rollMode == "disadvantage") then
        rollA = math.random(1, 20)
        rollB = math.random(1, 20)
        diceRoll = math.min(rollA, rollB)
    else
        diceRoll = math.random(1, 20)
    end

    local total = diceRoll + value

    local white = Color(255, 255, 255)
    local gray = Color(140, 140, 140)
    local green = Color(90, 200, 100)
    local red = Color(210, 70, 70)

    local segments = {{color = white, text = "a "}}

    if (rollA and rollB) then
        local usedColor = (rollMode == "advantage") and green or red
        local unusedRoll = (diceRoll == rollA) and rollB or rollA

        segments[#segments + 1] = {color = usedColor, text = tostring(diceRoll)}
        segments[#segments + 1] = {color = white, text = "/"}
        segments[#segments + 1] = {color = gray, text = tostring(unusedRoll)}
    else
        segments[#segments + 1] = {color = white, text = tostring(diceRoll)}
    end

    segments[#segments + 1] = {color = white, text = FormatRollTerm(value, attribName)}

    if (modifier and modifier != 0) then
        total = total + modifier
        segments[#segments + 1] = {color = white, text = FormatRollTerm(modifier, "Modifier")}
    end

    segments[#segments + 1] = {color = white, text = string.format(" = %d", total)}

    -- a forced mode is always called out by name, including Guaranteed Neutral, which prints nothing
    -- under the normal path - the point is for everyone reading chat to see the choice was deliberate
    if (forcedMode) then
        segments[#segments + 1] = {color = white, text = forcedRollLabels[forcedMode]}
    elseif (rollMode == "advantage") then
        segments[#segments + 1] = {color = white, text = " (Advantage)"}
    elseif (rollMode == "disadvantage") then
        segments[#segments + 1] = {color = white, text = " (Disadvantage)"}
    end

    if (diceRoll == 20) then
        segments[#segments + 1] = {color = green, text = " (Critical Success!)"}
    elseif (diceRoll == 1) then
        segments[#segments + 1] = {color = red, text = " (Critical Failure!)"}
    end

    ix.chat.Send(client, "attribroll", "", nil, nil, {diceSegments = segments})
    ix.log.Add(client, "roll", total, 20 + value)
end

-- generic command: /RollAttribute <name> [modifier] [mode]
-- mode is "advantage", "neutral", or "disadvantage" and must come *after* a modifier, since Helix
-- drops a nil optional argument out of the list entirely rather than leaving a gap - omitting the
-- modifier would slide the mode into its slot. the character sheet always sends both for this reason
ix.command.Add("RollAttribute", {
    description = "Rolls a 1d20 plus the given attribute, with an optional modifier and an optional forced roll mode (advantage/neutral/disadvantage).",
    arguments = {
        ix.type.string,
        bit.bor(ix.type.number, ix.type.optional),
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnRun = function(self, client, attribName, modifier, forceMode)
        for k, v in pairs(ix.attributes.list) do
            if (ix.util.StringMatches(L(v.name, client), attribName) or ix.util.StringMatches(k, attribName)) then
                PerformAttributeRoll(client, k, L(v.name, client), modifier, forceMode)
                return
            end
        end

        client:NotifyLocalized("Invalid attribute!")
    end
})

-- shorthand commands, all reusing the same function
local attributeShorthands = {
    RollAware = "awareness",
    RollChar = "charisma",
    RollCoord = "coordination",
    RollInt = "intelligence",
    RollLuck = "luck",
    RollSpeed = "speed",
    RollStr = "strength"
}

for command, attribID in pairs(attributeShorthands) do
    ix.command.Add(command, {
        description = "Rolls a 1d20 plus your " .. attribID .. ", with an optional modifier and an optional forced roll mode (advantage/neutral/disadvantage).",
        arguments = {
            bit.bor(ix.type.number, ix.type.optional),
            bit.bor(ix.type.string, ix.type.optional)
        },
        OnRun = function(self, client, modifier, forceMode)
            local attribute = ix.attributes.list[attribID]

            if (attribute) then
                PerformAttributeRoll(client, attribID, L(attribute.name, client), modifier, forceMode)
            end
        end
    })
end

-- keys allowed in the small info fields (Height, Weight, Sex, Age, Reputation, Faction)
local INFO_FIELD_KEYS = {
    height = true,
    weight = true,
    sex = true,
    age = true,
    reputation = true,
    faction = true,
    alignment = true
}

-- recognized image file extensions for a soft check
local IMAGE_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp"}

local function IsLikelyImageURL(url)
    local extension = url:match("%.(%a+)$")

    if (!extension) then
        return false
    end

    extension = extension:lower()

    for _, ext in ipairs(IMAGE_EXTENSIONS) do
        if (extension == ext) then
            return true
        end
    end

    return false
end

-- shared helper: finds a skill definition by name or id
local function FindSkill(skillName)
    for _, skill in ipairs(skillList) do
        if (ix.util.StringMatches(skill.name, skillName) or ix.util.StringMatches(skill.id, skillName)) then
            return skill
        end
    end
end

-- shared helper: finds a trait definition by name or id
local function FindTrait(traitName)
    for _, trait in ipairs(traitList) do
        if (ix.util.StringMatches(trait.name, traitName) or ix.util.StringMatches(trait.id, traitName)) then
            return trait
        end
    end
end

-- returns the combined trait- and active-condition-based bonus/penalty (if any) toward a specific skill
local function GetTraitSkillBonus(character, skillID)
    local bonus = 0
    local traitIDs = character:GetData("traits", {})

    for _, tid in ipairs(traitIDs) do
        local trait = traitsByID[tid]

        if (trait) then
            for _, mod in ipairs(trait.modifiers or {}) do
                if (mod.type == "skill" and mod.target == skillID) then
                    bonus = bonus + mod.amount
                elseif (mod.type == "allSkills") then
                    bonus = bonus + mod.amount
                end
            end
        end
    end

    for _, cond in ipairs(GetActiveConditions(character)) do
        for _, mod in ipairs(cond.modifiers or {}) do
            if (mod.type == "skill" and mod.target == skillID) then
                bonus = bonus + mod.amount
            elseif (mod.type == "allSkills") then
                bonus = bonus + mod.amount
            end
        end
    end

    return bonus
end

-- shared helper: computes a skill's attribute-based modifier for a given character (trait attribute bonuses included, trait skill bonuses are not - those are added separately)
local function GetSkillModifier(character, skill)
    local attrOne = GetEffectiveAttribute(character, skill.attributes[1])
    local attrTwo = GetEffectiveAttribute(character, skill.attributes[2])

    return math.floor((attrOne + attrTwo) / 2)
end

-- returns true if any of the character's traits force an automatic natural 1 on this skill's category
local function IsSkillForcedToFail(character, skill)
    local traitIDs = character:GetData("traits", {})

    for _, tid in ipairs(traitIDs) do
        local trait = traitsByID[tid]

        if (trait and trait.forceFailCategory == skill.category) then
            local exempt = false

            for _, exceptID in ipairs(trait.forceFailExcept or {}) do
                if (exceptID == skill.id) then
                    exempt = true
                    break
                end
            end

            if (!exempt) then
                return true
            end
        end
    end

    return false
end

-- returns "advantage", "disadvantage", or "normal" based on the character's traits (advantage and disadvantage cancel out to normal if both apply)
-- everything a skill adds on top of the raw die: attribute modifier, invested points and trait
-- bonuses. this is the "+ N (Sneaky Shit)" figure the roll line prints, and /pickpocket needs it
-- without rolling anything, so it lives here rather than inline in PerformSkillCheck
function GetSkillFlatBonus(character, skillData)
    local attribMod = GetSkillModifier(character, skillData)
    local invested = character:GetData("skills", {})[skillData.id] or 0

    return attribMod + invested + GetTraitSkillBonus(character, skillData.id)
end

-- extraAdvantage is an advantage source supplied by the caller for this one roll - used by the
-- pickpocket contest, where Secured Wallet grants advantage only on that specific Vigilance check
-- rather than on every one. it feeds the normal calculation, so it still cancels against disadvantage
-- instead of overriding it the way a Guaranteed mode does
local function GetSkillRollMode(character, skill, extraAdvantage)
    local traitIDs = character:GetData("traits", {})
    local hasAdvantage = extraAdvantage == true
    local hasDisadvantage = false

    for _, tid in ipairs(traitIDs) do
        local trait = traitsByID[tid]

        if (trait) then
            if (trait.advantageAllSkills) then
                hasAdvantage = true
            end

            if (trait.advantageSkills and table.HasValue(trait.advantageSkills, skill.id)) then
                hasAdvantage = true
            end

            if (trait.disadvantageSkills and table.HasValue(trait.disadvantageSkills, skill.id)) then
                hasDisadvantage = true
            end

            if (trait.disadvantageAllSkills) then
                hasDisadvantage = true
            end

            if (trait.disadvantageCategory == skill.category) then
                local exempt = false

                for _, exceptID in ipairs(trait.disadvantageExcept or {}) do
                    if (exceptID == skill.id) then
                        exempt = true
                        break
                    end
                end

                if (!exempt) then
                    hasDisadvantage = true
                end
            end
        end
    end

    for _, cond in ipairs(GetActiveConditions(character)) do
        local conditionDef = conditionsByID[cond.sourceId]

        if (conditionDef) then
            if (conditionDef.advantageAllSkills) then
                hasAdvantage = true
            end

            if (conditionDef.advantageSkills and table.HasValue(conditionDef.advantageSkills, skill.id)) then
                hasAdvantage = true
            end

            -- the instance can carry its own list: /rally picks the skill at the moment it's called,
            -- so it can't be declared on the shared template the way a fixed condition's would be
            if (cond.advantageSkills and table.HasValue(cond.advantageSkills, skill.id)) then
                hasAdvantage = true
            end

            if (conditionDef.disadvantageSkills and table.HasValue(conditionDef.disadvantageSkills, skill.id)) then
                hasDisadvantage = true
            end

            if (conditionDef.disadvantageAllSkills) then
                hasDisadvantage = true
            end

            if (conditionDef.disadvantageCategory == skill.category) then
                local exempt = false

                for _, exceptID in ipairs(conditionDef.disadvantageExcept or {}) do
                    if (exceptID == skill.id) then
                        exempt = true
                        break
                    end
                end

                if (!exempt) then
                    hasDisadvantage = true
                end
            end
        end
    end

    if (hasAdvantage and hasDisadvantage) then
        return "normal"
    elseif (hasAdvantage) then
        return "advantage"
    elseif (hasDisadvantage) then
        return "disadvantage"
    end

    return "normal"
end

-- shared 1d20-plus-skill-total roll used by both the /RollSkill command and anything else that needs
-- to force a skill check server-side (e.g. the scavenging plugin's search entities); announces the
-- roll in chat exactly like /RollSkill and returns the total result, the raw die face, and the skill
-- definition so callers can react to the outcome (e.g. a natural 20)
-- forceMode ("advantage"/"neutral"/"disadvantage") overrides the character's traits and conditions for
-- this one roll; leave it nil - as every non-UI caller does - for the usual behavior
function PerformSkillCheck(client, skillID, modifier, forceMode, extraAdvantage)
    local character = client:GetCharacter()

    if (!character) then
        return
    end

    local skillData = FindSkillByID(skillID)

    if (!skillData) then
        return
    end

    modifier = modifier or 0

    local flatBonus = GetSkillFlatBonus(character, skillData)

    -- a forced mode wins outright - GetSkillRollMode isn't even consulted, so a player who picks
    -- Guaranteed Advantage gets it even when every trait they have says otherwise
    local forcedMode = ResolveForcedRollMode(forceMode)
    local rollMode = forcedMode or GetSkillRollMode(character, skillData, extraAdvantage)
    local rollA, rollB, diceRoll

    if (rollMode == "advantage") then
        rollA = math.random(1, 20)
        rollB = math.random(1, 20)
        diceRoll = math.max(rollA, rollB)
    elseif (rollMode == "disadvantage") then
        rollA = math.random(1, 20)
        rollB = math.random(1, 20)
        diceRoll = math.min(rollA, rollB)
    else
        diceRoll = math.random(1, 20)
    end

    local forcedFail = IsSkillForcedToFail(character, skillData)

    if (forcedFail) then
        diceRoll = 1
        rollA, rollB = nil, nil
    end

    local result = diceRoll + flatBonus

    local white = Color(255, 255, 255)
    local gray = Color(140, 140, 140)
    local green = Color(90, 200, 100)
    local red = Color(210, 70, 70)

    local segments = {{color = white, text = "a "}}

    if (rollA and rollB) then
        local usedColor = (rollMode == "advantage") and green or red
        local unusedRoll = (diceRoll == rollA) and rollB or rollA

        segments[#segments + 1] = {color = usedColor, text = tostring(diceRoll)}
        segments[#segments + 1] = {color = white, text = "/"}
        segments[#segments + 1] = {color = gray, text = tostring(unusedRoll)}
    else
        segments[#segments + 1] = {color = white, text = tostring(diceRoll)}
    end

    segments[#segments + 1] = {color = white, text = FormatRollTerm(flatBonus, skillData.name)}

    if (modifier != 0) then
        result = result + modifier
        segments[#segments + 1] = {color = white, text = FormatRollTerm(modifier, "Modifier")}
    end

    segments[#segments + 1] = {color = white, text = string.format(" = %d", result)}

    -- nothing is tagged on a forced natural 1, including a guaranteed mode: the auto-fail trait threw
    -- the dice out entirely, and printing "(Guaranteed Advantage)" next to a 1 would just read as a bug
    if (!forcedFail) then
        if (forcedMode) then
            segments[#segments + 1] = {color = white, text = forcedRollLabels[forcedMode]}
        elseif (rollMode == "advantage") then
            segments[#segments + 1] = {color = white, text = " (Advantage)"}
        elseif (rollMode == "disadvantage") then
            segments[#segments + 1] = {color = white, text = " (Disadvantage)"}
        end
    end

    if (diceRoll == 20) then
        segments[#segments + 1] = {color = green, text = " (Critical Success!)"}
    elseif (diceRoll == 1) then
        segments[#segments + 1] = {color = red, text = " (Critical Failure!)"}
    end

    ix.chat.Send(client, "attribroll", "", nil, nil, {diceSegments = segments})
    ix.log.Add(client, "roll", result, 20 + flatBonus)

    return result, diceRoll, skillData
end

-- see the note on /RollAttribute: the mode has to follow a modifier, so the sheet always sends both
ix.command.Add("RollSkill", {
    description = "Rolls a 1d20 plus a skill's total (modifier + invested points), with an optional forced roll mode (advantage/neutral/disadvantage).",
    arguments = {
        ix.type.string,
        bit.bor(ix.type.number, ix.type.optional),
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnRun = function(self, client, skillName, modifier, forceMode)
        local skillData = FindSkill(skillName)

        if (!skillData) then
            client:Notify("Could not find that skill.")
            return
        end

        PerformSkillCheck(client, skillData.id, modifier, forceMode)
    end
})

-- formats a countdown in seconds as "X hour(s)" / "X minute(s)" / "X hour(s) and Y minute(s)" for /pray's cooldown message
local function FormatWaitTime(remainingSeconds)
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

ix.command.Add("Pray", {
    description = "Prays for guidance, raising one skill by 1 point for 12 hours. Can only be done once every 18 hours.",
    arguments = {
        ix.type.string
    },
    OnRun = function(self, client, skillName)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local traitIDs = character:GetData("traits", {})

        for _, tid in ipairs(traitIDs) do
            local trait = traitsByID[tid]

            if (trait and trait.preventsPray) then
                client:Notify("You have no faith left to pray with.")
                return
            end
        end

        local now = os.time()
        local cooldownUntil = character:GetData("prayerCooldownUntil", 0)

        if (now < cooldownUntil) then
            client:Notify("You must wait " .. FormatWaitTime(cooldownUntil - now) .. " before you can pray again.")
            return
        end

        local skillData = FindSkill(skillName)

        if (!skillData) then
            client:Notify("Could not find that skill.")
            return
        end

        -- Religious doubles the base, then Holy Healer adds its point on top, so the two stack:
        -- 1 normally, 2 with either, 3 with both when the prayer is for First Aid
        local amount = table.HasValue(traitIDs, "religious") and 2 or 1

        if (skillData.id == "firstaid") then
            for _, tid in ipairs(traitIDs) do
                local trait = traitsByID[tid]

                if (trait and trait.boostsPrayerFirstAid) then
                    amount = amount + 1
                    break
                end
            end
        end

        ApplyCharacterCondition(character, "prayer", 12, nil, {
            {type = "skill", target = skillData.id, amount = amount}
        })

        character:SetData("prayerCooldownUntil", now + (18 * 3600))

        client:Notify(string.format("You pray for guidance in %s. (+%d for 12 hours)", skillData.name, amount))
    end
})

-- the cap is on the patient, not the medic: one person can patch up as many others as they like, but
-- nobody gains health this way more than once every 12 hours
local FIRST_AID_COOLDOWN = 12 * 3600
-- a failed attempt only locks the patient out briefly. the 12 hours is the price of actually being
-- healed, and this is just enough to stop the roll being spammed until it lands
local FIRST_AID_FAIL_COOLDOWN = 60
-- 10 on the total, matching the bar the scavenging and harvesting checks already use
local FIRST_AID_SUCCESS_THRESHOLD = 10
local FIRST_AID_HEALTH_CAP = 100
local FIRST_AID_CRIT_BONUS = 10
-- floored at 1 health rather than dealt as real damage, so a botched patch-up can never kill someone
local FIRST_AID_CRIT_FAIL_DAMAGE = 10

ix.command.Add("FirstAid", {
    description = "Rolls First Aid to patch up whoever you're aiming at, or yourself if you aren't. Needs a 10 or better, and anyone can only be healed this way once every 12 hours.",
    OnRun = function(self, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        -- both trait effects are read off declarative flags rather than hardcoded ids, so another
        -- trait can be given either behavior later without touching this command
        local doublesBonus = false

        for _, tid in ipairs(character:GetData("traits", {})) do
            local trait = traitsByID[tid]

            if (trait) then
                if (trait.preventsFirstAid) then
                    client:Notify("Your hands start shaking before you've even begun. You can't do this.")
                    return
                end

                if (trait.doublesFirstAidBonus) then
                    doublesBonus = true
                end
            end
        end

        -- same 96-unit aim trace the medical items use, so "close enough" means the same thing here
        local target = GetOtherTreatmentTarget(client) or client
        local isSelf = target == client
        local targetCharacter = target:GetCharacter()

        if (!targetCharacter) then
            client:Notify("They have no character loaded.")
            return
        end

        if (target:Health() >= FIRST_AID_HEALTH_CAP) then
            client:Notify(isSelf and "You're in perfect health already."
                or (target:Name() .. " is in perfect health already."))

            return
        end

        local now = os.time()
        local readyAt = targetCharacter:GetData("firstAidCooldownUntil", 0)

        if (now < readyAt) then
            client:Notify(string.format("%s can't be patched up again for another %s.",
                isSelf and "You" or target:Name(), FormatWaitTime(readyAt - now)))

            return
        end

        local result, diceRoll = PerformSkillCheck(client, "firstaid")

        if (!result) then
            return
        end

        -- the stored timestamp is what actually gates the command; the condition alongside it is so
        -- the patient can see the lockout on their Health tab. both get the same duration
        local function SetTreatedCooldown(seconds)
            targetCharacter:SetData("firstAidCooldownUntil", now + seconds)
            ApplyCharacterCondition(targetCharacter, "recentlytreated", seconds / 3600)
        end

        -- shared by both ways an attempt can come to nothing without doing harm, so an ordinary
        -- wasted try never costs the full 12 hours
        local function FailAttempt(reason)
            SetTreatedCooldown(FIRST_AID_FAIL_COOLDOWN)
            client:Notify(reason)
        end

        -- checked ahead of the threshold: a natural 1 usually falls under it anyway, and botching it
        -- badly enough to do harm has to take precedence over simply achieving nothing
        if (diceRoll == 1) then
            local hurt = math.min(FIRST_AID_CRIT_FAIL_DAMAGE, target:Health() - 1)

            if (hurt > 0) then
                target:SetHealth(target:Health() - hurt)
            end

            -- the full cooldown, not the short retry one: the wound has been meddled with badly
            -- enough that it needs leaving alone, which is a harsher outcome than simply failing
            SetTreatedCooldown(FIRST_AID_COOLDOWN)

            client:Notify(isSelf and "You make it worse. That's going to bruise."
                or ("You make it worse - " .. target:Name() .. " is hurt by the attempt."))

            if (!isSelf) then
                target:Notify(client:Name() .. " botches the treatment and hurts you.")
            end

            return
        end

        if (result < FIRST_AID_SUCCESS_THRESHOLD) then
            FailAttempt(isSelf and "You fail to provide any first aid."
                or ("You fail to provide any first aid to " .. target:Name() .. "."))

            return
        end

        -- the flat First Aid bonus is whatever the roll added on top of the raw die face - i.e. the
        -- same "+ N (First Aid)" figure the roll line prints, attributes and invested points included
        local flatBonus = result - diceRoll

        if (doublesBonus) then
            flatBonus = flatBonus * 2
        end

        local healAmount = math.floor(diceRoll / 2) + flatBonus

        if (diceRoll == 20) then
            healAmount = healAmount + FIRST_AID_CRIT_BONUS
        end

        -- a roll can clear 10 and still heal nothing if their First Aid bonus is deeply negative,
        -- since the heal uses half the raw die face rather than the total. treated as a failure
        if (healAmount <= 0) then
            FailAttempt(isSelf and "You make a mess of it and end up no better off."
                or ("You make a mess of it and " .. target:Name() .. " is no better off."))

            return
        end

        local before = target:Health()
        local after = math.min(before + healAmount, FIRST_AID_HEALTH_CAP)
        local healed = after - before

        target:SetHealth(after)
        SetTreatedCooldown(FIRST_AID_COOLDOWN)

        if (isSelf) then
            client:Notify(string.format("You patch yourself up, recovering %d health.", healed))
        else
            client:Notify(string.format("You patch up %s, recovering %d health for them.", target:Name(), healed))
            target:Notify(string.format("%s patches you up, recovering %d health.", client:Name(), healed))
        end
    end
})

-- a short burst of movement speed. the percentage is the roll total itself, so anything from 25 up
-- reaches the cap - well within reach of a trained character, which is the point
local ATHLETICS_DURATION = 60
local ATHLETICS_COOLDOWN = 5 * 60
-- a wasted attempt barely costs anything - just enough to stop the roll being spammed
local ATHLETICS_FAIL_COOLDOWN = 15
local ATHLETICS_SUCCESS_THRESHOLD = 10
local ATHLETICS_MAX_PERCENT = 25
-- both of these land *after* the cap, so they genuinely stack past it: a capped 25 plus the trait's
-- 7 plus a critical's 8 is the 40% ceiling
local ATHLETICS_CRIT_PERCENT = 8

-- a critical failure instead: a pulled muscle, slower than normal for as long as the cooldown lasts
local ATHLETICS_INJURY_DURATION = 5 * 60
local ATHLETICS_INJURY_PENALTY = 0.25

-- back to the configured defaults rather than to whatever they were before the boost: those are the
-- same values PostPlayerLoadout uses, so this can't strand anyone at a modified speed
local function ResetMovementSpeed(client)
    if (!IsValid(client)) then
        return
    end

    client:SetWalkSpeed(ix.config.Get("walkSpeed"))
    client:SetRunSpeed(ix.config.Get("runSpeed"))
end

ix.command.Add("Athletics", {
    description = "Rolls Athletics for a burst of speed lasting 1 minute. Needs a 10 or better, and can be attempted every 10 minutes.",
    OnRun = function(self, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local now = os.time()
        local readyAt = character:GetData("athleticsCooldownUntil", 0)

        if (now < readyAt) then
            client:Notify(string.format(
                "You need to catch your breath for another %s.", FormatWaitTime(readyAt - now)
            ))

            return
        end

        local result, diceRoll = PerformSkillCheck(client, "athletics")

        if (!result) then
            return
        end

        -- as with /firstaid, the timestamp is the real gate and the condition is the readout
        local function SetSprintCooldown(seconds)
            character:SetData("athleticsCooldownUntil", now + seconds)
            ApplyCharacterCondition(character, "recentlysprint", seconds / 3600)
        end

        -- checked before the threshold, since a natural 1 almost always lands under it anyway and
        -- the injury has to take precedence over the ordinary failure
        if (diceRoll == 1) then
            local penaltyMultiplier = 1 - ATHLETICS_INJURY_PENALTY

            client:SetWalkSpeed(ix.config.Get("walkSpeed") * penaltyMultiplier)
            client:SetRunSpeed(ix.config.Get("runSpeed") * penaltyMultiplier)

            ApplyCharacterCondition(character, "pulledmuscle", ATHLETICS_INJURY_DURATION / 3600)
            SetSprintCooldown(ATHLETICS_COOLDOWN)

            client:Notify("Something in your leg gives out mid-stride. You're limping.")

            -- the injury runs exactly as long as the cooldown, so the penalty can never still be
            -- running when the next attempt becomes available
            timer.Simple(ATHLETICS_INJURY_DURATION, function()
                ResetMovementSpeed(client)

                if (IsValid(client)) then
                    local activeCharacter = client:GetCharacter()

                    if (activeCharacter == character) then
                        RemoveCharacterCondition(character, "pulledmuscle")
                    end
                end
            end)

            return
        end

        if (result < ATHLETICS_SUCCESS_THRESHOLD) then
            SetSprintCooldown(ATHLETICS_FAIL_COOLDOWN)
            client:Notify("You push yourself and get nowhere.")

            return
        end

        local percent = math.min(result, ATHLETICS_MAX_PERCENT)

        -- applied after the cap rather than before it, so the trait and a critical are a genuine
        -- bonus on top of a maxed roll instead of being swallowed by the ceiling
        for _, tid in ipairs(character:GetData("traits", {})) do
            local trait = traitsByID[tid]

            if (trait and trait.athleticsBonusPercent) then
                percent = percent + trait.athleticsBonusPercent
                break
            end
        end

        if (diceRoll == 20) then
            percent = percent + ATHLETICS_CRIT_PERCENT
        end

        local multiplier = 1 + (percent / 100)

        client:SetWalkSpeed(ix.config.Get("walkSpeed") * multiplier)
        client:SetRunSpeed(ix.config.Get("runSpeed") * multiplier)
        SetSprintCooldown(ATHLETICS_COOLDOWN)

        -- shown under Other Conditions while it lasts. the percentage is rolled fresh each time, so
        -- it rides along on the instance rather than being fixed on the condition template
        ApplyCharacterCondition(
            character, "secondwind", ATHLETICS_DURATION / 3600, nil, nil,
            {effectText = string.format("moving %d%% faster", percent)}
        )

        client:Notify(string.format("You hit your stride - %d%% faster for the next minute.", percent))

        -- the cooldown is ten times the duration, so a second boost can never overlap this timer
        timer.Simple(ATHLETICS_DURATION, function()
            ResetMovementSpeed(client)

            -- cleared alongside the speed so the two always end together, rather than leaving the
            -- condition sitting there for the second or two until it expires on its own
            if (IsValid(client)) then
                local activeCharacter = client:GetCharacter()

                if (activeCharacter == character) then
                    RemoveCharacterCondition(character, "secondwind")
                end
            end
        end)
    end
})

-- returns the first trait a character holds carrying the given flag, or nil. handy where the flag's
-- value matters and not just its presence, e.g. Made for Running's athleticsBonusPercent
local function GetTraitWithFlag(character, flag)
    for _, tid in ipairs(character:GetData("traits", {})) do
        local trait = traitsByID[tid]

        if (trait and trait[flag]) then
            return trait
        end
    end

    return nil
end

-- Rally never affects the caller. That's the whole point of the skill: it's the one thing on the sheet
-- that does nothing for you alone, which is what separates leadership from a personal buff.
-- Anarchist is the deliberate inversion of that - see ralliesSelfOnly below
local RALLY_RADIUS_AT_LEVEL_FIVE = 512
-- an untrained leader can still reach whoever is stood right next to them, rather than the command
-- succeeding and silently affecting nobody
local RALLY_MIN_RADIUS = 128
local RALLY_COOLDOWN = 60 * 60
-- failing doesn't cost the hour, only long enough to stop it being mashed
local RALLY_FAIL_COOLDOWN = 30
local RALLY_SUCCESS_THRESHOLD = 10
local RALLY_DURATION = 5 * 60

ix.command.Add("Rally", {
    description = "Rallies nearby allies for 5 minutes, granting advantage on a skill. Never affects you unless you are an Anarchist, reaches further the more Leadership you have invested, and can only be used once an hour.",
    arguments = {
        ix.type.string
    },
    OnRun = function(self, client, skillName)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local skillData = FindSkill(skillName)

        if (!skillData) then
            client:Notify("Could not find that skill.")
            return
        end

        local now = os.time()
        local readyAt = character:GetData("rallyCooldownUntil", 0)

        if (now < readyAt) then
            client:Notify(string.format(
                "You've nothing left to say for another %s.", FormatWaitTime(readyAt - now)
            ))

            return
        end

        -- Leadership is Social, so the Asshole trait's forced natural 1 already stops this dead
        local result, diceRoll = PerformSkillCheck(client, "leadership")

        if (!result) then
            return
        end

        if (diceRoll == 1) then
            character:SetData("rallyCooldownUntil", now + RALLY_COOLDOWN)
            client:Notify("Nobody so much as looks up. Best to let that one go.")

            return
        end

        if (result < RALLY_SUCCESS_THRESHOLD) then
            character:SetData("rallyCooldownUntil", now + RALLY_FAIL_COOLDOWN)
            client:Notify("Your words don't land.")

            return
        end

        -- scaled off invested points rather than the roll total, so range is something you build
        -- toward deliberately instead of something you get lucky into
        local level = character:GetData("skills", {})["leadership"] or 0
        local radius = math.max(RALLY_MIN_RADIUS, (level / 5) * RALLY_RADIUS_AT_LEVEL_FIVE)

        if (diceRoll == 20) then
            radius = radius * 2
        end

        -- Inspirational Leader adds a second skill drawn from the same category. the pool is built
        -- once, but the pick happens per person down in the loop, so everyone sharpens up in a
        -- different way off the same shout
        local bonusPool

        for _, tid in ipairs(character:GetData("traits", {})) do
            local trait = traitsByID[tid]

            if (trait and trait.rallyBonusSkillInCategory) then
                bonusPool = {}

                for _, candidate in ipairs(GetSkillsInCategory(skillData.category)) do
                    if (candidate.id != skillData.id) then
                        bonusPool[#bonusPool + 1] = candidate
                    end
                end

                break
            end
        end

        local hasBonus = bonusPool and #bonusPool > 0

        -- an Anarchist doesn't lead anyone: their rally reaches themselves and nobody else, which is
        -- the one case where the caller is a valid target
        local selfOnly = GetTraitWithFlag(character, "ralliesSelfOnly") != nil
        local candidates = {}
        -- counted separately from the reached total: an Anarchist in earshot was never rallied, so
        -- they mustn't inflate the count, but the leader should still hear that someone tuned them out
        local ignored = 0

        if (selfOnly) then
            candidates[1] = client
        else
            -- no line of sight test on purpose: someone through a wall can still hear you shouting.
            -- everyone inside the radius is reached, so there's no need to rank them by distance
            local origin = client:GetPos()

            for _, ply in ipairs(player.GetAll()) do
                if (ply != client and IsValid(ply) and ply:Alive() and ply:GetCharacter()) then
                    if (origin:Distance(ply:GetPos()) <= radius) then
                        if (GetTraitWithFlag(ply:GetCharacter(), "refusesRally")) then
                            ignored = ignored + 1
                        else
                            candidates[#candidates + 1] = ply
                        end
                    end
                end
            end
        end

        local reached = 0
        local selfSummary

        for _, ply in ipairs(candidates) do
            local targetCharacter = ply:GetCharacter()

            if (targetCharacter) then
                -- a fresh table per person: sharing one would hand every condition the same list, and
                -- appending a bonus skill would then pile up across everybody
                local grantedSkills = {skillData.id}
                local summary = skillData.name

                if (hasBonus) then
                    local bonusSkill = bonusPool[math.random(#bonusPool)]

                    grantedSkills[#grantedSkills + 1] = bonusSkill.id
                    summary = summary .. " and " .. bonusSkill.name
                end

                -- one Rallied condition per person, matched on sourceId, so a fresh rally replaces
                -- whatever the last one granted rather than stacking alongside it
                ApplyCharacterCondition(targetCharacter, "rallied", RALLY_DURATION / 3600, nil, nil, {
                    advantageSkills = grantedSkills
                })

                -- the self-only case gets its own wording below rather than being told it rallied itself
                if (ply != client) then
                    ply:Notify(string.format(
                        "%s rallies you - advantage on %s for the next 5 minutes.",
                        client:Name(), summary
                    ))
                else
                    selfSummary = summary
                end

                reached = reached + 1
            end
        end

        character:SetData("rallyCooldownUntil", now + RALLY_COOLDOWN)

        if (selfSummary) then
            client:Notify(string.format(
                "You talk yourself into it - advantage on %s for the next 5 minutes.", selfSummary
            ))
        elseif (reached == 0) then
            client:Notify(ignored > 0
                and "You call out. Nobody within earshot is interested in being told what to do."
                or "You call out, but there's nobody in earshot to hear it.")
        else
            -- the leader isn't told which second skill each person got; that's theirs to report back
            local message = string.format(
                "You rally %d %s - advantage on %s for the next 5 minutes%s.",
                reached, reached == 1 and "person" or "people", skillData.name,
                hasBonus and ", and something else besides for each of them" or ""
            )

            if (ignored > 0) then
                message = message .. string.format(" %d didn't really listen.", ignored)
            end

            client:Notify(message)
        end
    end
})

-- Pickpocketing is entirely opt-in on the victim's side: the target chooses Allow, Contest or Block,
-- so there's deliberately no cooldown. A thief who keeps trying can simply be blocked every time,
-- which makes spamming it pointless rather than something the code has to police
local PICKPOCKET_MIN_SCRAP = 10
local PICKPOCKET_BASE_PERCENT = 5
local PICKPOCKET_REQUEST_TIMEOUT = 30
-- the victim isn't prompted straight away, so the moment the window appears doesn't point straight at
-- whoever is stood closest. the thief is held in place by their own window for the whole wait
local PICKPOCKET_DELAY = 3

-- keyed by the victim's SteamID64, holding the one attempt they're currently being asked about, plus
-- a reverse map so a thief cancelling can find their own attempt without scanning
local pendingPickpockets = {}
local pendingPickpocketsByThief = {}

local function ClearPickpocket(entry)
    if (!entry) then
        return
    end

    pendingPickpockets[entry.victimID] = nil
    pendingPickpocketsByThief[entry.thiefID] = nil
end

if (SERVER) then
    ix.command.Add("Pickpocket", {
        description = "Attempts to pick the pocket of whoever you are aiming at. Takes a few seconds, holds you in place while they decide, and they choose whether to allow, contest or block it.",
        OnRun = function(self, client)
            local character = client:GetCharacter()

            if (!character) then
                return
            end

            -- same 96 unit aim trace the medical items and /firstaid use
            local target = GetOtherTreatmentTarget(client)

            if (!target) then
                client:Notify("You aren't aiming at anyone within reach.")
                return
            end

            local targetCharacter = target:GetCharacter()

            if (!targetCharacter) then
                client:Notify("They have no character loaded.")
                return
            end

            if (targetCharacter:GetMoney() <= PICKPOCKET_MIN_SCRAP) then
                client:Notify("Your target doesn't have any scrap to steal!")
                return
            end

            local skillData = FindSkillByID("sneakyshit")

            if (!skillData) then
                return
            end

            local percent = PICKPOCKET_BASE_PERCENT + GetSkillFlatBonus(character, skillData)

            -- Secured Wallet halves the percentage, rounding down, so an 11% lift becomes 5%
            if (GetTraitWithFlag(targetCharacter, "halvesPickpocketLoss")) then
                percent = math.floor(percent / 2)
            end

            percent = math.Clamp(percent, 0, 100)

            -- locked in now rather than recalculated on the answer, so the figure shown on the prompt
            -- is the figure that actually changes hands
            local amount = math.max(1, math.floor(targetCharacter:GetMoney() * percent / 100))
            local requestID = math.random(1, 2147483647)
            local victimID = target:SteamID64()
            local thiefID = client:SteamID64()

            local entry = {
                thief = client,
                victim = target,
                thiefID = thiefID,
                victimID = victimID,
                id = requestID,
                amount = amount,
                expiresAt = os.time() + PICKPOCKET_DELAY + PICKPOCKET_REQUEST_TIMEOUT
            }

            pendingPickpockets[victimID] = entry
            pendingPickpocketsByThief[thiefID] = entry

            -- the thief is pinned to this window for the whole attempt. that's the point: they can't
            -- line up a shot while their target reads a prompt, so /pickpocket can't be used to freeze
            -- someone in place and kill them
            net.Start("ixPickpocketWaiting")
            net.Send(client)

            timer.Simple(PICKPOCKET_DELAY, function()
                -- the thief may have backed out during the wait, or the target may have gone
                if (pendingPickpockets[victimID] != entry) then
                    return
                end

                if (!IsValid(target) or !target:GetCharacter()) then
                    ClearPickpocket(entry)

                    if (IsValid(client)) then
                        net.Start("ixPickpocketDismiss")
                        net.Send(client)

                        client:Notify("They're gone before you get the chance.")
                    end

                    return
                end

                entry.promptSent = true

                net.Start("ixPickpocketRequest")
                    net.WriteUInt(requestID, 32)
                    net.WriteUInt(amount, 32)
                    net.WriteUInt(PICKPOCKET_REQUEST_TIMEOUT, 8)
                net.Send(target)
            end)

            -- nothing else prunes an attempt that's simply never answered, so it clears itself
            timer.Simple(PICKPOCKET_DELAY + PICKPOCKET_REQUEST_TIMEOUT + 1, function()
                if (pendingPickpockets[victimID] == entry) then
                    ClearPickpocket(entry)

                    if (IsValid(client)) then
                        net.Start("ixPickpocketDismiss")
                        net.Send(client)

                        client:Notify("They never react. You let it go.")
                    end
                end
            end)

            client:Notify(string.format("You reach for %s's pocket...", target:Name()))
        end
    })

    net.Receive("ixPickpocketCancel", function(length, client)
        local entry = pendingPickpocketsByThief[client:SteamID64()]

        if (!entry) then
            return
        end

        ClearPickpocket(entry)

        -- if the prompt already went out, take it back off their screen rather than leaving them
        -- answering an attempt that no longer exists
        if (entry.promptSent and IsValid(entry.victim)) then
            net.Start("ixPickpocketDismiss")
            net.Send(entry.victim)
        end

        client:Notify("You think better of it and back off.")
    end)

    net.Receive("ixPickpocketResponse", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local requestID = net.ReadUInt(32)
        local choice = net.ReadString()
        local pending = pendingPickpockets[client:SteamID64()]

        -- validated rather than trusted: the id has to match the request the server actually sent to
        -- this specific player, so a crafted message can't invent a theft or answer someone else's
        if (!pending or pending.id != requestID or os.time() > pending.expiresAt) then
            ClearPickpocket(pending)
            return
        end

        ClearPickpocket(pending)

        local thief = pending.thief

        if (!IsValid(thief) or !thief:GetCharacter()) then
            return
        end

        -- the thief's waiting window goes away whatever the answer turns out to be
        net.Start("ixPickpocketDismiss")
        net.Send(thief)

        if (choice == "block") then
            client:Notify("You block the attempt. Please state in LOOC why you blocked it.")
            thief:Notify(string.format("%s blocks the attempt outright.", client:Name()))

            return
        end

        if (choice == "contest") then
            -- both rolls go through PerformSkillCheck, so the whole contest plays out in chat for
            -- anyone nearby to read rather than resolving invisibly
            local sneak = PerformSkillCheck(thief, "sneakyshit")
            local secured = GetTraitWithFlag(character, "securesPickpocketContest") != nil
            local notice = PerformSkillCheck(client, "vigilance", 0, nil, secured)

            if (!sneak or !notice) then
                return
            end

            -- ties go to the thief: the defender has to actually beat them, not just match
            if (notice > sneak) then
                client:Notify("You feel the hand at your pocket and step clear before they find anything.")
                thief:Notify(string.format("%s catches you at it. You come away with nothing.", client:Name()))

                return
            end
        elseif (choice != "allow") then
            return
        end

        -- re-clamped against their balance now, in case it dropped while they were deciding
        local amount = math.min(pending.amount, character:GetMoney())

        if (amount <= 0) then
            thief:Notify("Their pockets are empty by the time you get there.")
            return
        end

        character:TakeMoney(amount)
        thief:GetCharacter():GiveMoney(amount)

        client:Notify(string.format("You come up %d scrap short.", amount))
        thief:Notify(string.format("You lift %d scrap off %s.", amount, client:Name()))
    end)
end

ix.command.Add("CharSetSkill", {
    description = "Sets a character's invested points for a skill (capped at 10).",
    privilege = "Manage Character Skills",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string,
        ix.type.number
    },
    OnRun = function(self, client, target, skillName, amount)
        local skillData = FindSkill(skillName)

        if (!skillData) then
            return "Could not find that skill."
        end

        local modifier = GetSkillModifier(target, skillData)
        amount = math.Clamp(math.floor(amount), 0, 10)

        local invested = target:GetData("skills", {})
        invested[skillData.id] = amount
        target:SetData("skills", invested)

        return string.format("Set %s's %s to %d point(s) invested (total %d).", target:GetName(), skillData.name, amount, modifier + amount)
    end
})

local function FindCondition(conditionName)
    for _, condition in ipairs(conditionList) do
        if (ix.util.StringMatches(condition.name, conditionName) or ix.util.StringMatches(condition.id, conditionName)) then
            return condition
        end
    end
end

-- matches by either the region's display label ("Upper Torso") or its id ("uppertorso")
local function FindBodyRegion(name)
    for _, region in ipairs(bodyRegions) do
        if (ix.util.StringMatches(region.label, name) or ix.util.StringMatches(region.id, name)) then
            return region
        end
    end
end

-- for "other" (non-physical) conditions only - see CharGiveHealthCondition below for anything that
-- belongs on the Health tab
ix.command.Add("CharGiveCondition", {
    description = "Applies an Other Conditions-tab condition to a character for a given duration in hours (default 2).",
    privilege = "Manage Character Conditions",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string,
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, client, target, conditionName, hours)
        local conditionDef = FindCondition(conditionName)

        if (!conditionDef) then
            return "Could not find that condition."
        end

        if (conditionDef.category == "health") then
            return string.format("'%s' is a Health tab condition - use /CharGiveHealthCondition instead.", conditionDef.name)
        end

        hours = hours or 2
        ApplyCharacterCondition(target, conditionDef.id, hours)

        return string.format("Applied '%s' to %s for %g hour(s).", conditionDef.name, target:GetName(), hours)
    end
})

ix.command.Add("CharGiveHealthCondition", {
    description = "Applies a Health tab condition to a character at a specific body region for a given duration in hours.",
    privilege = "Manage Character Conditions",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string,
        ix.type.string,
        ix.type.number
    },
    OnRun = function(self, client, target, conditionName, locationName, hours)
        local conditionDef = FindCondition(conditionName)

        if (!conditionDef) then
            return "Could not find that condition."
        end

        if (conditionDef.category != "health") then
            return string.format("'%s' is an Other Conditions-tab condition - use /CharGiveCondition instead.", conditionDef.name)
        end

        local scope = conditionDef.regionScope or "general"

        if (scope == "general") then
            ApplyCharacterCondition(target, conditionDef.id, hours)

            return string.format("Applied '%s' to %s for %g hour(s). (This condition has no body location - '%s' was ignored.)", conditionDef.name, target:GetName(), hours, locationName)
        end

        local region = FindBodyRegion(locationName)

        if (!region) then
            return "Could not find that body region."
        end

        if (!IsRegionValidForCondition(conditionDef, region.id)) then
            return string.format("'%s' isn't a valid region for '%s'.", region.label, conditionDef.name)
        end

        ApplyCharacterCondition(target, conditionDef.id, hours, region.id)

        return string.format("Applied '%s' to %s's %s for %g hour(s).", conditionDef.name, target:GetName(), region.label, hours)
    end
})

ix.command.Add("CharClearConditions", {
    description = "Immediately clears all active conditions from a character.",
    privilege = "Manage Character Conditions",
    adminOnly = true,
    arguments = ix.type.character,
    OnRun = function(self, client, target)
        target:SetData("conditions", {})

        return string.format("Cleared all active conditions from %s.", target:GetName())
    end
})

ix.command.Add("CharGiveSkillPoints", {
    description = "Grants a character additional skill points to freely spend.",
    privilege = "Manage Character Skills",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.number
    },
    OnRun = function(self, client, target, amount)
        amount = math.floor(amount)
        local pool = target:GetData("skillPoints", 8)
        local newPool = math.max(0, pool + amount)
        target:SetData("skillPoints", newPool)

        return string.format("%s now has %d skill point(s) to spend.", target:GetName(), newPool)
    end
})

ix.command.Add("ViewTraits", {
    description = "Opens a list of all available traits.",
    OnRun = function(self, client)
        net.Start("ixOpenTraitList")
        net.Send(client)
    end
})

ix.command.Add("ViewConditions", {
    description = "Opens a list of all available Other Conditions-tab conditions.",
    OnRun = function(self, client)
        net.Start("ixOpenConditionList")
        net.Send(client)
    end
})

ix.command.Add("ViewHealthConditions", {
    description = "Opens a list of all available Health tab conditions, grouped by body region.",
    OnRun = function(self, client)
        net.Start("ixOpenHealthConditionList")
        net.Send(client)
    end
})

ix.command.Add("CharSetup", {
    description = "Begin your character's one-time narrative setup. This can only be run once.",
    OnRun = function(self, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        if (character:GetData("charSetupDone", false)) then
            client:Notify("You've already completed character setup.")
            return
        end

        local currentAttributes = {}

        for k in pairs(ix.attributes.list) do
            currentAttributes[k] = character:GetAttribute(k, 0)
        end

        net.Start("ixOpenCharSetup")
            net.WriteTable(currentAttributes)
        net.Send(client)
    end
})

if (SERVER) then
    net.Receive("ixSubmitCharSetup", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        if (character:GetData("charSetupDone", false)) then
            client:Notify("You've already completed character setup.")
            return
        end

        local choices = net.ReadTable()
        local skills = character:GetData("skills", {})
        local traits = character:GetData("traits", {})

        for _, stage in ipairs(charSetupStages) do
            local optionID = choices[stage.id]
            local option

            for _, opt in ipairs(stage.options) do
                if (opt.id == optionID) then
                    option = opt
                    break
                end
            end

            if (option) then
                for _, mod in ipairs(option.attributes or {}) do
                    local current = character:GetAttribute(mod.target, 0)
                    character:SetAttrib(mod.target, math.min(current + mod.amount, 10))
                end

                for _, mod in ipairs(option.skills or {}) do
                    skills[mod.target] = math.min((skills[mod.target] or 0) + mod.amount, 10)
                end

                if (option.bonusSkill) then
                    skills[option.bonusSkill.target] = math.min((skills[option.bonusSkill.target] or 0) + option.bonusSkill.amount, 10)
                end

                -- most options grant a single trait via traitID; a few (e.g. Branded) grant more than
                -- one via traitIDs - both are supported here so existing single-trait options don't need to change
                if (option.traitID and !table.HasValue(traits, option.traitID)) then
                    table.insert(traits, option.traitID)
                end

                for _, tid in ipairs(option.traitIDs or {}) do
                    if (!table.HasValue(traits, tid)) then
                        table.insert(traits, tid)
                    end
                end

                -- items are placeholders for now (option.items is empty) - safe to leave this loop in for when they're filled in
                for _, itemID in ipairs(option.items or {}) do
                    if (character.GetInventory) then
                        character:GetInventory():Add(itemID)
                    end
                end
            end
        end

        character:SetData("skills", skills)
        character:SetData("traits", traits)

        -- everything the setup wizard hands out is an origin trait, so none of it counts toward the
        -- escalating cost of *bought* traits later on
        local traitSources = character:GetData("traitSources", {})

        for _, tid in ipairs(traits) do
            traitSources[tid] = traitSources[tid] or "origin"
        end

        character:SetData("traitSources", traitSources)
        character:SetData("charSetupDone", true)

        client:Notify("Character setup complete!")
    end)
end

ix.command.Add("CharGiveTraits", {
    description = "Gives a trait to a character.",
    privilege = "Manage Character Traits",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string
    },
    OnRun = function(self, client, target, traitName)
        local trait = FindTrait(traitName)

        if (!trait) then
            return "Could not find that trait."
        end

        local traits = target:GetData("traits", {})

        if (table.HasValue(traits, trait.id)) then
            return string.format("%s already has the '%s' trait.", target:GetName(), trait.name)
        end

        local conflict = GetConflictingTrait(target, trait)

        if (conflict) then
            return string.format("The character has a conflicting trait! ('%s')", conflict.name)
        end

        table.insert(traits, trait.id)
        target:SetData("traits", traits)

        -- anything an admin hands out is a reward, so it never counts toward purchase escalation
        SetTraitSource(target, trait.id, "rewarded")

        return string.format("Gave %s the '%s' trait.", target:GetName(), trait.name)
    end
})

-- builds the purchase window's contents: every tier 1 trait, whether they already have it, and what
-- the next purchase would cost. also used to refresh the window in place after a successful buy
if (SERVER) then
    function SendTraitPurchaseList(client, character)
        local owned = {}

        for _, tid in ipairs(character:GetData("traits", {})) do
            owned[tid] = true
        end

        -- only the id and owned flag go over the wire. the client has the whole trait table already
        -- (sh_traits.lua is shared), so it looks up the name, description and effect itself - which
        -- also keeps FormatTraitModifiers clientside, where the L() calls inside it can actually work
        local available = {}

        for _, trait in ipairs(traitList) do
            if ((trait.tier or 1) == 1) then
                local conflict = !owned[trait.id] and GetConflictingTrait(character, trait) or nil

                available[#available + 1] = {
                    id = trait.id,
                    owned = owned[trait.id] == true,
                    -- name only, so the shop can say what's in the way without resolving it itself
                    blockedBy = conflict and conflict.name or nil
                }
            end
        end

        net.Start("ixOpenTraitPurchase")
            net.WriteTable({
                traits = available,
                points = character:GetData("traitPoints", 1),
                purchased = GetPurchasedTraitCount(character),
                maxPurchased = MAX_PURCHASED_TRAITS,
                nextCost = GetNextTraitCost(character)
            })
        net.Send(client)
    end
end

ix.command.Add("BuyTraits", {
    description = "Opens the Tier 1 trait shop, where trait points can be spent.",
    OnRun = function(self, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        SendTraitPurchaseList(client, character)
    end
})

-- takes a target as well as an amount, unlike the other trait commands' shorthand - an admin reward
-- that could only ever be applied to yourself wouldn't be much use for rewarding a player
ix.command.Add("GiveTraitPoint", {
    description = "Gives a character trait points, up to the maximum they could ever spend.",
    privilege = "Manage Character Traits",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.number
    },
    OnRun = function(self, client, target, amount)
        amount = math.Clamp(math.floor(amount or 0), 1, MAX_TRAIT_POINTS)

        local current = target:GetData("traitPoints", 1)
        local newTotal = math.min(current + amount, MAX_TRAIT_POINTS)

        if (newTotal == current) then
            return string.format(
                "%s already has the maximum of %d trait points.", target:GetName(), MAX_TRAIT_POINTS
            )
        end

        target:SetData("traitPoints", newTotal)

        local granted = newTotal - current
        local targetPlayer = target:GetPlayer()

        if (IsValid(targetPlayer)) then
            targetPlayer:Notify(string.format(
                "You've been given %d trait point(s). You now have %d.", granted, newTotal
            ))
        end

        return string.format(
            "Gave %s %d trait point(s). They now have %d.", target:GetName(), granted, newTotal
        )
    end
})

ix.command.Add("CharRemoveTrait", {
    description = "Removes a trait from a character.",
    privilege = "Manage Character Traits",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.string
    },
    OnRun = function(self, client, target, traitName)
        local trait = FindTrait(traitName)

        if (!trait) then
            return "Could not find that trait."
        end

        local traits = target:GetData("traits", {})

        for i, tid in ipairs(traits) do
            if (tid == trait.id) then
                table.remove(traits, i)
                target:SetData("traits", traits)

                -- clear the source too. if this was a purchased trait, that also drops the purchased
                -- count, so their next purchase falls back to the cheaper price - which is the right
                -- outcome, since they no longer have the trait they paid for
                local sources = target:GetData("traitSources", {})

                sources[trait.id] = nil
                target:SetData("traitSources", sources)

                return string.format("Removed the '%s' trait from %s.", trait.name, target:GetName())
            end
        end

        return string.format("%s doesn't have that trait.", target:GetName())
    end
})

-- gathers and sends a character's sheet data to whoever requested it
local function SendCharacterSheet(client, target)
    local isOwner = (target == client:GetCharacter())

    local targetPlayer = target:GetPlayer()

    local data = {
        name = target:GetName(),
        bio = target:GetData("bio", ""),
        picURL = target:GetData("picURL", ""),
        isOwner = isOwner,
        health = IsValid(targetPlayer) and targetPlayer:Health() or 0,
        maxHealth = IsValid(targetPlayer) and targetPlayer:GetMaxHealth() or 100,
        attributes = {},
        skillCategories = {}
    }

    -- private notes and the spendable point pool are only ever included when the requester owns this character
    if (isOwner) then
        data.privateNotes = target:GetData("privateNotes", "")
        data.skillPoints = target:GetData("skillPoints", 8)
        data.traitPoints = target:GetData("traitPoints", 1)
        data.purchasedTraits = GetPurchasedTraitCount(target)
        data.maxPurchasedTraits = MAX_PURCHASED_TRAITS
        data.nextTraitCost = GetNextTraitCost(target)
    end

    -- relationships are public (visible to anyone viewing the sheet); only the owner sees add/edit/delete controls client-side
    local relationships = target:GetData("relationships", {})
    local hasMyself = false

    for _, entry in ipairs(relationships) do
        if (entry.id == "myself") then
            hasMyself = true
            break
        end
    end

    if (!hasMyself) then
        table.insert(relationships, 1, {
            id = "myself",
            name = "Myself",
            thoughts = "That's how I feel about myself.",
            value = 100
        })

        target:SetData("relationships", relationships)
    end

    if (isOwner) then
        data.relationships = relationships
    else
        -- an entry marked private keeps its name and value public but has the thoughts text swapped
        -- out before it ever leaves the server. redacting this client-side would be no protection at
        -- all: anything sent to a client can be read there regardless of what the UI chooses to draw
        local publicRelationships = {}

        for _, entry in ipairs(relationships) do
            publicRelationships[#publicRelationships + 1] = {
                id = entry.id,
                name = entry.name,
                value = entry.value,
                private = entry.private,
                thoughts = entry.private and "My thoughts on this person are private." or entry.thoughts
            }
        end

        data.relationships = publicRelationships
    end

    -- info fields and biography are public, sent to whoever is viewing regardless of ownership
    data.info = target:GetData("sheetInfo", {})
    data.biography = target:GetData("biography", "")
    data.quote = target:GetData("quote", "")

    for k, v in pairs(ix.attributes.list) do
        data.attributes[k] = {
            name = L(v.name, client),
            value = GetEffectiveAttribute(target, k)
        }
    end

    -- active conditions are public - anyone viewing the sheet can see what's currently affecting a character
    data.conditions = {}

    do
        local now = os.time()

        for _, cond in ipairs(GetActiveConditions(target)) do
            local conditionDef = conditionsByID[cond.sourceId]

            -- legacy (pre-region) instances of a "fixed" scope condition still display at their fixed region
            local displayRegion = cond.region

            if (!displayRegion and conditionDef and conditionDef.regionScope == "fixed") then
                displayRegion = conditionDef.region
            end

            data.conditions[#data.conditions + 1] = {
                sourceId = cond.sourceId,
                name = cond.name,
                description = cond.description,
                region = displayRegion,
                category = (conditionDef and conditionDef.category) or "health",
                remainingSeconds = cond.expiresAt and (cond.expiresAt - now) or nil,
                -- suppresses the countdown for conditions whose expiry is only a refresh buffer
                hideTimer = conditionDef and conditionDef.hideTimer,
                modifiers = cond.modifiers,
                -- the instance wins over the template: /athletics writes its rolled percentage onto
                -- the instance, while everything else just carries whatever the template declared
                effectText = cond.effectText or (conditionDef and conditionDef.effectText),
                -- disadvantageSkills only ever comes from the template - nothing grants it per-use.
                -- advantageSkills can come from either, since /rally decides its skill when called;
                -- FormatTraitModifiers reads this field directly, so the card renders "advantage on
                -- Athletics" with no extra work
                disadvantageSkills = conditionDef and conditionDef.disadvantageSkills,
                advantageSkills = cond.advantageSkills or (conditionDef and conditionDef.advantageSkills)
            }
        end
    end

    -- traits are public - anyone viewing the sheet can see what traits a character has
    data.traits = {}

    for _, tid in ipairs(target:GetData("traits", {})) do
        local trait = traitsByID[tid]

        if (trait) then
            data.traits[#data.traits + 1] = {
                id = trait.id,
                name = trait.name,
                description = trait.description,
                tier = trait.tier or 1,
                source = TRAIT_SOURCE_LABELS[GetTraitSource(target, tid)] or TRAIT_SOURCE_LABELS.origin
            }
        end
    end

    local investedSkills = target:GetData("skills", {})
    local categoryLookup = {}

    for _, skill in ipairs(skillList) do
        local attrOne = GetEffectiveAttribute(target, skill.attributes[1])
        local attrTwo = GetEffectiveAttribute(target, skill.attributes[2])
        local modifier = math.floor((attrOne + attrTwo) / 2) + GetTraitSkillBonus(target, skill.id)
        local group = categoryLookup[skill.category]

        if (!group) then
            group = {name = skill.category, skills = {}}
            categoryLookup[skill.category] = group
            data.skillCategories[#data.skillCategories + 1] = group
        end

        group.skills[#group.skills + 1] = {
            id = skill.id,
            name = skill.name,
            modifier = modifier,
            points = investedSkills[skill.id] or 0,
            attribOne = {name = L(ix.attributes.list[skill.attributes[1]].name, client), value = attrOne},
            attribTwo = {name = L(ix.attributes.list[skill.attributes[2]].name, client), value = attrTwo}
        }
    end

    net.Start("ixOpenCharSheet")
        net.WriteTable(data)
    net.Send(client)
end

ix.command.Add("CharSheet", {
    description = "Opens a character sheet. Leave blank to view your own.",
    arguments = bit.bor(ix.type.string, ix.type.optional),
    OnRun = function(self, client, targetName)
        local target = client:GetCharacter()

        if (targetName and targetName != "") then
            local found

            for _, v in pairs(ix.char.loaded) do
                if (IsValid(v:GetPlayer()) and ix.util.StringMatches(v:GetName(), targetName)) then
                    found = v
                    break
                end
            end

            if (!found) then
                client:Notify("Could not find that character.")
                return
            end

            target = found
        end

        if (!target) then
            return
        end

        SendCharacterSheet(client, target)
    end
})

if (SERVER) then
    net.Receive("ixCharSheetSetBio", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local text = net.ReadString():sub(1, 1000)
        character:SetData("bio", text)
    end)

    net.Receive("ixCharSheetSetPic", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local url = net.ReadString()

        if (url != "" and !IsLikelyImageURL(url)) then
            client:Notify("That doesn't look like a direct image link (should end in .png, .jpg, etc). Saved it anyway, but double-check it displays correctly!")
        end

        character:SetData("picURL", url)
    end)

    net.Receive("ixCharSheetSetNotes", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local text = net.ReadString():sub(1, 2000)
        character:SetData("privateNotes", text)
    end)

    net.Receive("ixCharSheetSetInfo", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local payload = net.ReadTable()
        local sanitized = {}

        for key, value in pairs(payload) do
            if (INFO_FIELD_KEYS[key] and isstring(value)) then
                sanitized[key] = value:sub(1, 60)
            end
        end

        character:SetData("sheetInfo", sanitized)
    end)

    net.Receive("ixCharSheetSetBiography", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local text = net.ReadString():sub(1, 3000)
        character:SetData("biography", text)
    end)

    net.Receive("ixCharSheetSetQuote", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local text = net.ReadString():sub(1, 100)
        character:SetData("quote", text)
    end)

    net.Receive("ixCharSheetAddRelationship", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local payload = net.ReadTable()
        local name = isstring(payload.name) and payload.name:sub(1, 40) or ""

        if (name == "") then
            return
        end

        local thoughts = isstring(payload.thoughts) and payload.thoughts:sub(1, 500) or ""
        local value = math.Clamp(math.floor(tonumber(payload.value) or 50), 1, 100)
        local relationships = character:GetData("relationships", {})
        local id = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))

        table.insert(relationships, {
            id = id, name = name, thoughts = thoughts, value = value,
            -- normalized to a real boolean rather than trusted as-is; this comes off the wire
            private = payload.private == true
        })

        character:SetData("relationships", relationships)

        SendCharacterSheet(client, character)
    end)

    net.Receive("ixCharSheetEditRelationship", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local payload = net.ReadTable()
        local id = payload.id

        if (!isstring(id)) then
            return
        end

        local relationships = character:GetData("relationships", {})

        for _, entry in ipairs(relationships) do
            if (entry.id == id) then
                if (entry.id != "myself" and isstring(payload.name) and payload.name != "") then
                    entry.name = payload.name:sub(1, 40)
                end

                if (isstring(payload.thoughts)) then
                    entry.thoughts = payload.thoughts:sub(1, 500)
                end

                entry.private = payload.private == true

                if (payload.value) then
                    entry.value = math.Clamp(math.floor(tonumber(payload.value) or entry.value), 1, 100)
                end

                break
            end
        end

        character:SetData("relationships", relationships)
        SendCharacterSheet(client, character)
    end)

    net.Receive("ixCharSheetBuyTrait", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local traitID = net.ReadString()
        local trait = traitsByID[traitID]

        -- every condition is re-checked here rather than trusting that the button which sent this was
        -- one the client was actually shown
        if (!trait or (trait.tier or 1) != 1) then
            client:Notify("Only Tier 1 traits can be purchased.")
            return
        end

        local traits = character:GetData("traits", {})

        if (table.HasValue(traits, traitID)) then
            client:Notify("You already have that trait.")
            return
        end

        local conflict = GetConflictingTrait(character, trait)

        if (conflict) then
            client:Notify(string.format(
                "You can't take '%s' while you have '%s'.", trait.name, conflict.name
            ))

            return
        end

        local cost = GetNextTraitCost(character)

        if (!cost) then
            client:Notify(string.format(
                "You've already purchased the maximum of %d traits.", MAX_PURCHASED_TRAITS
            ))

            return
        end

        local points = character:GetData("traitPoints", 1)

        if (points < cost) then
            client:Notify(string.format(
                "'%s' costs %d trait point(s) and you have %d.", trait.name, cost, points
            ))

            return
        end

        table.insert(traits, traitID)
        character:SetData("traits", traits)
        character:SetData("traitPoints", points - cost)
        SetTraitSource(character, traitID, "purchased")

        client:Notify(string.format(
            "You purchased '%s' for %d trait point(s).", trait.name, cost
        ))

        -- refresh both the shop (prices have gone up) and any open sheet behind it
        SendTraitPurchaseList(client, character)
        SendCharacterSheet(client, character)
    end)

    net.Receive("ixCharSheetDeleteRelationship", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        local id = net.ReadString()

        if (id == "myself") then
            return
        end

        local relationships = character:GetData("relationships", {})

        for i, entry in ipairs(relationships) do
            if (entry.id == id) then
                table.remove(relationships, i)
                break
            end
        end

        character:SetData("relationships", relationships)
        SendCharacterSheet(client, character)
    end)

    -- grants one free level of a skill (no point cost), used by skill book items; caps at 10 same as
    -- the normal point-spend path and refreshes the player's open character sheet if they have one up
    function GrantSkillLevel(client, skillID)
        local character = client:GetCharacter()

        if (!character) then
            return false
        end

        local skillData = FindSkillByID(skillID)

        if (!skillData) then
            return false
        end

        local invested = character:GetData("skills", {})
        local current = invested[skillID] or 0

        if (current >= 10) then
            client:Notify(skillData.name .. " is already at its maximum.")
            return false
        end

        invested[skillID] = current + 1
        character:SetData("skills", invested)

        client:Notify("You feel your understanding of " .. skillData.name .. " deepen.")
        SendCharacterSheet(client, character)

        return true
    end

    -- handles a player spending points from their pool to raise a specific skill by one level
    net.Receive("ixCharSheetSpendSkill", function(length, client)
        local character = client:GetCharacter()

        if (!character) then
            return
        end

        if (!character:GetData("charSetupDone", false)) then
            client:Notify("You must complete /charsetup before spending skill points.")
            return
        end

        local skillID = net.ReadString()
        local skillData

        for _, skill in ipairs(skillList) do
            if (skill.id == skillID) then
                skillData = skill
                break
            end
        end

        if (!skillData) then
            return
        end

        local invested = character:GetData("skills", {})
        local current = invested[skillID] or 0

        if (current >= 10) then
            client:Notify("That skill's invested points are already at their maximum.")
            return
        end

        local nextLevel = current + 1
        local cost = skillLevelCost[nextLevel]
        local pool = character:GetData("skillPoints", 8)

        if (pool < cost) then
            client:Notify(string.format("You need %d skill point(s) to raise this further (you have %d).", cost, pool))
            return
        end

        invested[skillID] = nextLevel
        character:SetData("skills", invested)
        character:SetData("skillPoints", pool - cost)

        -- refresh their open sheet with the new values
        SendCharacterSheet(client, character)
    end)
end

if (SERVER) then
    local BLEED_TICK_INTERVAL = 180 -- 3 real-life minutes

    -- periodically damages anyone with an active bleeding condition, stopping once their health reaches that tier's floor
    timer.Create("ixBleedingTick", 10, 0, function()
        local now = os.time()

        for _, client in ipairs(player.GetAll()) do
            local character = client:GetCharacter()

            if (character and client:Alive()) then
                local conditions = character:GetData("conditions", {})
                local changed = false

                for _, cond in ipairs(conditions) do
                    local tier = bleedingTiers[cond.sourceId]

                    if (tier and cond.expiresAt and cond.expiresAt > now) then
                        cond.lastBleedTick = cond.lastBleedTick or now

                        if (now - cond.lastBleedTick >= BLEED_TICK_INTERVAL) then
                            cond.lastBleedTick = now
                            changed = true

                            if (client:Health() > tier.floor) then
                                client:SetHealth(math.max(client:Health() - tier.damage, tier.floor))
                                client:Notify("Your wound throbs as you lose more blood.")
                            end
                        end
                    end
                end

                if (changed) then
                    character:SetData("conditions", conditions)
                end
            end
        end
    end)
end

-- how long a hunger or thirst tier has left before it gives way to the next one down, in hours. the
-- value drops one point per decay interval and the tier ends the moment it falls below its floor, so
-- that's the whole points still to lose plus whatever remains of the point currently counting down.
-- returns nil for the bottom tier, which has nothing left to fall into - those keep the template's own
-- short duration as a refresh buffer, and hide the countdown entirely on the sheet.
-- file scope rather than inside either tick, since the hunger and thirst sweeps are separate blocks
local function GetTierRemainingHours(character, tier, value, interval, lastDecayKey)
    if (tier.min <= 0) then
        return nil
    end

    local pointsLeft = math.max(value - tier.min + 1, 1)
    local intoCurrentPoint = math.Clamp(os.time() - character:GetData(lastDecayKey, os.time()), 0, interval)

    return (((pointsLeft - 1) * interval) + (interval - intoCurrentPoint)) / 3600
end

if (SERVER) then
    -- short so eating registers promptly; the sweep is only a table lookup per player
    local HUNGER_TICK_INTERVAL = 10

    -- ordered highest threshold first; character:GetHunger() is 0-100 (see the drift-needings plugin)
    local hungerTiers = {
        {id = "wellfed", min = 90},
        {id = "fed", min = 80},
        {id = "sated", min = 65},
        {id = "peckish", min = 50},
        {id = "hungry", min = 35},
        {id = "nearlystarving", min = 15},
        {id = "starving", min = 1},
        {id = "dyingofstarvation", min = 0}
    }

    -- refreshes each player's hunger-tier condition every tick based on their current hunger value,
    -- swapping to a different tier's condition the moment they cross a threshold. the condition's
    -- expiry is set to when the tier itself runs out, so the sheet's "remaining" is the time until
    -- they drop a tier rather than an arbitrary refresh window
    timer.Create("ixHungerTierTick", HUNGER_TICK_INTERVAL, 0, function()
        for _, client in ipairs(player.GetAll()) do
            local character = client:GetCharacter()

            if (character and client:Alive() and character.GetHunger) then
                local hunger = character:GetHunger()
                local currentTier

                for _, tier in ipairs(hungerTiers) do
                    if (hunger >= tier.min) then
                        currentTier = tier
                        break
                    end
                end

                if (currentTier) then
                    for _, tier in ipairs(hungerTiers) do
                        if (tier.id != currentTier.id) then
                            RemoveCharacterCondition(character, tier.id)
                        end
                    end

                    -- guarded: drift-needings owns the interval, and this plugin loads first
                    local interval = GetCharacterHungerInterval and GetCharacterHungerInterval(character) or 720

                    ApplyCharacterCondition(character, currentTier.id,
                        GetTierRemainingHours(character, currentTier, hunger, interval, "lastHungerDecay"))
                end
            end
        end
    end)
end

if (SERVER) then
    -- matches the hunger sweep; see the comment there
    local THIRST_TICK_INTERVAL = 10

    -- ordered highest threshold first; character:GetThirst() is 0-100 (see the drift-needings plugin)
    local thirstTiers = {
        {id = "wellhydrated", min = 90},
        {id = "hydrated", min = 80},
        {id = "quenched", min = 65},
        {id = "thirsty", min = 50},
        {id = "parched", min = 35},
        {id = "dehydrated", min = 15},
        {id = "severelydehydrated", min = 1},
        {id = "dyingofdehydration", min = 0}
    }

    -- refreshes each player's thirst-tier condition every tick based on their current thirst value,
    -- swapping to a different tier's condition the moment they cross a threshold; each condition's
    -- own durationHours (3 minutes) is just a buffer in case this timer ever misses a beat
    timer.Create("ixThirstTierTick", THIRST_TICK_INTERVAL, 0, function()
        for _, client in ipairs(player.GetAll()) do
            local character = client:GetCharacter()

            if (character and client:Alive() and character.GetThirst) then
                local thirst = character:GetThirst()
                local currentTier

                for _, tier in ipairs(thirstTiers) do
                    if (thirst >= tier.min) then
                        currentTier = tier
                        break
                    end
                end

                if (currentTier) then
                    for _, tier in ipairs(thirstTiers) do
                        if (tier.id != currentTier.id) then
                            RemoveCharacterCondition(character, tier.id)
                        end
                    end

                    -- guarded: drift-needings owns the interval, and this plugin loads first
                    local interval = GetCharacterThirstInterval and GetCharacterThirstInterval(character) or 360

                    ApplyCharacterCondition(character, currentTier.id,
                        GetTierRemainingHours(character, currentTier, thirst, interval, "lastThirstDecay"))
                end
            end
        end
    end)
end