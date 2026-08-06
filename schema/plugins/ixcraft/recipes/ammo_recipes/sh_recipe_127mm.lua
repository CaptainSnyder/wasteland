RECIPE.name = "12.7mm Ammo"
RECIPE.description = "Craft some 12.7mm Ammo."
RECIPE.model = "models/illusion/fwp/127ammobox.mdl"
RECIPE.category = "Ammunition"
RECIPE.requirements = {
	["craft_uncom_casings"] = 4,
	["craft_uncom_lead"] = 3
}
RECIPE.results = {
	["ammo_rare_127mm_small"] = 1
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
