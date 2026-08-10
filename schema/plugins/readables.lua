PLUGIN.name = "Readables"
PLUGIN.author = "Captain Snyder"
PLUGIN.description = "Opens a reading window for books and documents, driven by the ITEM.pages array on items using the lore base."

if (SERVER) then
	util.AddNetworkString("ixOpenBook")
end

if (CLIENT) then
	surface.CreateFont("ixBookFont", {
		font = "Georgia",
		size = 19,
		weight = 400
	})

	surface.CreateFont("ixBookTitleFont", {
		font = "Georgia",
		size = 26,
		weight = 600
	})

	local bookFrame

	local function OpenBook(itemTable)
		local pages = itemTable.pages or {}

		if (#pages == 0) then
			return
		end

		-- reopening replaces rather than stacking, so reading two books in a row doesn't leave the
		-- first one buried behind the second
		if (IsValid(bookFrame)) then
			bookFrame:Remove()
		end

		local frame = vgui.Create("DFrame")
		frame:SetSize(560, 640)
		frame:Center()
		frame:SetTitle("")
		frame:MakePopup()

		bookFrame = frame

		frame.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(24, 22, 19, 250))
			surface.SetDrawColor(90, 78, 60, 120)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local title = frame:Add("DLabel")
		title:SetText(itemTable.name)
		title:SetFont("ixBookTitleFont")
		title:SetTextColor(Color(217, 179, 92))
		title:SetContentAlignment(5)
		title:Dock(TOP)
		title:SetTall(40)
		title:DockMargin(10, 28, 10, 4)

		-- the page counter and its buttons are docked before the text so the text can FILL what's left
		local footer = frame:Add("DPanel")
		footer:Dock(BOTTOM)
		footer:SetTall(34)
		footer:DockMargin(10, 4, 10, 10)
		footer.Paint = function() end

		local previous = footer:Add("DButton")
		previous:SetText("< Back")
		previous:Dock(LEFT)
		previous:SetWide(90)

		local nextButton = footer:Add("DButton")
		nextButton:SetText("Next >")
		nextButton:Dock(RIGHT)
		nextButton:SetWide(90)

		local counter = footer:Add("DLabel")
		counter:SetFont("DermaDefaultBold")
		counter:SetTextColor(Color(150, 140, 120))
		counter:SetContentAlignment(5)
		counter:Dock(FILL)

		local scroll = vgui.Create("DScrollPanel", frame)
		scroll:Dock(FILL)
		scroll:DockMargin(24, 0, 24, 0)

		local body = scroll:Add("DLabel")
		body:SetFont("ixBookFont")
		body:SetTextColor(Color(214, 204, 186))
		body:SetWrap(true)
		body:SetAutoStretchVertical(true)
		body:Dock(TOP)

		local page = 1

		local function ShowPage(index)
			page = math.Clamp(index, 1, #pages)

			body:SetText(pages[page])
			counter:SetText(string.format("Page %d of %d", page, #pages))

			previous:SetEnabled(page > 1)
			nextButton:SetEnabled(page < #pages)

			-- back to the top on a page turn, or a long page leaves the next one scrolled halfway down
			scroll:ScrollToChild(body)
			scroll:GetVBar():SetScroll(0)
		end

		previous.DoClick = function()
			ShowPage(page - 1)
		end

		nextButton.DoClick = function()
			ShowPage(page + 1)
		end

		ShowPage(1)
	end

	net.Receive("ixOpenBook", function()
		local itemTable = ix.item.list[net.ReadString()]

		if (itemTable) then
			OpenBook(itemTable)
		end
	end)
end
