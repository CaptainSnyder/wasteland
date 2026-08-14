RECIPE.name = "75-Round Drum Magazine"
RECIPE.description = "Build a 75-Round Drum Magazine at a weapon workbench."
RECIPE.model = "models/items/boxmrounds.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_steel"] = 3,
	["craft_com_gears"] = 2,
	["craft_com_screws"] = 2
}
RECIPE.skills = {
	["repair"] = 6
}
RECIPE.results = {
	["ins2_mag_drum_75rd"] = 1
}
RECIPE.tools = {
	"craft_com_toolkit"
}


RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_tfa_weapon_bench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a weapon workbench."
end)
