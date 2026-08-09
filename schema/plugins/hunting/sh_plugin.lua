PLUGIN.name = "Hunting"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Lets specific NPCs leave behind a harvestable corpse when killed, instead of just despawning."

-- every huntable creature, keyed by the NPC class that spawns it. all of these are handled by the one
-- harvestable_corpse entity, so adding another creature means adding an entry here and nothing else:
--   model            what the corpse looks like
--   collisionBounds  fallback hitbox, used when the model has no compiled physics mesh (most creature
--                    models don't) - size it to the creature so the body doesn't sink or float
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
	-- OnNPCKilled is a base gamemode hook that fires for any NPC dying, regardless of what addon
	-- registered it or how it died - it doesn't require any cooperation from the NPC itself
	function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
		local def = self.harvestableNPCs[npc:GetClass()]

		if (!def) then
			return
		end

		local pos = npc:GetPos()
		local ang = npc:GetAngles()
		local npcClass = npc:GetClass()

		-- deferred slightly so our corpse isn't created while the engine/NPC addon's own death
		-- handling (ragdolling, removal, etc.) is still running; this delay also gives whatever
		-- default corpse/ragdoll the NPC leaves behind time to actually exist, so the cleanup
		-- sweep below has something to find
		timer.Simple(0.1, function()
			-- best-effort cleanup of whatever was left at the death spot, since an NPC may either
			-- turn into a corpse itself or spawn a separate prop_ragdoll. npc_antlion in particular
			-- gibs on death, so the sweep also clears the shell chunks it throws around
			if (IsValid(npc)) then
				npc:Remove()
			end

			for _, ent in ipairs(ents.FindInSphere(pos, 64)) do
				if (IsValid(ent) and (ent:GetClass() == "prop_ragdoll" or ent:GetClass() == npcClass)) then
					ent:Remove()
				end
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

			local physObj = corpse:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:Wake()
			elseif (corpse.SetDeathPose) then
				-- no real physics mesh on this model, so it can't topple over on its own (see
				-- harvestable_corpse.lua's Initialize) - tip it onto its side instead of leaving it
				-- stuck standing upright in its default idle pose
				corpse:SetDeathPose()
			end
		end)
	end
end
