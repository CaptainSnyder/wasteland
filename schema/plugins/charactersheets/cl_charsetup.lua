local charSetupStages = PLUGIN.charSetupStages
local skillList = PLUGIN.skills
local traitList = PLUGIN.traits

local skillsByID = {}

for _, skill in ipairs(skillList) do
    skillsByID[skill.id] = skill
end

local traitsByID = {}

for _, trait in ipairs(traitList) do
    traitsByID[trait.id] = trait
end

local function BuildRewardSummaryText(option)
    local parts = {}

    for _, mod in ipairs(option.attributes or {}) do
        local attribData = ix.attributes.list[mod.target]
        parts[#parts + 1] = string.format("+%d %s", mod.amount, attribData and L(attribData.name) or mod.target)
    end

    for _, mod in ipairs(option.skills or {}) do
        local skill = skillsByID[mod.target]
        parts[#parts + 1] = string.format("+%d %s", mod.amount, skill and skill.name or mod.target)
    end

    if (option.traitID) then
        local trait = traitsByID[option.traitID]
        parts[#parts + 1] = "Trait: " .. (trait and trait.name or option.traitID)
    end

    if (option.bonusSkill) then
        local skill = skillsByID[option.bonusSkill.target]
        parts[#parts + 1] = string.format("+%d %s (bonus)", option.bonusSkill.amount, skill and skill.name or option.bonusSkill.target)
    end

    return table.concat(parts, ", ")
end

local function OpenCharSetupWizard(startingAttributes)
    local stageIndex = 1
    local choices = {}
    local runningAttribs = table.Copy(startingAttributes)

    local frame = vgui.Create("DFrame")
    frame:SetSize(650, 550)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)

    local titleLabel = frame:Add("DLabel")
    titleLabel:SetFont("DermaLarge")
    titleLabel:SetTextColor(Color(217, 179, 92))
    titleLabel:Dock(TOP)
    titleLabel:SetTall(30)
    titleLabel:SetContentAlignment(5)
    titleLabel:DockMargin(10, 10, 10, 0)

    local promptLabel = frame:Add("DLabel")
    promptLabel:SetFont("DermaDefaultBold")
    promptLabel:Dock(TOP)
    promptLabel:SetTall(20)
    promptLabel:SetContentAlignment(5)
    promptLabel:DockMargin(10, 0, 10, 5)

    local bodyContainer = frame:Add("DPanel")
    bodyContainer:Dock(FILL)
    bodyContainer:DockMargin(10, 0, 10, 10)
    bodyContainer.Paint = function() end

    local function ClearBody()
        bodyContainer:Clear()
    end

    -- forward declarations so these can all reference each other
    local ShowStage
    local ShowChoicesReview
    local ShowFinalSummary
    local ShowIntroPage

    local function ResetWizard()
        choices = {}
        runningAttribs = table.Copy(startingAttributes)
        ShowIntroPage()
    end

    local function AddStartOverButton(parent)
        local startOverButton = parent:Add("DButton")
        startOverButton:SetText("Start Over")
        startOverButton:Dock(LEFT)
        startOverButton:SetWide(120)

        startOverButton.DoClick = function()
            Derma_Query(
                "Are you sure you want to start over? All your current choices will be lost.",
                "Start Over?",
                "Yes, start over", function() ResetWizard() end,
                "Cancel", function() end
            )
        end
    end

    ShowChoicesReview = function()
        titleLabel:SetText("Review Your Choices")
        promptLabel:SetText("Take a moment to re-read what you picked at each stage")
        ClearBody()

        local scroll = vgui.Create("DScrollPanel", bodyContainer)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 0, 0, 40)

        for _, stage in ipairs(charSetupStages) do
            local optionID = choices[stage.id]
            local option

            for _, opt in ipairs(stage.options) do
                if (opt.id == optionID) then
                    option = opt
                    break
                end
            end

            if (option) then
                local box = scroll:Add("DPanel")
                box:Dock(TOP)
                box:DockMargin(0, 0, 0, 8)
                box.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
                end

                local stageLabel = box:Add("DLabel")
                stageLabel:SetText(stage.title .. " - " .. option.name)
                stageLabel:SetFont("DermaDefaultBold")
                stageLabel:SetTextColor(Color(217, 179, 92))
                stageLabel:Dock(TOP)
                stageLabel:SetTall(20)
                stageLabel:DockMargin(8, 4, 8, 0)

                local descLabel = box:Add("DLabel")
                descLabel:SetText(option.description)
                descLabel:SetWrap(true)
                descLabel:SetAutoStretchVertical(true)
                descLabel:Dock(TOP)
                descLabel:DockMargin(8, 2, 8, 4)

                box.PerformLayout = function(self, w, h)
                    self:SetTall(24 + descLabel:GetTall() + 8)
                end
            end
        end

        local buttonRow = bodyContainer:Add("DPanel")
        buttonRow:Dock(BOTTOM)
        buttonRow:SetTall(32)
        buttonRow.Paint = function() end

        AddStartOverButton(buttonRow)

        local continueButton = buttonRow:Add("DButton")
        continueButton:SetText("Continue")
        continueButton:Dock(FILL)
        continueButton:DockMargin(5, 0, 0, 0)

        continueButton.DoClick = function()
            ShowFinalSummary()
        end
    end

    ShowFinalSummary = function()
        titleLabel:SetText("Setup Complete")
        promptLabel:SetText("Confirm below to lock in your character - this cannot be undone")
        ClearBody()

        local scroll = vgui.Create("DScrollPanel", bodyContainer)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 0, 0, 40)

        local attribTotals = {}
        local skillTotals = {}
        local traitIDs = {}
        local itemIDs = {}

        for _, stage in ipairs(charSetupStages) do
            local optionID = choices[stage.id]
            local option

            for _, opt in ipairs(stage.options) do
                if (opt.id == optionID) then
                    option = opt
                    break
                end
            end

            if (option) then
                for _, mod in ipairs(option.attributes or {}) do
                    attribTotals[mod.target] = (attribTotals[mod.target] or 0) + mod.amount
                end

                for _, mod in ipairs(option.skills or {}) do
                    skillTotals[mod.target] = (skillTotals[mod.target] or 0) + mod.amount
                end

                if (option.bonusSkill) then
                    skillTotals[option.bonusSkill.target] = (skillTotals[option.bonusSkill.target] or 0) + option.bonusSkill.amount
                end

                if (option.traitID) then
                    traitIDs[#traitIDs + 1] = option.traitID
                end

                for _, itemID in ipairs(option.items or {}) do
                    itemIDs[#itemIDs + 1] = itemID
                end
            end
        end

        local function AddSectionHeader(text)
            local header = scroll:Add("DLabel")
            header:SetText(text)
            header:SetFont("DermaDefaultBold")
            header:SetTextColor(Color(217, 179, 92))
            header:Dock(TOP)
            header:SetTall(22)
            header:DockMargin(0, 8, 0, 2)
        end

        local function AddLine(text)
            local label = scroll:Add("DLabel")
            label:SetText(text)
            label:Dock(TOP)
            label:SetTall(18)
            label:DockMargin(8, 0, 0, 0)
        end

        AddSectionHeader("Attribute Increases")

        local hasAttribs = false

        for attribID, amount in pairs(attribTotals) do
            hasAttribs = true
            local attribData = ix.attributes.list[attribID]
            AddLine(string.format("%s: +%d", attribData and L(attribData.name) or attribID, amount))
        end

        if (!hasAttribs) then
            AddLine("None")
        end

        AddSectionHeader("Starting Skill Levels")

        local hasSkills = false

        for skillID, amount in pairs(skillTotals) do
            hasSkills = true
            local skill = skillsByID[skillID]
            AddLine(string.format("%s: starts at level %d", skill and skill.name or skillID, amount))
        end

        if (!hasSkills) then
            AddLine("None")
        end

        AddSectionHeader("Traits Gained")

        if (#traitIDs == 0) then
            AddLine("None")
        else
            for _, traitID in ipairs(traitIDs) do
                local trait = traitsByID[traitID]
                AddLine(trait and trait.name or traitID)
            end
        end

        AddSectionHeader("Starting Items")

        if (#itemIDs == 0) then
            AddLine("None")
        else
            for _, itemID in ipairs(itemIDs) do
                AddLine(itemID)
            end
        end

        local buttonRow = bodyContainer:Add("DPanel")
        buttonRow:Dock(BOTTOM)
        buttonRow:SetTall(32)
        buttonRow.Paint = function() end

        AddStartOverButton(buttonRow)

        local confirmButton = buttonRow:Add("DButton")
        confirmButton:SetText("Confirm and Begin")
        confirmButton:Dock(FILL)
        confirmButton:DockMargin(5, 0, 0, 0)

        confirmButton.DoClick = function()
            net.Start("ixSubmitCharSetup")
                net.WriteTable(choices)
            net.SendToServer()

            frame:Close()
        end
    end

    -- picks one random option per stage, then drops the player on the choices review page so they can
    -- still read what fate handed them before continuing on to the final summary to confirm
    local function RandomizeAllChoices()
        choices = {}
        runningAttribs = table.Copy(startingAttributes)

        for _, stage in ipairs(charSetupStages) do
            local option = stage.options[math.random(#stage.options)]
            choices[stage.id] = option.id

            for _, mod in ipairs(option.attributes or {}) do
                runningAttribs[mod.target] = math.min((runningAttribs[mod.target] or 0) + mod.amount, 10)
            end
        end

        ShowChoicesReview()
    end

    -- one paragraph, one label - DLabel's auto-stretch height calculation gets unreliable (and clips
    -- the render) when a single label's text contains embedded blank-line breaks, so each paragraph
    -- gets its own label instead of joining them all into one string with "\n\n"
    local INTRO_PARAGRAPHS = {
        "You are another survivor in the wasteland. Whatever you were before doesn't matter much out here - what matters is what you do next.",
        "It's been over a century since the bombs fell in 1998, and the desert Southwest never got the chance to rebuild the way people once hoped. What's left is scattered: fortified settlements clinging to whatever water and scrap they can hold onto, ruins nobody's fully picked clean yet, and a lot of empty, dangerous space in between. Clean water and pre-war tech are worth more than caps out here, and plenty of people are willing to kill you for either.",
        "If you're looking for something resembling law and order, your best bet is the Desert Rangers - survivors who turned an old federal prison into a haven generations back, and who moved on to a proper stronghold of their own, the Ranger Citadel, about fifteen years ago. Not everyone respects the badge, though, and not everyone claiming to keep the peace actually does - outfits like the Red Skorpion Militia like to call themselves peacekeepers while running the same protection rackets raiders always have.",
        "You don't know yet who you'll become out here. Maybe you'll wear a star of your own someday. Maybe you'll end up just another name people stop asking about.",
        "That story starts now - where you came from, what shaped you, and how you ended up standing in the dirt about to find out."
    }

    -- the very first page: brief setting primer for players who've never touched Wasteland before,
    -- then a choice between the normal per-stage flow or randomizing everything up front
    ShowIntroPage = function()
        titleLabel:SetText("Welcome to the Wasteland")
        promptLabel:SetText("Arizona, 2102 - roughly a century after the bombs fell")
        ClearBody()

        local scroll = vgui.Create("DScrollPanel", bodyContainer)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 0, 0, 40)

        for _, paragraph in ipairs(INTRO_PARAGRAPHS) do
            local paragraphLabel = scroll:Add("DLabel")
            paragraphLabel:SetText(paragraph)
            paragraphLabel:SetWrap(true)
            paragraphLabel:SetAutoStretchVertical(true)
            paragraphLabel:Dock(TOP)
            paragraphLabel:DockMargin(4, 0, 4, 10)
        end

        local buttonRow = bodyContainer:Add("DPanel")
        buttonRow:Dock(BOTTOM)
        buttonRow:SetTall(32)
        buttonRow.Paint = function() end

        local randomizeJourneyButton = buttonRow:Add("DButton")
        randomizeJourneyButton:SetText("Randomize Your Journey")
        randomizeJourneyButton:Dock(LEFT)
        randomizeJourneyButton:SetWide(180)

        randomizeJourneyButton.DoClick = function()
            RandomizeAllChoices()
        end

        local startJourneyButton = buttonRow:Add("DButton")
        startJourneyButton:SetText("Start Your Journey")
        startJourneyButton:Dock(FILL)
        startJourneyButton:DockMargin(5, 0, 0, 0)

        startJourneyButton.DoClick = function()
            ShowStage(1)
        end
    end

    ShowStage = function(index)
        stageIndex = index
        local stage = charSetupStages[index]

        titleLabel:SetText(stage.title)
        promptLabel:SetText(stage.prompt)
        ClearBody()

        local scroll = vgui.Create("DScrollPanel", bodyContainer)
        scroll:Dock(FILL)

        for _, option in ipairs(stage.options) do
            local capped = false

            for _, mod in ipairs(option.attributes or {}) do
                if ((runningAttribs[mod.target] or 0) + mod.amount > 10) then
                    capped = true
                end
            end

            local box = scroll:Add("DPanel")
            box:Dock(TOP)
            box:DockMargin(0, 0, 0, 8)
            box.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35))
            end

            local nameLabel = box:Add("DLabel")
            nameLabel:SetText(option.name)
            nameLabel:SetFont("DermaDefaultBold")
            nameLabel:SetTextColor(Color(217, 179, 92))
            nameLabel:Dock(TOP)
            nameLabel:SetTall(20)
            nameLabel:DockMargin(8, 4, 8, 0)

            local descLabel = box:Add("DLabel")
            descLabel:SetText(option.description)
            descLabel:SetWrap(true)
            descLabel:SetAutoStretchVertical(true)
            descLabel:Dock(TOP)
            descLabel:DockMargin(8, 2, 8, 0)

            local rewardLabel = box:Add("DLabel")
            rewardLabel:SetText(BuildRewardSummaryText(option))
            rewardLabel:SetTextColor(Color(150, 190, 150))
            rewardLabel:SetWrap(true)
            rewardLabel:SetAutoStretchVertical(true)
            rewardLabel:Dock(TOP)
            rewardLabel:DockMargin(8, 4, 8, 0)

            local chooseButton = box:Add("DButton")
            chooseButton:Dock(TOP)
            chooseButton:SetTall(26)
            chooseButton:DockMargin(8, 6, 8, 8)

            if (capped) then
                chooseButton:SetText("Unavailable (attribute cap reached)")
                chooseButton:SetEnabled(false)
            else
                chooseButton:SetText("Choose")

                chooseButton.DoClick = function()
                    choices[stage.id] = option.id

                    for _, mod in ipairs(option.attributes or {}) do
                        runningAttribs[mod.target] = math.min((runningAttribs[mod.target] or 0) + mod.amount, 10)
                    end

                    if (stageIndex < #charSetupStages) then
                        ShowStage(stageIndex + 1)
                    else
                        ShowChoicesReview()
                    end
                end
            end

            box.PerformLayout = function(self, w, h)
                self:SetTall(24 + descLabel:GetTall() + 4 + rewardLabel:GetTall() + 4 + 26 + 8)
            end
        end
    end

    ShowIntroPage()
end

net.Receive("ixOpenCharSetup", function(length)
    local startingAttributes = net.ReadTable()
    OpenCharSetupWizard(startingAttributes)
end)

-- reminds the player they haven't finished /charsetup yet; deliberately not a toast Notify() since
-- those disappear on their own - this has to be dismissed with its close button (or one of the two
-- buttons below, both of which count as dismissing it)
net.Receive("ixCharSetupReminder", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(420, 180)
    frame:Center()
    frame:SetTitle("Character Setup Incomplete")
    frame:MakePopup()

    local label = frame:Add("DLabel")
    label:SetText("You haven't completed your character's setup yet. Type /charsetup in chat to begin.")
    label:SetWrap(true)
    label:SetContentAlignment(5)
    label:Dock(FILL)
    label:DockMargin(15, 15, 15, 15)

    local buttonRow = frame:Add("DPanel")
    buttonRow:Dock(BOTTOM)
    buttonRow:SetTall(30)
    buttonRow:DockMargin(15, 0, 15, 15)
    buttonRow.Paint = function() end

    local okButton = buttonRow:Add("DButton")
    okButton:SetText("Okay")
    okButton:Dock(LEFT)
    okButton:SetWide(120)
    okButton.DoClick = function()
        frame:Close()
    end

    local doItButton = buttonRow:Add("DButton")
    doItButton:SetText("I'll do it now")
    doItButton:Dock(RIGHT)
    doItButton:SetWide(120)
    doItButton.DoClick = function()
        ix.command.Send("CharSetup")
        frame:Close()
    end
end)