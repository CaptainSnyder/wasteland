RECIPE.name = "Plasma Converter"
RECIPE.description = "Build a Plasma Converter at a weapon workbench."
RECIPE.model = "models/props_lab/reciever01d.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_rare_powersupply"] = 1,
	["craft_uncom_circuitboard"] = 2,
	["craft_rare_weaponparts"] = 1
}
RECIPE.skills = {
	["energyweapons"] = 8
}
RECIPE.results = {
	["wl_plasmaconverter"] = 1
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
