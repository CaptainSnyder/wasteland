PLUGIN.skills = {
    -- Combat
    {id = "automaticweapons", name = "Automatic Weapons", category = "Combat", attributes = {"awareness", "coordination"}},
    {id = "bigguns", name = "Big Guns", category = "Combat", attributes = {"strength", "coordination"}},
    {id = "brawling", name = "Brawling", category = "Combat", attributes = {"strength", "speed"}},
    {id = "melee", name = "Melee", category = "Combat", attributes = {"strength", "coordination"}},
    {id = "smallarms", name = "Small Arms", category = "Combat", attributes = {"coordination", "awareness"}},
    {id = "snipers", name = "Snipers", category = "Combat", attributes = {"awareness", "intelligence"}},
    {id = "energyweapons", name = "Energy Weapons", category = "Combat", attributes = {"intelligence", "coordination"}},
    {id = "throwing", name = "Throwing", category = "Combat", attributes = {"speed", "coordination"}},
    -- General
    {id = "explosives", name = "Explosives", category = "General", attributes = {"intelligence", "awareness"}},
    {id = "firstaid", name = "First Aid", category = "General", attributes = {"intelligence", "awareness"}},
    {id = "sneakyshit", name = "Sneaky Shit", category = "General", attributes = {"speed", "coordination"}},
    {id = "nerdstuff", name = "Nerd Stuff", category = "General", attributes = {"intelligence", "luck"}},
    {id = "gambling", name = "Gambling", category = "General", attributes = {"luck", "charisma"}},
    -- Exploration
    {id = "lockpicking", name = "Lockpicking", category = "Exploration", attributes = {"coordination", "luck"}},
    {id = "survival", name = "Survival", category = "Exploration", attributes = {"awareness", "intelligence"}},
    {id = "repair", name = "Repair", category = "Exploration", attributes = {"intelligence", "coordination"}},
    {id = "scavenging", name = "Scavenging", category = "Exploration", attributes = {"awareness", "luck"}},
    {id = "vigilance", name = "Vigilance", category = "Exploration", attributes = {"speed", "awareness"}},
    {id = "athletics", name = "Athletics", category = "Exploration", attributes = {"speed", "strength"}},
    {id = "piloting", name = "Piloting", category = "Exploration", attributes = {"speed", "awareness"}},
    -- Social
    {id = "barter", name = "Barter", category = "Social", attributes = {"charisma", "intelligence"}},
    {id = "hardass", name = "Hard Ass", category = "Social", attributes = {"charisma", "strength"}},
    {id = "kissass", name = "Kiss Ass", category = "Social", attributes = {"charisma", "luck"}},
    {id = "leadership", name = "Leadership", category = "Social", attributes = {"charisma", "awareness"}},
    {id = "deception", name = "Deception", category = "Social", attributes = {"charisma", "intelligence"}}
}

-- PLUGIN.skillLevelCost[n] = cost in skill points to raise a skill from level (n - 1) to level n
PLUGIN.skillLevelCost = {1, 1, 1, 2, 2, 3, 3, 4, 5, 6}