RECIPE.name = "Cooked Meat"
RECIPE.description = "Cook a cut of raw meat into something actually worth eating."
RECIPE.model = "models/items/plate_steak.mdl"
RECIPE.category = "Cooking"
RECIPE.requirements = {
	["foods_com_rawmeat"] = 1
}
RECIPE.results = {
	["foods_com_cookedmeat"] = 1
}

RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_stove")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a stove."
end)
