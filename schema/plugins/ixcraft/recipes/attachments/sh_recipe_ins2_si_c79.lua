RECIPE.name = "C79 Elcan Scope"
RECIPE.description = "Build a C79 Elcan Scope at a weapon workbench."
RECIPE.model = "models/props_lab/reciever01b.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_circuitboard"] = 2,
	["craft_uncom_steel"] = 2,
	["craft_rare_weaponparts"] = 1
}
RECIPE.skills = {
	["nerdstuff"] = 6
}
RECIPE.results = {
	["ins2_si_c79"] = 1
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
