-- Example traits — replace/expand this list with your real ones.
-- tier: 1 = basic, usually a drawback, freely available on request
--       2 = strong benefit, sometimes a small drawback, staff-rewarded
--       3 = strong benefit, zero drawback, rarely rewarded / GM use
-- modifiers: {type = "attribute" or "skill", target = <attribute or skill id>, amount = number (can be negative)}
PLUGIN.traits = {
    {
        id = "photographicmemory",
        name = "Photographic Memory",
        description = "You recall nearly everything you've ever read or seen, with no real drawback to speak of.",
        tier = 3,
        modifiers = {
            {type = "attribute", target = "intelligence", amount = 3}
        }
    },
    {
        id = "asshole",
        name = "Asshole",
        description = "You're a natural at bullying people into submission, but genuine social grace is beyond you.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "hardass", amount = 3}
        },
        -- forces a natural 1 on any skill roll in this category, except the listed exemptions
        forceFailCategory = "Social",
        forceFailExcept = {"hardass"}
    },
    {
        id = "violenceaintinmynature",
        name = "Violence Ain't In My Nature",
        description = "You avoid conflict at every turn, favoring practical skills and people skills over aggression.",
        tier = 2,
        -- an entire category rolled with disadvantage (roll twice, take the lower)
        disadvantageCategory = "Combat",
        -- specific skills rolled with advantage (roll twice, take the higher), regardless of category
        advantageSkills = {"firstaid", "nerdstuff", "survival", "repair", "scavenging", "athletics", "barter", "kissass"}
    },
    {
        id = "smallbounty",
        name = "Small Bounty",
        description = "Someone has placed a small bounty on your head. Clear your name with the Desert Rangers to remove this.",
        tier = 3
    },
    {
        id = "largebounty",
        name = "Large Bounty",
        description = "Someone has placed a large bounty on your head. Clear your name with the Desert Rangers to remove this.",
        tier = 3
    },

    -- Tier 1 minor attribute traits: +1 or -1 to a single attribute
    {
        id = "sharpeyed",
        name = "Sharp Eyed",
        description = "You notice things others miss.",
        tier = 1,
        modifiers = {{type = "attribute", target = "awareness", amount = 1}}
    },
    {
        id = "oblivious",
        name = "Oblivious",
        description = "You tend to miss what's going on around you.",
        tier = 1,
        modifiers = {{type = "attribute", target = "awareness", amount = -1}}
    },
    {
        id = "charming",
        name = "Charming",
        description = "People warm up to you easily.",
        tier = 1,
        modifiers = {{type = "attribute", target = "charisma", amount = 1}}
    },
    {
        id = "offputting",
        name = "Off-Putting",
        description = "Something about you rubs people the wrong way.",
        tier = 1,
        modifiers = {{type = "attribute", target = "charisma", amount = -1}}
    },
    {
        id = "nimblefingers",
        name = "Nimble Fingers",
        description = "Your hands are quick and precise.",
        tier = 1,
        modifiers = {{type = "attribute", target = "coordination", amount = 1}}
    },
    {
        id = "butterfingers",
        name = "Butterfingers",
        description = "You fumble things more often than most.",
        tier = 1,
        modifiers = {{type = "attribute", target = "coordination", amount = -1}}
    },
    {
        id = "quicklearner",
        name = "Quick Learner",
        description = "You pick up on things faster than most.",
        tier = 1,
        modifiers = {{type = "attribute", target = "intelligence", amount = 1}}
    },
    {
        id = "slowlearner",
        name = "Slow Learner",
        description = "It takes you a bit longer to understand new things.",
        tier = 1,
        modifiers = {{type = "attribute", target = "intelligence", amount = -1}}
    },
    {
        id = "lucky",
        name = "Lucky",
        description = "Fortune tends to favor you.",
        tier = 1,
        modifiers = {{type = "attribute", target = "luck", amount = 1}}
    },
    {
        id = "unlucky",
        name = "Unlucky",
        description = "Things just don't seem to go your way.",
        tier = 1,
        modifiers = {{type = "attribute", target = "luck", amount = -1}}
    },
    {
        id = "builtforspeed",
        name = "Built for Speed",
        description = "You move quicker than most.",
        tier = 1,
        modifiers = {{type = "attribute", target = "speed", amount = 1}}
    },
    {
        id = "lameleg",
        name = "Lame Leg",
        description = "An old injury slows you down.",
        tier = 1,
        modifiers = {{type = "attribute", target = "speed", amount = -1}}
    },
    {
        id = "sturdy",
        name = "Sturdy",
        description = "You're a bit tougher and stronger than most.",
        tier = 1,
        modifiers = {{type = "attribute", target = "strength", amount = 1}}
    },
    {
        id = "frail",
        name = "Frail",
        description = "You're a bit weaker than most.",
        tier = 1,
        modifiers = {{type = "attribute", target = "strength", amount = -1}}
    },

    -- Tier 2 attribute traits: +2 to one attribute, -1 to two different attributes
    {
        id = "hypervigilant",
        name = "Hyper-Vigilant",
        description = "You're always scanning for danger, leaving little room for social grace or steady hands.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "awareness", amount = 2},
            {type = "attribute", target = "charisma", amount = -1},
            {type = "attribute", target = "coordination", amount = -1}
        }
    },
    {
        id = "silvertongue",
        name = "Silver Tongue",
        description = "You can talk your way into or out of almost anything, though deep thinking and steady hands aren't your strong suit.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "charisma", amount = 2},
            {type = "attribute", target = "coordination", amount = -1},
            {type = "attribute", target = "intelligence", amount = -1}
        }
    },
    {
        id = "steadyhands",
        name = "Steady Hands",
        description = "Your hands never shake, but you're not the brightest, and fortune rarely smiles on you.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "coordination", amount = 2},
            {type = "attribute", target = "intelligence", amount = -1},
            {type = "attribute", target = "luck", amount = -1}
        }
    },
    {
        id = "overthinker",
        name = "Overthinker",
        description = "You analyze everything to death, which slows you down both physically and in the luck department.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "intelligence", amount = 2},
            {type = "attribute", target = "luck", amount = -1},
            {type = "attribute", target = "speed", amount = -1}
        }
    },
    {
        id = "charmedlife",
        name = "Charmed Life",
        description = "Fortune follows you everywhere, but you've never had much need for speed or muscle.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "luck", amount = 2},
            {type = "attribute", target = "speed", amount = -1},
            {type = "attribute", target = "strength", amount = -1}
        }
    },
    {
        id = "recklessrunner",
        name = "Reckless Runner",
        description = "You're fast, but you don't look where you're going, and you're not built for a fight.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "speed", amount = 2},
            {type = "attribute", target = "strength", amount = -1},
            {type = "attribute", target = "awareness", amount = -1}
        }
    },
    {
        id = "brute",
        name = "Brute",
        description = "All muscle, little else - people find you intimidating rather than charming, and subtlety isn't your thing.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "strength", amount = 2},
            {type = "attribute", target = "awareness", amount = -1},
            {type = "attribute", target = "charisma", amount = -1}
        }
    },

    -- Tier 3 attribute traits: +3 to one attribute, zero drawback
    -- (Intelligence is already covered by "Photographic Memory" above)
    {
        id = "eagleeyed",
        name = "Eagle Eyed",
        description = "Your senses are preternaturally sharp, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "awareness", amount = 3}}
    },
    {
        id = "magneticpersonality",
        name = "Magnetic Personality",
        description = "People are naturally drawn to you, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "charisma", amount = 3}}
    },
    {
        id = "perfectbalance",
        name = "Perfect Balance",
        description = "Your body moves with uncanny precision, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "coordination", amount = 3}}
    },
    {
        id = "blessed",
        name = "Blessed",
        description = "Fortune seems to bend in your favor, always, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "luck", amount = 3}}
    },
    {
        id = "lightningreflexes",
        name = "Lightning Reflexes",
        description = "You move faster than should be possible, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "speed", amount = 3}}
    },
    {
        id = "herculean",
        name = "Herculean",
        description = "Your strength borders on superhuman, with no real drawback to speak of.",
        tier = 3,
        modifiers = {{type = "attribute", target = "strength", amount = 3}}
    },
    {
        id = "fearofblood",
        name = "Fear of Blood",
        description = "The sight of blood makes your hands shake and your stomach turn.",
        tier = 1,
        disadvantageSkills = {"firstaid"}
    },
    {
        id = "smoothbrain",
        name = "Smooth Brain",
        description = "You talk just like your brain, which just so happens to be smooth.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "kissass", amount = 2},
            {type = "skill", target = "barter", amount = 2},
            {type = "attribute", target = "intelligence", amount = -2}
        }
    },
    {
        id = "hippocraticoath",
        name = "Hippocratic Oath",
        description = "You've sworn off violence entirely, dedicating yourself to healing rather than harming - a conviction that's left you badly out of practice with every weapon.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "firstaid", amount = 3},
            {type = "skill", target = "automaticweapons", amount = -2},
            {type = "skill", target = "bigguns", amount = -2},
            {type = "skill", target = "brawling", amount = -2},
            {type = "skill", target = "melee", amount = -2},
            {type = "skill", target = "smallarms", amount = -2},
            {type = "skill", target = "snipers", amount = -2},
            {type = "skill", target = "energyweapons", amount = -2},
            {type = "skill", target = "throwing", amount = -2}
        }
    },
    {
        id = "jackofalltrades",
        name = "Jack of All Trades",
        description = "You've dabbled in a little of everything over the years, never mastering one thing but never being truly bad at anything either.",
        tier = 3,
        modifiers = {
            {type = "allSkills", amount = 1}
        }
    },
    {
        id = "criminal",
        name = "Criminal",
        description = "A life of petty crime has sharpened some skills, but soured how people see you.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "lockpicking", amount = 1},
            {type = "skill", target = "sneakyshit", amount = 1},
            {type = "attribute", target = "charisma", amount = -1}
        }
    },
    {
        id = "destructive",
        name = "Destructive",
        description = "You know how to blow things up, but your bedside manner and mechanical touch leave something to be desired.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "explosives", amount = 2},
            {type = "skill", target = "firstaid", amount = -1},
            {type = "skill", target = "repair", amount = -1}
        }
    },
    {
        id = "twofaced",
        name = "Two Faced",
        description = "You're a convincing liar, but the people who actually look up to you tend to see right through it.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "deception", amount = 2},
            {type = "skill", target = "leadership", amount = -1}
        }
    },
    {
        id = "ghost",
        name = "Ghost",
        description = "You move without a sound, and it costs you nothing.",
        tier = 2,
        advantageSkills = {"sneakyshit"}
    },
    {
        id = "mechanicalbrain",
        name = "Mechanical Brain",
        description = "You understand machines far better than you understand people.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "repair", amount = 3},
            {type = "attribute", target = "charisma", amount = -2}
        }
    },
    {
        id = "nevertellmetheodds",
        name = "Never Tell Me The Odds",
        description = "You've beaten the odds more times than you probably should have, though it hasn't done much for your muscles.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "gambling", amount = 2},
            {type = "attribute", target = "luck", amount = 1},
            {type = "attribute", target = "strength", amount = -2}
        }
    },
    {
        id = "hermit",
        name = "Hermit",
        description = "You've spent far more time alone in the wasteland than around people, and it shows both ways.",
        tier = 2,
        disadvantageCategory = "Social",
        advantageSkills = {"survival", "scavenging"}
    },

    -- filling remaining skill gaps: Combat (all 8), Vigilance, Piloting, Leadership
    {
        id = "triggerdiscipline",
        name = "Trigger Discipline",
        description = "Countless hours on the range have paid off, though you've picked up some bad habits with your luck along the way.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "smallarms", amount = 1},
            {type = "skill", target = "automaticweapons", amount = 1},
            {type = "attribute", target = "luck", amount = -1}
        }
    },
    {
        id = "heavyordnance",
        name = "Heavy Ordnance",
        description = "You know your way around the biggest guns in the wasteland, but they aren't exactly easy to carry or aim quickly.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "bigguns", amount = 3},
            {type = "attribute", target = "speed", amount = -1},
            {type = "attribute", target = "coordination", amount = -1}
        }
    },
    {
        id = "coldblooded",
        name = "Cold Blooded",
        description = "You're a patient, calculating killer at range, but that same detachment makes it hard to connect with people.",
        tier = 2,
        advantageSkills = {"snipers"},
        disadvantageAttributes = {"charisma"}
    },
    {
        id = "brawler",
        name = "Brawler",
        description = "You'd rather settle things with your fists than think your way through them.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "brawling", amount = 2},
            {type = "attribute", target = "intelligence", amount = -1}
        }
    },
    {
        id = "bladedancer",
        name = "Blade Dancer",
        description = "You move gracefully with a blade in hand, though you tend to get too focused on your opponent to notice much else.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "melee", amount = 3},
            {type = "attribute", target = "awareness", amount = -1}
        }
    },
    {
        id = "arcwelder",
        name = "Arc Welder",
        description = "You've got an uncanny knack for energy weapons, with no real drawback to speak of.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "energyweapons", amount = 3}
        }
    },
    {
        id = "grenadier",
        name = "Grenadier",
        description = "You've got a great arm and an even better sense of timing, though you don't think too hard about anything else.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "throwing", amount = 2},
            {type = "attribute", target = "intelligence", amount = -1}
        }
    },
    {
        id = "nightwatch",
        name = "Night Watch",
        description = "Years of keeping watch have sharpened your instincts, though you've never had much luck of your own.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "vigilance", amount = 3},
            {type = "attribute", target = "luck", amount = -1}
        }
    },
    {
        id = "acepilot",
        name = "Ace Pilot",
        description = "Behind the wheel or in the cockpit, you're simply better than everyone else, with no real drawback to speak of.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "piloting", amount = 3}
        }
    },
    {
        id = "bornleader",
        name = "Born Leader",
        description = "People naturally look to you for direction, though you've never been especially graceful about anything else.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "leadership", amount = 3},
            {type = "attribute", target = "coordination", amount = -1}
        }
    },
    {
        id = "twitchy",
        name = "Twitchy",
        description = "Your reflexes are lightning fast, but your racing mind makes it hard to think clearly under pressure.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "speed", amount = 1}
        },
        disadvantageAttributes = {"intelligence"}
    },

    -- purely (or mostly) negative traits
    {
        id = "chronicpain",
        name = "Chronic Pain",
        description = "An old injury flares up without warning, sapping your strength and slowing you down.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "strength", amount = -2},
            {type = "attribute", target = "speed", amount = -1}
        },
        disadvantageSkills = {"athletics"}
    },
    {
        id = "onehanded",
        name = "One-Handed",
        description = "You've grown used to relying on your dominant hand alone, and it shows.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "coordination", amount = -2},
            {type = "attribute", target = "strength", amount = -1}
        }
    },
    {
        id = "hardofhearing",
        name = "Hard of Hearing",
        description = "Your hearing isn't what it used to be, and it's made you slower to notice danger.",
        tier = 1,
        disadvantageAttributes = {"awareness"},
        disadvantageSkills = {"vigilance"}
    },
    {
        id = "sluggish",
        name = "Sluggish",
        description = "You move noticeably slower than most people around you.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "speed", amount = -2}
        }
    },
    {
        id = "cowardly",
        name = "Cowardly",
        description = "You'll run before you fight, every single time - and you're very, very good at running.",
        tier = 2,
        disadvantageCategory = "Combat",
        advantageAttributes = {"speed"},
        advantageSkills = {"athletics", "sneakyshit"}
    },
    {
        id = "superstitiousfool",
        name = "Superstitious Fool",
        description = "You put more faith in omens and luck than in facts, and it shows.",
        tier = 1,
        disadvantageSkills = {"gambling", "nerdstuff"}
    },
    {
        id = "forgetful",
        name = "Forgetful",
        description = "Names, details, plans - they all seem to slip right out of your head.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "intelligence", amount = -2}
        },
        disadvantageAttributes = {"intelligence"}
    },
    {
        id = "cursed",
        name = "Cursed",
        description = "Fortune has turned its back on you completely.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "luck", amount = -3}
        }
    },
    {
        id = "divineblessing",
        name = "Divine Blessing",
        description = "A GM-only trait representing overwhelming supernatural favor - advantage on every skill and attribute roll, with absolutely no drawback.",
        tier = 3,
        advantageAllSkills = true,
        advantageAllAttributes = true
    },
    {
        id = "divinecurse",
        name = "Divine Curse",
        description = "A GM-only trait representing overwhelming supernatural misfortune - disadvantage on every skill and attribute roll, with no benefit whatsoever.",
        tier = 3,
        disadvantageAllSkills = true,
        disadvantageAllAttributes = true
    },
    {
        id = "drugaddict",
        name = "Drug Addict",
        description = "You're hooked - go too long without something to take the edge off and your body will make you regret it.",
        tier = 1,
        effectText = "suffers Withdrawal (-1 to all attributes and all skills) whenever you don't have a drug in your system"
        -- no modifiers here - the drawback is entirely mechanical, see the Withdrawal condition and
        -- GetActiveConditions in sh_plugin.lua, which auto-applies Withdrawal to anyone with this trait
        -- unless they currently have a condition flagged suppressesWithdrawal (Drunk, High, etc)
    },
    {
        id = "branded",
        name = "Branded",
        description = "Someone owned you once, and they made sure you'd never forget it - the brand they left on you saw to that. Every time you tried to push back against what was done to you, it was answered with a beating harder than the last, until you stopped pushing back at all. Standing your ground now takes more out of you than it should.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "charisma", amount = -1}
        },
        disadvantageSkills = {"hardass"}
    },
    {
        id = "paranoid",
        name = "Paranoid",
        description = "You're always watching for the next threat, the next betrayal, the next reason to run. It's exhausting to live like that, but it's kept you alive more than once.",
        tier = 2,
        advantageSkills = {"vigilance"}
    },
    {
        id = "tattoo",
        name = "Tattoo",
        description = "You've got a tattoo somewhere on you. It doesn't do anything mechanically - it's just yours.",
        tier = 1
        -- purely a roleplay trait, no modifiers, no advantage/disadvantage
    },
    {
        id = "unbroken",
        name = "Unbroken",
        description = "You know exactly what it feels like to have every choice taken from you, down to the smallest ones. Nobody gets to do that to you again - not to your body, not to your freedom to move, and not without a fight.",
        tier = 2,
        modifiers = {
            {type = "attribute", target = "coordination", amount = 1}
        },
        advantageSkills = {"athletics", "melee"}
    },
    {
        id = "onelasttarget",
        name = "One Last Target...",
        description = "Due to your complicated past, there is one last target you feel obligated to take care of. Note: Discuss this trait with a GM.",
        tier = 1
        -- purely a roleplay hook trait, no modifiers - the actual story beat is meant to be worked out with staff
    },
    {
        id = "rangertraining",
        name = "Ranger Training",
        description = "The Rangers don't let anyone wear the star without putting them through real training first - fieldcraft, endurance drills, hours spent learning to read terrain and stay alert even when exhausted. Whether or not you ever actually earn that star, the training itself stuck, and it shows every time you're out in the wasteland.",
        tier = 2,
        modifiers = {
            {type = "skill", target = "survival", amount = 1},
            {type = "skill", target = "athletics", amount = 1},
            {type = "attribute", target = "awareness", amount = 1}
        }
    },
    {
        id = "religious",
        name = "Religious",
        description = "Your faith runs deep, and it shows when you pray - whatever skill you ask for guidance in, you receive twice the clarity everyone else does.",
        tier = 2,
        effectText = "doubles the skill bonus you get from /pray"
        -- doubles the skill bonus granted by /pray - checked directly in the Pray command, not a modifier
    },
    {
        id = "atheist",
        name = "Atheist",
        description = "You put your faith in nothing but yourself, and it's kept your head clear. You cannot use /pray, but you carry a permanent +1 to Luck.",
        tier = 1,
        modifiers = {
            {type = "attribute", target = "luck", amount = 1}
        },
        effectText = "cannot use /pray at all",
        -- blocks /pray entirely - checked directly in the Pray command, not a modifier
        preventsPray = true
    },
    {
        id = "scrapfinder",
        name = "Scrap Finder",
        description = "Even when you find just about nothing, you can still somehow manage to get a little bit of scrap.",
        tier = 1,
        effectText = "every scavenge or lockpick attempt also pays scrap - 1-10 when you find something, 1-20 when you don't"
        -- grants bonus ration tokens on every scavenge/lockpick attempt - checked directly in
        -- ResolveScavengeResult (scavenging/sh_plugin.lua), not a modifier
    },
    {
        id = "poornutritionalhabits",
        name = "Poor Nutritional Habits",
        description = "You've never had a good relationship with food and water. Whatever you eat or drink just doesn't do as much for you.",
        tier = 1,
        effectText = "food and drink restore 25% less than normal"
        -- reduces the effect of every food/drink item by 25% - checked directly in the shared
        -- Apply function (drift-needings/items/base/sh_foods.lua), not a modifier
    },
    {
        id = "carefulrationing",
        name = "Careful Rationing",
        description = "You know how to make the most of every meal and every drop of water.",
        tier = 2,
        effectText = "food and drink restore 25% more than normal"
        -- increases the effect of every food/drink item by 25% - checked directly in the shared
        -- Apply function (drift-needings/items/base/sh_foods.lua), not a modifier
    },
    {
        id = "bigappetite",
        name = "Big Appetite",
        description = "You burn through food fast, no matter how much you eat.",
        tier = 1,
        effectText = "hunger drains 25% faster"
        -- hunger drains 25% faster - checked directly in GetHungerInterval (drift-needings/sv_hooks.lua),
        -- which the ixNeedsDecayTick timer re-reads every tick, so it applies without a respawn
    },
    {
        id = "smallappetite",
        name = "Small Appetite",
        description = "You've always gotten by on less food than most people need.",
        tier = 2,
        effectText = "hunger drains 25% slower"
        -- hunger drains 25% slower - checked directly in GetHungerInterval (drift-needings/sv_hooks.lua),
        -- which the ixNeedsDecayTick timer re-reads every tick, so it applies without a respawn
    },
    {
        id = "unquenchablethirst",
        name = "Unquenchable Thirst",
        description = "No matter how much you drink, you're parched again before long.",
        tier = 1,
        effectText = "thirst drains 25% faster"
        -- thirst drains 25% faster - checked directly in GetThirstInterval (drift-needings/sv_hooks.lua),
        -- which the ixNeedsDecayTick timer re-reads every tick, so it applies without a respawn
    },
    {
        id = "camelsconstitution",
        name = "Camel's Constitution",
        description = "Your body holds onto water far better than most people's.",
        tier = 2,
        effectText = "thirst drains 25% slower"
        -- thirst drains 25% slower - checked directly in GetThirstInterval (drift-needings/sv_hooks.lua),
        -- which the ixNeedsDecayTick timer re-reads every tick, so it applies without a respawn
    },
    {
        id = "wastenotwantnot",
        name = "Waste Not Want Not",
        description = "You never leave a kill half-stripped. Every creature you harvest, you go back over a second time to make sure you didn't miss anything.",
        tier = 2,
        effectText = "doubles your harvest attempts on a creature corpse - two Survival rolls instead of one"
        -- doubles the number of independent harvest attempts (each its own Survival roll) when
        -- harvesting a creature corpse - checked directly in the corpse entity's Use function
        -- (hunting/entities/entities/molerat_corpse.lua), not a modifier
    },

    -- age traits: exact mirrors of each other, so one's advantage is the other's disadvantage.
    -- tier 3 because age is a story detail a GM signs off on, not something anyone can just claim -
    -- there's no age field on a character, so the requirement in each description is enforced by
    -- staff at the point the trait is granted. deliberately roll-mode only rather than flat stats:
    -- a large share of characters could plausibly qualify for one of these, so the effect should be
    -- situational instead of a permanent edge everyone carries
    {
        id = "young",
        name = "Young",
        description = "You're under 21. You've got the energy and the fight in you that the older folks lost years ago, but nobody in this wasteland is going to take orders from a kid, and threatening someone twice your age tends to get you laughed at.",
        tier = 3,
        advantageSkills = {"athletics", "brawling"},
        disadvantageSkills = {"hardass", "leadership"}
    },
    {
        id = "old",
        name = "Old",
        description = "You're 60 or older. Six decades out here bought you a voice people actually listen to and a stare that ends arguments, but your body settled that debt a long time ago - running and fighting are young people's work now.",
        tier = 3,
        advantageSkills = {"hardass", "leadership"},
        disadvantageSkills = {"athletics", "brawling"}
    }
}

