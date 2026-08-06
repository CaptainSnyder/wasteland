ITEM.name = "General Skill Book"
ITEM.description = "A dog-eared compilation of general survival know-how. The pages are brittle and yellowed - poring over it will probably be the last thing it's good for."
ITEM.model = "models/props_interiors/books02.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Skill Books"
ITEM.price = 2000

ITEM.functions.Read = {
	name = "Read",
	isMulti = true,
	multiOptions = function(itemTable, client)
		local character = client:GetCharacter()
		local invested = character and character:GetData("skills", {}) or {}
		local options = {}

		for _, skill in ipairs(GetSkillsInCategory("General")) do
			local level = invested[skill.id] or 0
			local label = (level >= 10) and (skill.name .. " (MAXED)") or (skill.name .. " (" .. level .. "/10)")

			options[#options + 1] = {name = label, data = {skillID = skill.id}}
		end

		return options
	end,
	OnRun = function(item, data)
		local client = item.player
		local skillID = data and data.skillID
		local skillData = skillID and FindSkillByID(skillID)

		if (!skillData or skillData.category != "General") then
			return false
		end

		return GrantSkillLevel(client, skillID)
	end
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(200, 400)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
