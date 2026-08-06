ITEM.name = "Bandage"
ITEM.model = Model("models/illusion/eftcontainers/bandage.mdl")
ITEM.description = "[COMMON] Restores a small portion of health [15]"
ITEM.category = "Medical"
ITEM.price = 20

ITEM.functions.ApplySelf = {
	name = "Use on Self",
	sound = "items/medshot4.wav",
	OnRun = function(itemTable)
		local client = itemTable.player

		client:SetHealth(math.min(client:Health() + 15, client:GetMaxHealth()))
	end
}

ITEM.functions.ApplyOnOther = {
	name = "Use on Other",
	sound = "items/medshot4.wav",
	OnRun = function(itemTable)
		local client = itemTable.player
		local target = GetOtherTreatmentTarget(client)

		if (!target) then
			client:Notify("You aren't aiming at anyone within reach.")
			return false
		end

		target:SetHealth(math.min(target:Health() + 15, target:GetMaxHealth()))
		client:Notify("You bandage " .. target:Name() .. ".")
	end
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		character:GiveMoney(ix.config.Get("rationTokens", math.random(4, 10)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
