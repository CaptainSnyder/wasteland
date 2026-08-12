RECIPE.name = "9mm Ammo"
RECIPE.description = "Craft some 9mm Ammo."
RECIPE.model = "models/illusion/fwp/9mmammo.mdl"
RECIPE.category = "Ammunition"
RECIPE.requirements = {
	["craft_uncom_casings"] = 2,
	["craft_uncom_lead"] = 1
}
RECIPE.skills = {
	["repair"] = 1
}
RECIPE.results = {
	["ammo_com_9mm_small"] = 1
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
