RECIPE.name = "Recycling Chip"
RECIPE.description = "Build a Recycling Chip at a weapon workbench."
RECIPE.model = "models/props_lab/reciever01c.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_circuitboard"] = 1,
	["craft_uncom_wires"] = 1
}
RECIPE.skills = {
	["energyweapons"] = 5
}
RECIPE.results = {
	["wl_recyclingchip"] = 1
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
