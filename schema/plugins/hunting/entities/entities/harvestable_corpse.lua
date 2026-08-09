ENT.Type = "anim"
ENT.PrintName = "Harvestable Corpse"
ENT.Category = "Wasteland - Hunting"
ENT.Spawnable = false -- only ever created by the hunting plugin when a tracked NPC dies
ENT.AdminOnly = true

-- the fallback corpse, used only for creature models that can't ragdoll (no compiled collision
-- joints - the molerat has no physics mesh at all). anything that can ragdoll gets a real
-- prop_ragdoll instead, created in hunting/sh_plugin.lua. the harvest itself lives in that file's
-- HarvestCreatureCorpse so both forms behave identically
function ENT:SetupDataTables()
end

if (SERVER) then
	-- for the (shouldn't happen) case of this entity existing without a definition, e.g. someone
	-- spawning it by hand through the entity browser
	local DEFAULT_DEF = {
		name = "Carcass",
		model = "models/props_junk/watermelon01.mdl",
		collisionBounds = {Vector(-16, -16, 0), Vector(16, 16, 24)},
		loot = {}
	}

	-- called by the plugin between ents.Create and Spawn, so Initialize below has it available
	function ENT:SetCreatureDefinition(def)
		self.creatureDef = def
		-- the same field the ragdoll path tags itself with, so HarvestCreatureCorpse doesn't care
		-- which of the two forms it was handed
		self.ixHarvestDef = def
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
		self:SetUseType(SIMPLE_USE)

		if (!IsValid(self:GetPhysicsObject())) then
			-- PhysicsInit silently failed because the model has no physics mesh, leaving
			-- SOLID_VPHYSICS/MOVETYPE_VPHYSICS with nothing behind them - which is exactly what let
			-- the molerat fall straight through the world. fall back to a static bounding box
			local mins, maxs = unpack(def.collisionBounds or DEFAULT_DEF.collisionBounds)

			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolid(SOLID_BBOX)
			self:SetCollisionBounds(mins, maxs)
		end
	end

	-- with no physics mesh there's nothing to topple, so fake the "fell over" look by tipping the
	-- model onto its side. only ever called for the fallback path; a real ragdoll flops on its own
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

	function ENT:Use(activator, caller)
		HarvestCreatureCorpse(activator, self)
	end
end
