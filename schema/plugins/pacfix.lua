PLUGIN.name = "Fix Pac"
PLUGIN.description = "Fixes a very specific PAC issue!"
PLUGIN.author = "Shazzy"

function PLUGIN:PlayerSpawn(ply)
    if not ( ply:IsValid() or ply:Alive() or ply:GetCharacter() ) then return end

    ply:ConCommand("pac_restart")
end