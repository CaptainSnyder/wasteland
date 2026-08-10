-- Base for readable documents: books, journals, reports, anything with words in it.
--
-- Helix hands every item in a subfolder the base "base_<foldername>", so anything dropped into
-- items/lore/ inherits this automatically without declaring it. Define ITEM.pages as an array of
-- strings and each entry becomes one page in the reader.
ITEM.name = "Readable"
ITEM.description = "Something with writing on it."
ITEM.model = "models/props_interiors/books02.mdl"
ITEM.category = "Books"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 50
ITEM.pages = {}

ITEM.functions.Read = {
	name = "Read",
	OnRun = function(item)
		local client = item.player

		if (!IsValid(client)) then
			return false
		end

		-- only the uniqueID goes over the wire. item files are shared, so the client already has the
		-- full text in ix.item.list and there's no reason to send several pages of prose per read
		net.Start("ixOpenBook")
			net.WriteString(item.uniqueID)
		net.Send(client)

		-- reading a book never destroys it, unlike the skill books in items/books/
		return false
	end
}

ITEM.functions.Junkify = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()

		-- paper is worth almost nothing as scrap, which is rather the point: selling one on, or just
		-- keeping it, beats tearing it up every time
		character:GiveMoney(ix.config.Get("rationTokens", math.random(1, 3)))
		client:EmitSound("physics/metal/metal_box_break1.wav", 75, math.random(160, 180), 0.35)
	end
}
