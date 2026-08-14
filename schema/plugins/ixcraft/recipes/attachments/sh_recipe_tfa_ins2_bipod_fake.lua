RECIPE.name = "Fixed Bipod"
RECIPE.description = "Build a Fixed Bipod at a weapon workbench."
RECIPE.model = "models/props_c17/tools_pliers01a.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_steel"] = 2,
	["craft_com_screws"] = 2
}
RECIPE.skills = {
	["repair"] = 3
}
RECIPE.results = {
	["tfa_ins2_bipod_fake"] = 1
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
