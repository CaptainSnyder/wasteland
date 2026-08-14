RECIPE.name = "Heavy Barrel"
RECIPE.description = "Build a Heavy Barrel at a weapon workbench."
RECIPE.model = "models/props_c17/tools_wrench01a.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_steel"] = 3
}
RECIPE.skills = {
	["repair"] = 4
}
RECIPE.results = {
	["ins2_br_heavy"] = 1
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
