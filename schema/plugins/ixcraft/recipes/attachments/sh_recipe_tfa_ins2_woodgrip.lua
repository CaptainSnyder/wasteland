RECIPE.name = "Wooden Foregrip"
RECIPE.description = "Build a Wooden Foregrip at a weapon workbench."
RECIPE.model = "models/props_c17/tools_pliers01a.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_com_wood"] = 2,
	["craft_com_screws"] = 2
}
RECIPE.skills = {
	["repair"] = 2
}
RECIPE.results = {
	["tfa_ins2_woodgrip"] = 1
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
