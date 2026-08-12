RECIPE.name = ".38 Ammo"
RECIPE.description = "Craft some .38 Ammo."
RECIPE.model = "models/mosi/fallout4/ammo/38.mdl"
RECIPE.category = "Ammunition"
RECIPE.requirements = {
	["craft_uncom_casings"] = 2,
	["craft_uncom_lead"] = 1
}
RECIPE.skills = {
	["repair"] = 1
}
RECIPE.results = {
	["ammo_com_38_small"] = 1
}
RECIPE.tools = {
	"craft_com_toolkit"
}


RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_reloadingbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a reloading bench."
end)
