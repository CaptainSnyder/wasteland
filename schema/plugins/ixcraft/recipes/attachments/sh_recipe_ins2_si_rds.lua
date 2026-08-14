RECIPE.name = "Aimpoint Red Dot"
RECIPE.description = "Build a Aimpoint Red Dot at a weapon workbench."
RECIPE.model = "models/props_lab/reciever01a.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_circuitboard"] = 1,
	["craft_uncom_steel"] = 1,
	["craft_com_screws"] = 2
}
RECIPE.skills = {
	["nerdstuff"] = 3
}
RECIPE.results = {
	["ins2_si_rds"] = 1
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
