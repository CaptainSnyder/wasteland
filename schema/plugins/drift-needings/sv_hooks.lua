
function PLUGIN:PostPlayerLoadout( pl )
    if !IsValid( pl ) and !pl:IsPlayer() then return end
    local char = pl:GetCharacter() or false

    if char then
        if !char:GetData( "ixSaturation" ) then
            ix.Hunger:InitThirst( pl )
        end

        if !char:GetData( "ixSatiety" ) then
            ix.Hunger:InitHunger( pl )
        end
    end
end

-- base: 1 point every 6 minutes (40 points per 4-hour block, full bar lasts 10 hours), shifted ±25%
-- by Unquenchable Thirst / Camel's Constitution; read fresh every tick (not cached at spawn) so
-- granting or removing either trait takes effect immediately, with no respawn needed
local function GetThirstInterval( character )
    local traitIDs = character:GetData( "traits", {} )
    local hasFast = table.HasValue( traitIDs, "unquenchablethirst" )
    local hasSlow = table.HasValue( traitIDs, "camelsconstitution" )

    if ( hasFast and !hasSlow ) then
        return 270
    elseif ( hasSlow and !hasFast ) then
        return 450
    end

    return 360
end

-- base: 1 point every 12 minutes (20 points per 4-hour block, full bar lasts 20 hours), shifted ±25%
-- by Big Appetite / Small Appetite; same "read fresh every tick" reasoning as GetThirstInterval
local function GetHungerInterval( character )
    local traitIDs = character:GetData( "traits", {} )
    local hasFast = table.HasValue( traitIDs, "bigappetite" )
    local hasSlow = table.HasValue( traitIDs, "smallappetite" )

    if ( hasFast and !hasSlow ) then
        return 540
    elseif ( hasSlow and !hasFast ) then
        return 900
    end

    return 720
end

-- exposed as globals for the hunger and thirst tier conditions over in the charactersheets plugin,
-- which need the same intervals to work out how long a tier has left before it gives way to the next.
-- globals because locals don't cross files, matching how the rest of the schema shares functions
GetCharacterHungerInterval = GetHungerInterval
GetCharacterThirstInterval = GetThirstInterval

-- replaces the old per-player named timers (which baked a fixed interval in at spawn) with a single
-- global sweep every 10 seconds; each player's actual decay interval is recomputed from their
-- current traits on every check, so a trait granted or removed mid-life applies on the very next
-- tick instead of requiring a respawn
timer.Create( "ixNeedsDecayTick", 10, 0, function()
    local now = os.time()

    for _, pl in ipairs( player.GetAll() ) do
        local char = pl:GetCharacter()

        if ( char and pl:Alive() ) then
            local lastThirst = char:GetData( "lastThirstDecay", now )

            if ( now - lastThirst >= GetThirstInterval( char ) ) then
                char:SetData( "lastThirstDecay", now )

                local bSaturation = hook.Run( "CanPlayerThirst", pl ) or true

                if bSaturation == true then
                    ix.Hunger:DowngradeSaturation( pl, 1 )

                    if char:GetThirst() <= 0 then
                        pl:SetHealth( math.Clamp( pl:Health() - 2, 10, pl:GetMaxHealth() ) )
                    end
                end
            end

            local lastHunger = char:GetData( "lastHungerDecay", now )

            if ( now - lastHunger >= GetHungerInterval( char ) ) then
                char:SetData( "lastHungerDecay", now )

                local bSatiety = hook.Run( "CanPlayerHunger", pl ) or true

                if bSatiety == true then
                    ix.Hunger:DowngradeSatiety( pl, 1 )

                    if char:GetHunger() <= 0 then
                        pl:EmitSound( "npc/barnacle/barnacle_digesting2.wav", 45, 100 )
                        pl:SetHealth( math.Clamp( pl:Health() - 2, 10, pl:GetMaxHealth() ) )
                    end
                end
            end
        end
    end
end )

function ix.Hunger:InitThirst( pl )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", 60 )
        end
    end
end

function ix.Hunger:InitHunger( pl )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", 60 )
        end
    end
end

function ix.Hunger:RestoreSatiety( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", math.Clamp(char:GetData("ixSatiety", 0) + amount, 0, 100) )
        end
    end
end

function ix.Hunger:RestoreSaturation( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", math.Clamp(char:GetData("ixSaturation", 0) + amount, 0, 100) )
        end
    end
end

function ix.Hunger:DowngradeSatiety( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", math.Clamp(char:GetData("ixSatiety", 0) - amount, 0, 100) )
        end
    end
end

function ix.Hunger:DowngradeSaturation( pl, amount )
    if IsValid( pl ) and pl:IsPlayer() then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSaturation", math.Clamp(char:GetData("ixSaturation", 0) - amount, 0, 100) )
        end
    end
end

function PLUGIN:DoPlayerDeath(pl, _, __)
    if IsValid( pl ) then
        local char = pl:GetCharacter() or false

        if char then
            char:SetData( "ixSatiety", 60 )
            char:SetData( "ixSaturation", 60 )
        end
    end
end

util.AddNetworkString( 'EnableHungerBars' )
function PLUGIN:PlayerLoadedCharacter( pl, _, __ )
    net.Start( 'EnableHungerBars' )
    net.Send( pl )
end
