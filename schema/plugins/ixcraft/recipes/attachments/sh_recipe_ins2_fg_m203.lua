RECIPE.name = "M203 Grenade Launcher"
RECIPE.description = "Build a M203 Grenade Launcher at a weapon workbench."
RECIPE.model = "models/weapons/w_grenade.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_steel"] = 3,
	["craft_com_gears"] = 2,
	["craft_rare_weaponparts"] = 1
}
RECIPE.skills = {
	["explosives"] = 6
}
RECIPE.results = {
	["ins2_fg_m203"] = 1
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
