-- Condition templates. Each has a duration (in hours) and the same modifier format traits use.
-- Items apply these by id via ApplyCharacterCondition(character, id) - see items/sh_painkillers.lua for an example.

-- the 11 clickable regions on the Health tab's body diagram
PLUGIN.bodyRegions = {
    {id = "head", label = "Head"},
    {id = "uppertorso", label = "Upper Torso"},
    {id = "lowertorso", label = "Lower Torso"},
    {id = "upperleftarm", label = "Upper Left Arm"},
    {id = "lowerleftarm", label = "Lower Left Arm"},
    {id = "upperrightarm", label = "Upper Right Arm"},
    {id = "lowerrightarm", label = "Lower Right Arm"},
    {id = "upperleftleg", label = "Upper Left Leg"},
    {id = "lowerleftleg", label = "Lower Left Leg"},
    {id = "upperrightleg", label = "Upper Right Leg"},
    {id = "lowerrightleg", label = "Lower Right Leg"}
}

-- category splits conditions between the two tabs on the character sheet:
--   "health" - shown on the Health tab (either on the body diagram, or its "General" list if region-less)
--   "other"  - shown on the Other Conditions tab (non-physical effects, e.g. drug highs/withdrawal)
-- regionScope controls where a condition can live:
--   "general" - whole-body, never shown on the diagram (region is always nil)
--   "fixed"   - always the same single region (see `region`)
--   "choice"  - one of a fixed list of regions (see `regionOptions`)
--   "any"     - can occur on any of the 11 regions (wound-type conditions like bleeding/infection)
PLUGIN.conditions = {
    {
        id = "painkillers",
        name = "Painkillers",
        description = "A temporary boost to physical toughness, dulling pain enough to push through it.",
        durationHours = 2,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = 2}
        }
    },
    {
        id = "sprainedankle",
        name = "Sprained Ankle",
        description = "A twisted ankle makes it painful to move quickly.",
        durationHours = 2,
        category = "health",
        regionScope = "choice",
        regionOptions = {"lowerleftleg", "lowerrightleg"},
        modifiers = {
            {type = "attribute", target = "speed", amount = -2}
        }
    },
    {
        id = "brokenarm",
        name = "Broken Arm",
        description = "Your arm is in bad shape - lifting, aiming, and fine motor work are all a struggle.",
        durationHours = 12,
        category = "health",
        regionScope = "choice",
        regionOptions = {"upperleftarm", "lowerleftarm", "upperrightarm", "lowerrightarm"},
        modifiers = {
            {type = "attribute", target = "strength", amount = -3},
            {type = "attribute", target = "coordination", amount = -2}
        },
        disadvantageSkills = {"melee", "smallarms", "repair", "lockpicking", "automaticweapons"}
    },
    {
        id = "concussion",
        name = "Concussion",
        description = "Your head is pounding and your thoughts won't stay straight.",
        durationHours = 6,
        category = "health",
        regionScope = "fixed",
        region = "head",
        modifiers = {
            {type = "attribute", target = "intelligence", amount = -3}
        },
        disadvantageSkills = {"nerdstuff", "survival", "explosives"}
    },
    {
        id = "blackeye",
        name = "Black Eye",
        description = "Your vision is swollen and blurry on one side.",
        durationHours = 4,
        category = "health",
        regionScope = "fixed",
        region = "head",
        modifiers = {
            {type = "attribute", target = "awareness", amount = -2}
        },
        disadvantageSkills = {"snipers", "vigilance", "scavenging"}
    },
    {
        id = "brokenribs",
        name = "Broken Ribs",
        description = "Every deep breath and sudden movement is agony.",
        durationHours = 8,
        category = "health",
        regionScope = "fixed",
        region = "uppertorso",
        modifiers = {
            {type = "attribute", target = "strength", amount = -2},
            {type = "attribute", target = "speed", amount = -1}
        },
        disadvantageSkills = {"brawling", "bigguns", "athletics"}
    },
    {
        id = "foodpoisoning",
        name = "Food Poisoning",
        description = "Something you ate is not agreeing with you, at all.",
        durationHours = 3,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "luck", amount = -2}
        },
        disadvantageSkills = {"gambling", "firstaid"}
    },
    {
        id = "disfiguringscar",
        name = "Disfiguring Scar",
        description = "A fresh, ugly wound has left a mark that people can't help but stare at.",
        durationHours = 24,
        category = "health",
        regionScope = "any",
        modifiers = {
            {type = "attribute", target = "charisma", amount = -3}
        },
        disadvantageSkills = {"barter", "kissass", "leadership", "deception", "hardass"}
    },
    {
        id = "twistedwrist",
        name = "Twisted Wrist",
        description = "Your wrist won't cooperate, making anything that needs a steady grip harder.",
        durationHours = 3,
        category = "health",
        regionScope = "choice",
        regionOptions = {"lowerleftarm", "lowerrightarm"},
        modifiers = {
            {type = "attribute", target = "coordination", amount = -2}
        },
        disadvantageSkills = {"energyweapons", "throwing", "piloting"}
    },
    {
        id = "infection",
        name = "Infection",
        description = "A wound has gotten infected, leaving you weak and foggy-headed.",
        durationHours = 4,
        category = "health",
        regionScope = "any",
        modifiers = {
            {type = "attribute", target = "strength", amount = -1},
            {type = "attribute", target = "intelligence", amount = -1}
        },
        disadvantageSkills = {"sneakyshit"}
    },
    {
        id = "fever",
        name = "Fever",
        description = "A burning fever leaves you weak and struggling to concentrate.",
        durationHours = 4,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "intelligence", amount = -2},
            {type = "attribute", target = "strength", amount = -1}
        },
        disadvantageSkills = {"nerdstuff", "survival"}
    },
    {
        id = "lightbleeding",
        name = "Lightly Bleeding",
        description = "A shallow wound is leaking a little blood.",
        durationHours = 1,
        category = "health",
        regionScope = "any",
        modifiers = {
            {type = "attribute", target = "strength", amount = -1}
        }
    },
    {
        id = "moderatebleeding",
        name = "Moderately Bleeding",
        description = "An open wound is steadily draining your strength.",
        durationHours = 2,
        category = "health",
        regionScope = "any",
        modifiers = {
            {type = "attribute", target = "strength", amount = -2},
            {type = "attribute", target = "speed", amount = -1}
        },
        disadvantageSkills = {"athletics", "brawling"}
    },
    {
        id = "severebleeding",
        name = "Severely Bleeding",
        description = "Blood is pouring out of you fast enough to be a real danger.",
        durationHours = 3,
        category = "health",
        regionScope = "any",
        modifiers = {
            {type = "attribute", target = "strength", amount = -3},
            {type = "attribute", target = "speed", amount = -2},
            {type = "attribute", target = "awareness", amount = -1}
        },
        disadvantageSkills = {"athletics", "brawling", "melee"}
    },
    {
        id = "dislocatedshoulder",
        name = "Dislocated Shoulder",
        description = "Your shoulder is out of socket, making it agony to swing or aim with that arm.",
        durationHours = 6,
        category = "health",
        regionScope = "choice",
        regionOptions = {"upperleftarm", "upperrightarm"},
        modifiers = {
            {type = "attribute", target = "strength", amount = -2},
            {type = "attribute", target = "coordination", amount = -1}
        },
        disadvantageSkills = {"melee", "brawling", "smallarms"}
    },
    {
        id = "bloodloss",
        name = "Blood Loss",
        description = "You've lost more blood than your body can spare, and it's taking everything with it.",
        durationHours = 8,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = -3},
            {type = "attribute", target = "speed", amount = -2},
            {type = "attribute", target = "awareness", amount = -1}
        }
    },
    {
        id = "drunk",
        name = "Drunk",
        description = "Alcohol has loosened you up, for better and worse.",
        durationHours = 2,
        category = "other",
        regionScope = "general",
        -- being drunk counts as having your fix - withdrawal won't kick in while this is active
        suppressesWithdrawal = true,
        effectText = "holds off Withdrawal while active",
        modifiers = {
            {type = "attribute", target = "charisma", amount = 1},
            {type = "attribute", target = "coordination", amount = -2},
            {type = "attribute", target = "intelligence", amount = -1}
        },
        disadvantageSkills = {"smallarms", "lockpicking", "piloting"}
    },
    {
        id = "high",
        name = "High",
        description = "You're riding a warm, careless buzz.",
        durationHours = 2,
        category = "other",
        regionScope = "general",
        -- being high counts as having your fix - withdrawal won't kick in while this is active
        suppressesWithdrawal = true,
        effectText = "holds off Withdrawal while active",
        modifiers = {
            {type = "attribute", target = "charisma", amount = 1},
            {type = "attribute", target = "intelligence", amount = -2}
        },
        disadvantageSkills = {"nerdstuff", "lockpicking"}
    },
    {
        id = "withdrawal",
        name = "Withdrawal",
        description = "Your body is screaming for another fix.",
        durationHours = 4,
        category = "other",
        regionScope = "general",
        modifiers = {
            {type = "allAttributes", amount = -1},
            {type = "allSkills", amount = -1}
        }
    },
    {
        id = "prayer",
        name = "Answered Prayer",
        description = "A brief moment of clarity and conviction, sharpening one skill for a short while.",
        durationHours = 12,
        category = "other",
        regionScope = "general",
        modifiers = {},
        -- only ever granted through /pray, which builds its own per-use skill modifier (see the
        -- Pray command in sh_plugin.lua) - hidden from the Other Conditions reference list since
        -- it's never something you'd manually assign
        hideFromList = true
    },
    {
        id = "secondwind",
        name = "Athletics Check",
        description = "Your legs have found a rhythm and your lungs are keeping up with them, for now.",
        durationHours = 1 / 60,
        category = "other",
        regionScope = "general",
        modifiers = {},
        -- only ever granted through /athletics, which supplies its own effect text carrying the
        -- rolled percentage - hidden from the reference list since the effect varies every time
        hideFromList = true
    },
    {
        id = "cigarette",
        name = "Nicotine Buzz",
        description = "A quick smoke steadies your nerves, if only for a little while.",
        durationHours = 10 / 60,
        category = "other",
        regionScope = "general",
        -- the cheapest way to keep withdrawal off your back for a little while
        suppressesWithdrawal = true,
        effectText = "holds off Withdrawal while active",
        modifiers = {
            {type = "attribute", target = "luck", amount = 1}
        }
    },
    -- hunger tiers: re-evaluated and refreshed every tick by the ixHungerTierTick timer in
    -- sh_plugin.lua based on character:GetHunger() (0-100, from the drift-needings plugin) - never
    -- applied any other way, so durationHours is just a short buffer in case a tick is ever missed
    {
        id = "wellfed",
        name = "Well Fed",
        description = "You've eaten well and it shows - steady hands, quick feet, plenty of energy.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = 2},
            {type = "attribute", target = "speed", amount = 1}
        },
        advantageSkills = {"athletics", "brawling"}
    },
    {
        id = "fed",
        name = "Fed",
        description = "You've had enough to eat recently. You're doing just fine.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = 1},
            {type = "attribute", target = "speed", amount = 1}
        },
        advantageSkills = {"athletics"}
    },
    {
        id = "sated",
        name = "Sated",
        description = "You're not full, but you're not hungry either.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = 1}
        }
    },
    {
        id = "peckish",
        name = "Peckish",
        description = "You could go for a bite to eat, but it's not urgent yet.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {}
    },
    {
        id = "hungry",
        name = "Hungry",
        description = "Your stomach won't stop reminding you it's empty.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = -1},
            {type = "attribute", target = "speed", amount = -1}
        }
    },
    {
        id = "nearlystarving",
        name = "Nearly Starving",
        description = "You're running on fumes. Your body is starting to shut down anything it doesn't need to survive.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "strength", amount = -2},
            {type = "attribute", target = "speed", amount = -2}
        },
        disadvantageSkills = {"athletics"}
    },
    {
        id = "starving",
        name = "Starving",
        description = "You are starving, and your body is failing you for it.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "allAttributes", amount = -3}
        },
        disadvantageSkills = {"athletics", "brawling"}
    },
    {
        id = "dyingofstarvation",
        name = "Dying of Starvation",
        description = "Your body has started consuming itself. You are dying of starvation.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "allAttributes", amount = -5}
        },
        disadvantageAllSkills = true,
        disadvantageAllAttributes = true
    },
    -- thirst tiers: same structure and thresholds as the hunger tiers above, just Coordination/
    -- Intelligence instead of Strength/Speed - re-evaluated and refreshed every tick by the
    -- ixThirstTierTick timer in sh_plugin.lua based on character:GetThirst() (0-100)
    {
        id = "wellhydrated",
        name = "Well Hydrated",
        description = "You're properly hydrated and it shows - clear head, steady hands, quick reflexes.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "coordination", amount = 2},
            {type = "attribute", target = "intelligence", amount = 1}
        },
        advantageSkills = {"vigilance", "scavenging"}
    },
    {
        id = "hydrated",
        name = "Hydrated",
        description = "You've had enough to drink recently. You're doing just fine.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "coordination", amount = 1},
            {type = "attribute", target = "intelligence", amount = 1}
        },
        advantageSkills = {"scavenging"}
    },
    {
        id = "quenched",
        name = "Quenched",
        description = "Your thirst is quenched, if not entirely gone.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "coordination", amount = 1}
        }
    },
    {
        id = "thirsty",
        name = "Thirsty",
        description = "You could use something to drink, but it's not urgent yet.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {}
    },
    {
        id = "parched",
        name = "Parched",
        description = "Your mouth is dry and it's getting hard to ignore.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "coordination", amount = -1},
            {type = "attribute", target = "intelligence", amount = -1}
        }
    },
    {
        id = "dehydrated",
        name = "Dehydrated",
        description = "You're dehydrated, and your body isn't working the way it should.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "attribute", target = "coordination", amount = -2},
            {type = "attribute", target = "intelligence", amount = -2}
        },
        disadvantageSkills = {"scavenging"}
    },
    {
        id = "severelydehydrated",
        name = "Severely Dehydrated",
        description = "You are severely dehydrated, and your body is failing you for it.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "allAttributes", amount = -3}
        },
        disadvantageSkills = {"vigilance", "scavenging"}
    },
    {
        id = "dyingofdehydration",
        name = "Dying of Dehydration",
        description = "Your body is shutting down from lack of water. You are dying of dehydration.",
        durationHours = 3 / 60,
        category = "health",
        regionScope = "general",
        modifiers = {
            {type = "allAttributes", amount = -5}
        },
        disadvantageAllSkills = true,
        disadvantageAllAttributes = true
    }
}

-- per-tier tick damage and health floor for the bleeding conditions above; ticks run every 3 real-world minutes (see the sv timer in sh_plugin.lua)
PLUGIN.bleedingTiers = {
    lightbleeding = {floor = 8, damage = 2},
    moderatebleeding = {floor = 50, damage = 5},
    severebleeding = {floor = 15, damage = 9}
}
