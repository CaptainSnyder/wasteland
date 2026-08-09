PLUGIN.name = "Hunting"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Lets specific NPCs leave behind a harvestable corpse when killed, instead of just despawning."

-- every huntable creature, keyed by the NPC class that spawns it. adding another creature means
-- adding an entry here and nothing else:
--   model            what the corpse looks like
--   collisionBounds  fallback hitbox, only used when the model can't ragdoll (see below) - size it to
--                    the creature so the body doesn't sink into the floor or hover above it
--   loot             what a successful Survival roll yields, one of each entry per success level
PLUGIN.harvestableNPCs = {
	vj_fallout_molerat = {
		name = "Molerat",
		model = "models/fallout/molerat.mdl",
		collisionBounds = {Vector(-16, -16, 0), Vector(16, 16, 24)},
		loot = {
			{uniqueID = "foods_com_rawmeat", name = "Raw Meat"},
			{uniqueID = "craft_uncom_leather", name = "Leather"}
		}
	},
	npc_antlion = {
		name = "Antlion",
		model = "models/AntLion.mdl",
		-- antlions are longer and lower than a molerat, so the box is wider and shorter to match
		collisionBounds = {Vector(-24, -24, 0), Vector(24, 24, 20)},
		loot = {
			{uniqueID = "foods_com_rawmeat", name = "Raw Meat"},
			{uniqueID = "craft_uncom_chitin", name = "Chitin"}
		}
	}
}

