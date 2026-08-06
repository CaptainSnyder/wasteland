
ITEM.name = "Foods"
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.description = "..."
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Foods"
ITEM.useSound = "items/medshot4.wav"
ITEM.RestoreSaturation = 0
ITEM.RestoreSatiety = 0
ITEM.bDropOnDeath = true
ITEM.returnItems = {}

-- Careful Rationing (+25%) and Poor Nutritional Habits (-25%) cancel out to 1x if a character
-- somehow has both, matching how advantage/disadvantage cancel out elsewhere in this schema
local function GetNutritionMultiplier( pl )
	local character = pl:GetCharacter()

	if ( !character ) then
		return 1
	end

	local traitIDs = character:GetData( "traits", {} )
	local hasBoost = table.HasValue( traitIDs, "carefulrationing" )
	local hasPenalty = table.HasValue( traitIDs, "poornutritionalhabits" )

	if ( hasBoost and !hasPenalty ) then
		return 1.25
	elseif ( hasPenalty and !hasBoost ) then
		return 0.75
	end

	return 1
end

ITEM.functions.Apply = {
	name = "Use",
	tip = "useTip",
	icon = "icon16/arrow_right.png",
	OnRun = function( item )
		local pl = item.player

		if istable( item.useSound ) then
			ix.util.EmitQueuedSounds( pl, item.useSound, 0, 0.1, 70, 100)
		else
			pl:EmitSound( item.useSound, 70 )
		end

		if istable( item.returnItems ) then
			for _, v in ipairs( item.returnItems ) do
				pl:GetCharacter():GetInventory():Add( v )
			end
		else
			pl:GetCharacter():GetInventory():Add( item.returnItems )
		end

		local multiplier = GetNutritionMultiplier( pl )

		if item.RestoreSaturation then
            ix.Hunger:RestoreSaturation( pl, tonumber( item.RestoreSaturation ) * multiplier )
        end

        if item.RestoreSatiety then
            ix.Hunger:RestoreSatiety( pl, tonumber( item.RestoreSatiety ) * multiplier )
        end

		return true
	end,
}
