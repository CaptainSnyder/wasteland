PLUGIN.name = "Hunting"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Lets specific NPCs leave behind a harvestable corpse when killed, instead of just despawning."

-- maps an NPC class to the corpse entity it should leave behind when killed
PLUGIN.harvestableNPCs = {
	vj_fallout_molerat = "molerat_corpse"
}

if (SERVER) then
	-- OnNPCKilled is a base gamemode hook that fires for any NPC dying, regardless of what addon
	-- registered it or how it died - it doesn't require any cooperation from vj_fallout_molerat itself
	function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
		local corpseClass = self.harvestableNPCs[npc:GetClass()]

		if (!corpseClass) then
			return
		end

		local pos = npc:GetPos()
		local ang = npc:GetAngles()
		local npcClass = npc:GetClass()

		-- deferred slightly so our corpse isn't created while the engine/NPC addon's own death
		-- handling (ragdolling, removal, etc.) is still running; this delay also gives whatever
		-- default corpse/ragdoll the NPC addon leaves behind time to actually exist, so the cleanup
		-- sweep below has something to find
		timer.Simple(0.1, function()
			-- best-effort cleanup of whatever the NPC addon left at the death spot, since we don't
			-- know whether it turns the NPC entity itself into a corpse or spawns a separate
			-- prop_ragdoll - if this doesn't fully clear the original body, the class name or
			-- radius here may need adjusting once the addon's actual death behavior is visible
			if (IsValid(npc)) then
				npc:Remove()
			end

			for _, ent in ipairs(ents.FindInSphere(pos, 64)) do
				if (IsValid(ent) and (ent:GetClass() == "prop_ragdoll" or ent:GetClass() == npcClass)) then
					ent:Remove()
				end
			end

			local corpse = ents.Create(corpseClass)

			if (!IsValid(corpse)) then
				return
			end

			corpse:SetPos(pos)
			corpse:SetAngles(ang)
			corpse:Spawn()

			local physObj = corpse:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:Wake()
			elseif (corpse.SetDeathPose) then
				-- no real physics mesh on this model, so it can't topple over on its own (see
				-- molerat_corpse.lua's Initialize) - tip it onto its side instead of leaving it
				-- stuck standing upright in its default idle pose
				corpse:SetDeathPose()
			end
		end)
	end
end
