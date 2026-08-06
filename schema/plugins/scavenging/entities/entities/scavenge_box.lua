ENT.Type = "anim"
ENT.PrintName = "Scavenge Box"
ENT.Category = "Wasteland - Scavenging"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.SkillID = "scavenging"
ENT.SearchCooldown = 21600 -- 6 hours before this box can be searched again

function ENT:SetupDataTables()
end

if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/props_junk/cardboard_box001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)

        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        self.usingPlayers = {}
    end

    -- releases a player's use-latch once they let go of +use, so holding the key down can never
    -- fire more than the one attempt that happened on the initial press
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

        -- ignore repeat Use calls that fire every tick while +use is held; only the initial press counts
        if (self.usingPlayers[activator]) then
            return
        end

        self.usingPlayers[activator] = true

        if (self.nextUse and self.nextUse > CurTime()) then
            activator:Notify("There's nothing left worth taking in here right now. Try again in " .. FormatSearchCooldown(self.nextUse - CurTime()) .. ".")
            return
        end

        local character = activator:GetCharacter()

        if (!character) then
            return
        end

        self.nextUse = CurTime() + self.SearchCooldown

        local result, diceRoll = PerformSkillCheck(activator, self.SkillID)

        if (!result) then
            return
        end

        ResolveScavengeResult(activator, diceRoll, result)
    end
end
