RECIPE.name = "Galil 75-Round Drum"
RECIPE.description = "Build a Galil 75-Round Drum at a weapon workbench."
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
	["tfa_ins2_galil_drummag_75rounds"] = 1
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