if (SERVER) then
	local harvestableNPCs = PLUGIN.harvestableNPCs

	-- 10 or under: nothing. 11-17: 1 of each. 18+: 2 of each. a natural 20 doesn't do anything extra
	-- on top of that - it's just whatever the total result already earns
	local function GetHarvestAmount(result)
		if (result <= 10) then
			return 0
		elseif (result <= 17) then
			return 1
		end

		return 2
	end

	-- joins harvested amounts into "2 Raw Meat and 2 Chitin", or a comma list if a creature ever
	-- drops three or more different things
	local function FormatHaul(entries)
		if (#entries == 1) then
			return entries[1]
		elseif (#entries == 2) then
			return entries[1] .. " and " .. entries[2]
		end

		local last = entries[#entries]
		local rest = {}

		for i = 1, #entries - 1 do
			rest[#rest + 1] = entries[i]
		end

		return table.concat(rest, ", ") .. " and " .. last
	end

	-- shared by both corpse forms: the ragdoll path routes here through PLUGIN:PlayerUse, the static
	-- fallback entity through its own ENT:Use. global so the entity file can reach it - locals don't
	-- cross files
	function HarvestCreatureCorpse(client, corpse)
		local def = corpse.ixHarvestDef

		if (!def or !IsValid(client) or !client:IsPlayer()) then
			return
		end

		-- +use fires every tick while the key is held, so debounce per player rather than running the
		-- whole harvest (or spamming the "nothing left" notify) sixty times a second
		if ((client.ixNextCorpseUse or 0) > CurTime()) then
			return
		end

		client.ixNextCorpseUse = CurTime() + 1

		if (corpse.ixHarvested) then
			client:Notify("There's nothing left to take from this carcass.")
			return
		end

		local character = client:GetCharacter()

		if (!character) then
			return
		end

		corpse.ixHarvested = true

		-- Waste Not Want Not doubles the number of independent harvest attempts (each with its own
		-- Survival roll), not the yield of a single roll - so two bad rolls can still net nothing
		local attempts = 1

		if (table.HasValue(character:GetData("traits", {}), "wastenotwantnot")) then
			attempts = 2
		end

		local totals = {}

		for i = 1, attempts do
			local result = PerformSkillCheck(client, "survival")
			local amount = result and GetHarvestAmount(result) or 0

			for j = 1, amount do
				for _, entry in ipairs(def.loot) do
					character:GetInventory():Add(entry.uniqueID)
				end
			end

			for _, entry in ipairs(def.loot) do
				totals[entry.uniqueID] = (totals[entry.uniqueID] or 0) + amount
			end
		end

		local harvested = {}

		for _, entry in ipairs(def.loot) do
			local amount = totals[entry.uniqueID] or 0

			if (amount > 0) then
				harvested[#harvested + 1] = string.format("%d %s", amount, entry.name)
			end
		end

		if (#harvested > 0) then
			client:Notify("You harvest " .. FormatHaul(harvested) .. " from the carcass.")
		else
			client:Notify("You search the carcass but come away empty-handed.")
		end

		timer.Simple(1, function()
			if (IsValid(corpse)) then
				corpse:Remove()
			end
		end)
	end

	-- tries a real prop_ragdoll first so the body actually flops and settles. a model only ragdolls if
	-- it was compiled with collision joints; plenty of creature models weren't (the molerat has no
	-- physics mesh at all), and for those prop_ragdoll comes back with no jointed physics, so we throw
	-- it away and fall back to the static tipped-over entity
	local function CreateCorpse(def, pos, ang)
		local ragdoll = ents.Create("prop_ragdoll")

		if (IsValid(ragdoll)) then
			ragdoll:SetModel(def.model)
			ragdoll:SetPos(pos)
			ragdoll:SetAngles(ang)
			ragdoll:Spawn()
			ragdoll:Activate()

			-- more than one physics object means real jointed ragdoll physics, not a single rigid prop
			if (ragdoll:GetPhysicsObjectCount() > 1) then
				ragdoll.ixHarvestDef = def
				ragdoll:SetUseType(SIMPLE_USE)

				return ragdoll
			end

			ragdoll:Remove()
		end

		local corpse = ents.Create("harvestable_corpse")

		if (!IsValid(corpse)) then
			return
		end

		-- assigned before Spawn so the entity's Initialize can read the model and hitbox from it
		corpse:SetCreatureDefinition(def)
		corpse:SetPos(pos)
		corpse:SetAngles(ang)
		corpse:Spawn()

		if (!IsValid(corpse:GetPhysicsObject()) and corpse.SetDeathPose) then
			-- no physics mesh, so it can't topple on its own - tip it onto its side instead of leaving
			-- it stuck standing upright in its default idle pose
			corpse:SetDeathPose()
		end

		return corpse
	end

	-- the engine builds its own ragdoll when an NPC dies, which is what was leaving a second body next
	-- to ours. catching it here kills it at the source, which is far more reliable than sweeping a
	-- radius afterwards and hoping the class name and distance both match
	function PLUGIN:CreateEntityRagdoll(owner, ragdoll)
		if (IsValid(owner) and harvestableNPCs[owner:GetClass()] and IsValid(ragdoll)) then
			ragdoll:Remove()
		end
	end

	-- OnNPCKilled is a base gamemode hook that fires for any NPC dying, regardless of what addon
	-- registered it or how it died - it doesn't require any cooperation from the NPC itself
	function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
		local def = harvestableNPCs[npc:GetClass()]

		if (!def) then
			return
		end

		local pos = npc:GetPos()
		local ang = npc:GetAngles()
		local npcClass = npc:GetClass()

		-- removed immediately rather than on a timer: the longer the dead NPC lives, the more chance
		-- it has to finish spawning gibs and death effects we'd then have to clean up
		npc:Remove()

		-- still deferred by a tick so our corpse isn't created while the engine's death handling is
		-- mid-flight, and so anything the NPC managed to leave behind already exists to be swept up
		timer.Simple(0.1, function()
			for _, ent in ipairs(ents.FindInSphere(pos, 96)) do
				if (!IsValid(ent)) then
					continue
				end

				local class = ent:GetClass()

				-- antlions in particular burst into shell chunks on death, so gibs get swept too
				if (class == "prop_ragdoll" or class == npcClass or class:find("gib")) then
					ent:Remove()
				end
			end

			CreateCorpse(def, pos, ang)
		end)
	end

	-- prop_ragdoll has no Use callback of its own, so the ragdoll corpse is handled here. the static
	-- fallback entity has a real ENT:Use and is deliberately not routed through this
	function PLUGIN:PlayerUse(client, entity)
		if (IsValid(entity) and entity.ixHarvestDef) then
			HarvestCreatureCorpse(client, entity)
		end
	end
end
