ENT.Type = "anim"
ENT.PrintName = "Harvestable Corpse"
ENT.Category = "Wasteland - Hunting"
ENT.Spawnable = false -- only ever created by the hunting plugin when a tracked NPC dies
ENT.AdminOnly = true

-- one entity serves every huntable creature. what it looks like and what it drops both come from the
-- definition in hunting/sh_plugin.lua, assigned by the plugin before Spawn() is called - adding a new
-- creature is a data entry there, not another copy of this file
function ENT:SetupDataTables()
end

if (SERVER) then
	-- fallback for the (shouldn't happen) case of this entity existing without a definition, e.g.
	-- someone spawning it by hand through the entity browser
	local DEFAULT_DEF = {
		name = "Carcass",
		model = "models/props_junk/watermelon01.mdl",
		collisionBounds = {Vector(-16, -16, 0), Vector(16, 16, 24)},
		loot = {}
	}

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

	-- called by the plugin between ents.Create and Spawn, so Initialize below has it available
	function ENT:SetCreatureDefinition(def)
		self.creatureDef = def
	end

	function ENT:GetCreatureDefinition()
		return self.creatureDef or DEFAULT_DEF
	end

	function ENT:Initialize()
		local def = self:GetCreatureDefinition()

		self:SetModel(def.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			-- deliberately NOT frozen (unlike the scavenge box/lockpick safe) - a fresh corpse
			-- should actually topple and settle instead of sitting rigidly in its death pose
			physObj:Wake()
		else
			-- creature models are frequently NPC-only, moving via an AI hitbox rather than a compiled
			-- vphysics mesh. PhysicsInit then silently fails, leaving SOLID_VPHYSICS/MOVETYPE_VPHYSICS
			-- with no physics object behind them - which is exactly what let the molerat fall straight
			-- through the world. fall back to a plain static bounding box that can't fall through
			-- anything; loses the toppling animation but is guaranteed to stay put
			local mins, maxs = unpack(def.collisionBounds or DEFAULT_DEF.collisionBounds)

			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_BBOX)
			self:SetCollisionBounds(mins, maxs)
		end

		self.usingPlayers = {}
		self.harvested = false
	end

	-- OnNPCKilled fires before any death animation gets a chance to play, so freezing on the NPC's
	-- captured sequence just landed on its normal standing/idle pose - no better than doing nothing.
	-- For models with no physics mesh to topple with (see the Initialize fallback above), fake the
	-- "fell over" look by tipping the frozen model onto its side instead
	function ENT:SetDeathPose()
		local def = self:GetCreatureDefinition()
		local ang = self:GetAngles()

		ang:RotateAroundAxis(ang:Forward(), 85)
		self:SetAngles(ang)

		-- lifted so the now-sideways body doesn't clip into the floor - roughly half the collision
		-- height set in Initialize, so a bigger creature gets lifted further
		local _, maxs = unpack(def.collisionBounds or DEFAULT_DEF.collisionBounds)

		self:SetPos(self:GetPos() + Vector(0, 0, maxs.z * 0.5))
	end

	-- same "only fire once per press, not once per tick while held" latch as the scavenging entities
	function ENT:Think()
		for ply in pairs(self.usingPlayers) do
			if (!IsValid(ply) or !ply:KeyDown(IN_USE)) then
				self.usingPlayers[ply] = nil
			end
		end

		self:NextThink(CurTime() + 0.1)

		return true
	end

	function ENT:Use(activator, caller)
		if (!IsValid(activator) or !activator:IsPlayer()) then
			return
		end

		if (self.usingPlayers[activator]) then
			return
		end

		self.usingPlayers[activator] = true

		if (self.harvested) then
			activator:Notify("There's nothing left to take from this carcass.")
			return
		end

		local character = activator:GetCharacter()

		if (!character) then
			return
		end

		self.harvested = true

		local def = self:GetCreatureDefinition()

		-- Waste Not Want Not doubles the number of independent harvest attempts (each with its own
		-- Survival roll), not the yield of a single roll - so two bad rolls can still net nothing
		local attempts = 1

		if (table.HasValue(character:GetData("traits", {}), "wastenotwantnot")) then
			attempts = 2
		end

		local totals = {}

		for i = 1, attempts do
			local result = PerformSkillCheck(activator, "survival")
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
			activator:Notify("You harvest " .. FormatHaul(harvested) .. " from the carcass.")
		else
			activator:Notify("You search the carcass but come away empty-handed.")
		end

		timer.Simple(1, function()
			if (IsValid(self)) then
				self:Remove()
			end
		end)
	end
end
