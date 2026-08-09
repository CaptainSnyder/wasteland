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
ix.util.Include("cl_conditions.lua")
ix.util.Include("cl_charsetup.lua")

local charSetupStages = PLUGIN.charSetupStages

local skillList = PLUGIN.skills
local skillLevelCost = PLUGIN.skillLevelCost
local traitList = PLUGIN.traits
local conditionList = PLUGIN.conditions
local bodyRegions = PLUGIN.bodyRegions
local bleedingTiers = PLUGIN.bleedingTiers

local traitsByID = {}

for _, trait in ipairs(traitList) do
    traitsByID[trait.id] = trait
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
function ApplyCharacterCondition(character, conditionID, durationHoursOverride, region, modifiersOverride)
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

    if (existing) then
        existing.expiresAt = now + durationSeconds
        existing.region = resolvedRegion
        existing.modifiers = modifiersOverride or existing.modifiers
    else
        table.insert(conditions, {
            id = tostring(now) .. "_" .. tostring(math.random(1000, 9999)),
            sourceId = conditionID,
            name = conditionDef.name,
            description = conditionDef.description,
            expiresAt = now + durationSeconds,
            modifiers = modifiersOverride or conditionDef.modifiers,
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
local function GetSkillRollMode(character, skill)
    local traitIDs = character:GetData("traits", {})
    local hasAdvantage = false
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
function PerformSkillCheck(client, skillID, modifier, forceMode)
    local character = client:GetCharacter()

    if (!character) then
        return
    end

    local skillData = FindSkillByID(skillID)

    if (!skillData) then
        return
    end

    modifier = modifier or 0

    local attribMod = GetSkillModifier(character, skillData)
    local invested = character:GetData("skills", {})[skillData.id] or 0
    local traitBonus = GetTraitSkillBonus(character, skillData.id)
    local flatBonus = attribMod + invested + traitBonus

    -- a forced mode wins outright - GetSkillRollMode isn't even consulted, so a player who picks
    -- Guaranteed Advantage gets it even when every trait they have says otherwise
    local forcedMode = ResolveForcedRollMode(forceMode)
    local rollMode = forcedMode or GetSkillRollMode(character, skillData)
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

        local amount = table.HasValue(traitIDs, "religious") and 2 or 1

        ApplyCharacterCondition(character, "prayer", 12, nil, {
            {type = "skill", target = skillData.id, amount = amount}
        })

        character:SetData("prayerCooldownUntil", now + (18 * 3600))

        client:Notify(string.format("You pray for guidance in %s. (+%d for 12 hours)", skillData.name, amount))
    end
})

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

        table.insert(traits, trait.id)
        target:SetData("traits", traits)

        return string.format("Gave %s the '%s' trait.", target:GetName(), trait.name)
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

    data.relationships = relationships

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
                modifiers = cond.modifiers,
                -- disadvantageSkills lives on the template, not the stored instance, since it never
                -- varies per-instance the way modifiers can (e.g. /pray's per-use skill target)
                disadvantageSkills = conditionDef and conditionDef.disadvantageSkills
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
                tier = trait.tier or 1
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

        table.insert(relationships, {id = id, name = name, thoughts = thoughts, value = value})
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

                if (payload.value) then
                    entry.value = math.Clamp(math.floor(tonumber(payload.value) or entry.value), 1, 100)
                end

                break
            end
        end

        character:SetData("relationships", relationships)
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

if (SERVER) then
    local HUNGER_TICK_INTERVAL = 60 -- check every minute

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
    -- swapping to a different tier's condition the moment they cross a threshold; each condition's
    -- own durationHours (3 minutes) is just a buffer in case this timer ever misses a beat
    timer.Create("ixHungerTierTick", HUNGER_TICK_INTERVAL, 0, function()
        for _, client in ipairs(player.GetAll()) do
            local character = client:GetCharacter()

            if (character and client:Alive() and character.GetHunger) then
                local hunger = character:GetHunger()
                local currentTier

                for _, tier in ipairs(hungerTiers) do
                    if (hunger >= tier.min) then
                        currentTier = tier.id
                        break
                    end
                end

                if (currentTier) then
                    for _, tier in ipairs(hungerTiers) do
                        if (tier.id != currentTier) then
                            RemoveCharacterCondition(character, tier.id)
                        end
                    end

                    ApplyCharacterCondition(character, currentTier)
                end
            end
        end
    end)
end

if (SERVER) then
    local THIRST_TICK_INTERVAL = 60 -- check every minute

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
                        currentTier = tier.id
                        break
                    end
                end

                if (currentTier) then
                    for _, tier in ipairs(thirstTiers) do
                        if (tier.id != currentTier) then
                            RemoveCharacterCondition(character, tier.id)
                        end
                    end

                    ApplyCharacterCondition(character, currentTier)
                end
            end
        end
    end)
end