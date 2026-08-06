-- Adds a "Char Sheet" entry to the tab menu, sorting right after "You" (SortedPairs keys the tab
-- list alphabetically, and "you_charsheet" > "you"). Clicking it closes the tab menu and opens
-- /CharSheet instead of switching to a real subpanel - same PopulateTabButton pattern Settings uses
-- to pin its own button (see helix/gamemode/core/derma/cl_settings.lua) rather than the (nonexistent
-- on this panel) OnCharacterMenuCreated hook, which only fires on the character select screen.
hook.Add("CreateMenuButtons", "ixWastelandCharSheetTab", function(tabs)
    tabs["you_charsheet"] = {
        PopulateTabButton = function(info, button)
            button.OnSelected = function()
                local menu = ix.gui.menu

                if (IsValid(menu)) then
                    menu:Remove()
                end

                ix.command.Send("CharSheet")
            end
        end
    }
end)

ix.lang.AddTable("english", {
    you_charsheet = "Char Sheet"
})
