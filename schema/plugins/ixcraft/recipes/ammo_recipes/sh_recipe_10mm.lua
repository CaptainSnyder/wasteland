RECIPE.name = "10mm Ammo"
RECIPE.description = "Craft some 10mm Ammo."
RECIPE.model = "models/mosi/fallout4/ammo/10mm.mdl"
RECIPE.category = "Ammunition"
RECIPE.requirements = {
	["craft_uncom_casings"] = 3,
	["craft_uncom_lead"] = 2
}
RECIPE.results = {
	["ammo_uncom_10mm_small"] = 1
}
RECIPE.tools = {
	"craft_rare_toolkit"
}


RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_reloadingbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a reloading bench."
end)
