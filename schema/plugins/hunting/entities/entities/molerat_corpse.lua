ENT.Type = "anim"
ENT.PrintName = "Molerat Corpse"
ENT.Category = "Wasteland - Hunting"
ENT.Spawnable = false -- only ever created by the hunting plugin when a molerat dies
ENT.AdminOnly = true

function ENT:SetupDataTables()
end

if (SERVER) then
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

	function ENT:Initialize()
		self:SetModel("models/fallout/molerat.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			-- deliberately NOT frozen (unlike the scavenge box/lockpick safe) - a fresh corpse
			-- should actually topple and settle instead of sitting rigidly in its death pose
			physObj:Wake()
		else
			-- this model has no compiled vphysics collision mesh (common for NPC-only creature
			-- models, which move via an AI hitbox rather than a real physics mesh) - PhysicsInit
			-- above silently failed, leaving SOLID_VPHYSICS/MOVETYPE_VPHYSICS with no physics
			-- object behind them, which is exactly what let it fall straight through the world.
			-- fall back to a plain static bounding box that can't fall through anything; loses the
			-- toppling animation but is guaranteed to actually stay in place
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_BBOX)
			self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 24))
		end

		self.usingPlayers = {}
		self.harvested = false
	end

	-- OnNPCKilled fires before any death animation gets a chance to play, so freezing on the NPC's
	-- captured sequence just landed on its normal standing/idle pose - no better than doing nothing.
	-- Since this model has no physics mesh to topple over with (see the Initialize fallback above),
	-- fake the "fell over" look directly by tipping the frozen model onto its side instead
	function ENT:SetDeathPose()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Forward(), 85)
		self:SetAngles(ang)

		-- lifted up so the now-sideways body doesn't clip into the floor - matches roughly half the
		-- collision height set in Initialize
		self:SetPos(self:GetPos() + Vector(0, 0, 12))
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

		-- Waste Not Want Not doubles the number of independent harvest attempts (each with its own
		-- Survival roll), not the yield of a single roll - so two bad rolls can still net nothing
		local attempts = 1

		if (table.HasValue(character:GetData("traits", {}), "wastenotwantnot")) then
			attempts = 2
		end

		local totalMeat, totalLeather = 0, 0

		for i = 1, attempts do
			local result = PerformSkillCheck(activator, "survival")
			local amount = result and GetHarvestAmount(result) or 0

			for j = 1, amount do
				character:GetInventory():Add("foods_com_rawmeat")
				character:GetInventory():Add("craft_uncom_leather")
			end

			totalMeat = totalMeat + amount
			totalLeather = totalLeather + amount
		end

		if (totalMeat > 0) then
			activator:Notify(string.format("You harvest %d Raw Meat and %d Leather from the carcass.", totalMeat, totalLeather))
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
