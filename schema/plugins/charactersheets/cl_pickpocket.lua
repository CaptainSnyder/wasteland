-- The prompt shown to whoever is being pickpocketed. The thief is deliberately not named: you can see
-- who's stood next to you, and naming them here would hand out information the character wouldn't
-- actually have in the moment
local promptFrame
local waitingFrame

-- the thief's side. holding them here for the whole attempt is the point of it existing: they can't
-- be doing anything else while their target reads a prompt, so /pickpocket can't be used to pin
-- someone in place. closing it is allowed, but it calls the attempt off rather than freeing them up
net.Receive("ixPickpocketWaiting", function()
    if (IsValid(waitingFrame)) then
        waitingFrame:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(320, 130)
    frame:Center()
    frame:SetTitle("Picking a Pocket")
    frame:MakePopup()

    waitingFrame = frame

    local label = frame:Add("DLabel")
    label:SetText("The victim is deciding...")
    label:SetFont("DermaDefaultBold")
    label:SetTextColor(Color(217, 179, 92))
    label:SetContentAlignment(5)
    label:Dock(FILL)
    label:DockMargin(12, 12, 12, 12)

    -- the X is intercepted rather than removed, so backing out stays possible but always deliberate
    frame.btnClose.DoClick = function()
        Derma_Query(
            "If you close this window, you cancel your attempt to pickpocket.",
            "Cancel Attempt?",
            "Cancel the attempt", function()
                net.Start("ixPickpocketCancel")
                net.SendToServer()

                if (IsValid(frame)) then
                    frame:Remove()
                end
            end,
            "Keep waiting", function() end
        )
    end
end)

-- sent to whichever side still has something open once the attempt is over, cancelled or expired
net.Receive("ixPickpocketDismiss", function()
    if (IsValid(waitingFrame)) then
        waitingFrame:Remove()
    end

    if (IsValid(promptFrame)) then
        promptFrame:Remove()
    end
end)

net.Receive("ixPickpocketRequest", function()
    local requestID = net.ReadUInt(32)
    local amount = net.ReadUInt(32)
    local timeout = net.ReadUInt(8)

    if (IsValid(promptFrame)) then
        promptFrame:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(360, 220)
    frame:Center()
    frame:SetTitle("Pickpocket Attempt")
    frame:MakePopup()
    -- no close button: the three options are the only ways out, so an attempt can't be left hanging
    frame:ShowCloseButton(false)

    promptFrame = frame

    local answered = false

    local function Respond(choice)
        if (answered) then
            return
        end

        answered = true

        net.Start("ixPickpocketResponse")
            net.WriteUInt(requestID, 32)
            net.WriteString(choice)
        net.SendToServer()

        frame:Remove()
    end

    local label = frame:Add("DLabel")
    label:SetText("Another player is attempting to pick your pocket.")
    label:SetFont("DermaDefaultBold")
    label:SetTextColor(Color(217, 179, 92))
    label:SetWrap(true)
    label:SetAutoStretchVertical(true)
    label:Dock(TOP)
    label:DockMargin(12, 32, 12, 4)

    local stakeLabel = frame:Add("DLabel")
    stakeLabel:SetText(string.format("They're going for %d scrap.", amount))
    stakeLabel:SetTextColor(Color(190, 190, 190))
    stakeLabel:SetWrap(true)
    stakeLabel:SetAutoStretchVertical(true)
    stakeLabel:Dock(TOP)
    stakeLabel:DockMargin(12, 0, 12, 8)

    local options = {
        {
            label = "Allow",
            choice = "allow",
            tooltip = "Let them take it. No roll."
        },
        {
            label = "Contest",
            choice = "contest",
            tooltip = "Roll your Vigilance against their Sneaky Shit. Beat them and you lose nothing."
        },
        {
            label = "Block",
            choice = "block",
            tooltip = "Please state in LOOC why you blocked the attempt."
        }
    }

    for _, option in ipairs(options) do
        local button = frame:Add("DButton")
        button:SetText(option.label)
        button:SetTall(28)
        button:Dock(TOP)
        button:DockMargin(12, 0, 12, 6)
        button:SetTooltip(option.tooltip)

        button.DoClick = function()
            Respond(option.choice)
        end
    end

    -- the server stops accepting an answer after the same timeout, so an AFK player isn't left with a
    -- dead window on screen and the thief isn't left waiting on one
    timer.Simple(timeout, function()
        if (IsValid(frame) and !answered) then
            answered = true
            frame:Remove()
        end
    end)
end)
