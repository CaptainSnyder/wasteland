RECIPE.name = "Underbarrel Flashlight"
RECIPE.description = "Build a Underbarrel Flashlight at a weapon workbench."
RECIPE.model = "models/props_lab/reciever01a.mdl"
RECIPE.category = "Attachments"
RECIPE.requirements = {
	["craft_uncom_wires"] = 1,
	["craft_uncom_circuitboard"] = 1
}
RECIPE.skills = {
	["nerdstuff"] = 2
}
RECIPE.results = {
	["ins2_ub_flashlight"] = 1
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
