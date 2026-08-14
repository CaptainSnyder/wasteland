RECIPE.name = "G.I.B. Ammunition"
RECIPE.description = "Build a G.I.B. Ammunition at a weapon workbench."
RECIPE.model = "models/items/boxsrounds.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_casings"] = 2,
	["craft_uncom_lead"] = 3,
	["craft_uncom_steel"] = 1
}
RECIPE.skills = {
	["repair"] = 6
}
RECIPE.results = {
	["am_gib"] = 1
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