-- builds a readable mechanical summary from a trait's modifiers, e.g. "+2 Strength, -1 Speed"
local skillsByID = {}

for _, skill in ipairs(PLUGIN.skills) do
    skillsByID[skill.id] = skill
end

PLUGIN.FormatTraitModifiers = function(trait)
    local parts = {}

    for _, mod in ipairs(trait.modifiers or {}) do
        local targetName = mod.target

        if (mod.type == "attribute") then
            local attribData = ix.attributes.list[mod.target]
            targetName = attribData and L(attribData.name) or mod.target
        elseif (mod.type == "skill") then
            local skill = skillsByID[mod.target]
            targetName = skill and skill.name or mod.target
        elseif (mod.type == "allSkills") then
            targetName = "all skills"
        elseif (mod.type == "allAttributes") then
            targetName = "all attributes"
        end

        local sign = (mod.amount >= 0) and "+" or ""
        parts[#parts + 1] = string.format("%s%d %s", sign, mod.amount, targetName)
    end

    if (trait.forceFailCategory) then
        parts[#parts + 1] = string.format("automatically rolls a natural 1 on any other %s skill", trait.forceFailCategory)
    end

    if (trait.disadvantageCategory) then
        parts[#parts + 1] = string.format("all %s skills rolled with disadvantage", trait.disadvantageCategory)
    end

    if (trait.advantageSkills and #trait.advantageSkills > 0) then
        local skillNames = {}

        for _, sid in ipairs(trait.advantageSkills) do
            local skill = skillsByID[sid]
            skillNames[#skillNames + 1] = skill and skill.name or sid
        end

        parts[#parts + 1] = "advantage on " .. table.concat(skillNames, ", ")
    end

    if (trait.disadvantageSkills and #trait.disadvantageSkills > 0) then
        local skillNames = {}

        for _, sid in ipairs(trait.disadvantageSkills) do
            local skill = skillsByID[sid]
            skillNames[#skillNames + 1] = skill and skill.name or sid
        end

        parts[#parts + 1] = "disadvantage on " .. table.concat(skillNames, ", ")
    end

    if (trait.advantageAttributes and #trait.advantageAttributes > 0) then
        local attribNames = {}

        for _, aid in ipairs(trait.advantageAttributes) do
            local attribData = ix.attributes.list[aid]
            attribNames[#attribNames + 1] = attribData and L(attribData.name) or aid
        end

        parts[#parts + 1] = "advantage on " .. table.concat(attribNames, ", ") .. " rolls"
    end

    if (trait.disadvantageAttributes and #trait.disadvantageAttributes > 0) then
        local attribNames = {}

        for _, aid in ipairs(trait.disadvantageAttributes) do
            local attribData = ix.attributes.list[aid]
            attribNames[#attribNames + 1] = attribData and L(attribData.name) or aid
        end

        parts[#parts + 1] = "disadvantage on " .. table.concat(attribNames, ", ") .. " rolls"
    end

    if (trait.advantageAllSkills) then
        parts[#parts + 1] = "advantage on all skills"
    end

    if (trait.advantageAllAttributes) then
        parts[#parts + 1] = "advantage on all attributes"
    end

    if (trait.disadvantageAllSkills) then
        parts[#parts + 1] = "disadvantage on all skills"
    end

    if (trait.disadvantageAllAttributes) then
        parts[#parts + 1] = "disadvantage on all attributes"
    end

    -- plenty of traits and conditions have their mechanics implemented in code rather than in a
    -- modifier table (Drug Addict's Withdrawal, Scrap Finder's payout, the hunger/thirst rates, and
    -- so on). without a written effect they produce an empty summary, and the sheet then falls back
    -- to "This is a roleplay trait!" - which is flatly wrong for anything that does something
    if (trait.effectText) then
        parts[#parts + 1] = trait.effectText
    end

    return table.concat(parts, ", ")
end