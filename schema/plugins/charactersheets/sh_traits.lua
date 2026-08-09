-- tier: 0 = purely negative, no mechanical upside at all - free to take, and shown last in both trait
--           browsers despite the number, since a wall of drawbacks isn't a useful thing to open on
--       1 = basic, either a small clean benefit or a genuine give-and-take, available to everyone
--       2 = strong benefit, sometimes a small drawback, staff-rewarded
--       3 = strong benefit, zero drawback, rarely rewarded / GM use
--
-- the line between 0 and 1 is whether the trait gives you anything: Criminal is tier 1 because its
-- charisma penalty buys two skill points, while Cursed is tier 0 because it only takes
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

    -- minor attribute traits: +1 or -1 to a single attribute. the +1 halves are tier 1, the -1 halves
    -- are tier 0, so each pair is split across the two sections in the browser
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
        modifiers = {
            {type = "attribute", target = "coordination", amount = -2},
            {type = "attribute", target = "strength", amount = -1}
        }
    },
    {
        id = "hardofhearing",
        name = "Hard of Hearing",
        description = "Your hearing isn't what it used to be, and it's made you slower to notice danger.",
        tier = 0,
        disadvantageAttributes = {"awareness"},
        disadvantageSkills = {"vigilance"}
    },
    {
        id = "sluggish",
        name = "Sluggish",
        description = "You move noticeably slower than most people around you.",
        tier = 0,
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
        tier = 0,
        disadvantageSkills = {"gambling", "nerdstuff"}
    },
    {
        id = "forgetful",
        name = "Forgetful",
        description = "Names, details, plans - they all seem to slip right out of your head.",
        tier = 0,
        modifiers = {
            {type = "attribute", target = "intelligence", amount = -2}
        },
        disadvantageAttributes = {"intelligence"}
    },
    {
        id = "cursed",
        name = "Cursed",
        description = "Fortune has turned its back on you completely.",
        tier = 0,
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
        tier = 0,
        effectText = "suffers Withdrawal (-1 to all attributes and all skills) whenever you don't have a drug in your system"
        -- no modifiers here - the drawback is entirely mechanical, see the Withdrawal condition and
        -- GetActiveConditions in sh_plugin.lua, which auto-applies Withdrawal to anyone with this trait
        -- unless they currently have a condition flagged suppressesWithdrawal (Drunk, High, etc)
    },
    {
        id = "branded",
        name = "Branded",
        description = "Someone owned you once, and they made sure you'd never forget it - the brand they left on you saw to that. Every time you tried to push back against what was done to you, it was answered with a beating harder than the last, until you stopped pushing back at all. Standing your ground now takes more out of you than it should.",
        tier = 0,
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
        -- tier 3 alongside the Bounties: it's a story thread staff have to agree to and then run,
        -- not something a player can simply declare about themselves
        tier = 3,
        -- set explicitly rather than leaning on the "This is a roleplay trait!" fallback: this one is a
        -- background hook rather than pure flavor. per-trait so the genuinely cosmetic traits (Tattoo)
        -- keep the roleplay wording
        effectText = "This is a background trait"
        -- no modifiers - the actual story beat is meant to be worked out with staff
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
        tier = 0,
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
        tier = 0,
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
        tier = 0,
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
        -- (hunting/entities/entities/harvestable_corpse.lua), not a modifier
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
    },

    -- one advantage trait (tier 2) and one disadvantage trait (tier 1) for every skill, each doing
    -- nothing but set the roll mode - no modifiers, no side effects. three of the pairs are already
    -- covered above and deliberately aren't repeated here: Ghost (advantage Sneaky Shit), Paranoid
    -- (advantage Vigilance) and Fear of Blood (disadvantage First Aid)

    -- Combat
    {
        id = "sprayandpray",
        name = "Spray and Pray",
        description = "You have never once released the trigger early, on the theory that the magazine knows what it's doing. Statistically indefensible. Keeps working anyway.",
        tier = 2,
        advantageSkills = {"automaticweapons"}
    },
    {
        id = "recoilshy",
        name = "Recoil Shy",
        description = "The first round goes exactly where you wanted. The remaining twenty-nine are put to a vote, and you are outnumbered.",
        tier = 0,
        disadvantageSkills = {"automaticweapons"}
    },
    {
        id = "compensating",
        name = "Compensating",
        description = "Nobody has ever asked why you need the biggest gun in the room. They just watch you carry it like it weighs nothing and quietly decide not to bring it up.",
        tier = 2,
        advantageSkills = {"bigguns"}
    },
    {
        id = "badback",
        name = "Bad Back",
        description = "You can lift it. You cannot aim it, hold it steady, or walk normally for the rest of the week, but you can lift it.",
        tier = 0,
        disadvantageSkills = {"bigguns"}
    },
    {
        id = "barregular",
        name = "Bar Regular",
        description = "You've been thrown out of enough places to know exactly how a fight starts, which is how you keep managing to finish them first.",
        tier = 2,
        advantageSkills = {"brawling"}
    },
    {
        id = "glassjaw",
        name = "Glass Jaw",
        description = "You throw a respectable punch. This remains true right up until the moment somebody throws one back at you.",
        tier = 0,
        disadvantageSkills = {"brawling"}
    },
    {
        id = "upcloseandpersonal",
        name = "Up Close and Personal",
        description = "You like your problems within arm's reach. Guns always felt impersonal, and you were never any good at distance in general.",
        tier = 2,
        advantageSkills = {"melee"}
    },
    {
        id = "loosegrip",
        name = "Loose Grip",
        description = "A blade is a simple tool: the pointy end goes in the other person. Yours keeps ending up on the floor between you.",
        tier = 0,
        disadvantageSkills = {"melee"}
    },
    {
        id = "quickdraw",
        name = "Quick Draw",
        description = "The gun is out before you've finished deciding whether it needed to be. So far the timing has worked out more often than not.",
        tier = 2,
        advantageSkills = {"smallarms"}
    },
    {
        id = "pointblankmiss",
        name = "Point Blank Miss",
        description = "You have missed at a range where missing should be physically impossible. Not once. There were witnesses both times.",
        tier = 0,
        disadvantageSkills = {"smallarms"}
    },
    {
        id = "patientsort",
        name = "Patient Sort",
        description = "Nine hours face-down in the dirt for one shot. You describe this as work. Everyone who knows you describes it as a warning sign.",
        tier = 2,
        advantageSkills = {"snipers"}
    },
    {
        id = "caffeineshakes",
        name = "Caffeine Shakes",
        description = "Six cups deep and the crosshair has developed a pulse of its own. You could stop drinking it. You will not.",
        tier = 0,
        disadvantageSkills = {"snipers"}
    },
    {
        id = "wattsup",
        name = "Watt's Up",
        description = "The hum of a charged cell just makes sense to you in a way that people never have. You've stopped mentioning this to people.",
        tier = 2,
        advantageSkills = {"energyweapons"}
    },
    {
        id = "shockprone",
        name = "Shock Prone",
        description = "Every energy weapon you pick up discovers a fresh and creative route to discharge directly into your hand. They cannot all be faulty.",
        tier = 0,
        disadvantageSkills = {"energyweapons"}
    },
    {
        id = "goodarm",
        name = "Good Arm",
        description = "Whatever leaves your hand arrives where you meant it to. This has settled more arguments than it started, though it's been close.",
        tier = 2,
        advantageSkills = {"throwing"}
    },
    {
        id = "cookedittoolong",
        name = "Cooked It Too Long",
        description = "You hold on to things a beat longer than anyone standing near you is comfortable with. Your friends have learned to stand further away.",
        tier = 0,
        disadvantageSkills = {"throwing"}
    },

    -- General
    {
        id = "fusewhisperer",
        name = "Fuse Whisperer",
        description = "You can tell how long a charge has left by the smell of it. Nobody has ever asked you to explain this, and you appreciate that.",
        tier = 2,
        advantageSkills = {"explosives"}
    },
    {
        id = "alltenfingers",
        name = "All Ten Fingers",
        description = "You still have every finger you were born with, a fact you mention constantly and which everyone around you regards as temporary.",
        tier = 0,
        disadvantageSkills = {"explosives"}
    },
    {
        id = "fieldmedic",
        name = "Field Medic",
        description = "You've patched people together in worse light, with worse supplies, while being shot at. A quiet room with clean water feels like cheating.",
        tier = 2,
        advantageSkills = {"firstaid"}
    },
    {
        id = "heavyfooted",
        name = "Heavy Footed",
        description = "Your approach has been described, by people trying to be kind about it, as audible.",
        tier = 0,
        disadvantageSkills = {"sneakyshit"}
    },
    {
        id = "wellactually",
        name = "Well, Actually",
        description = "You retain a staggering volume of information nobody requested. Roughly once a month this saves somebody's life, which you bring up constantly.",
        tier = 2,
        advantageSkills = {"nerdstuff"}
    },
    {
        id = "allergictoreading",
        name = "Allergic to Reading",
        description = "Words arranged in rows make your eyes slide clean off the page. You've gotten this far on pictures and confidence.",
        tier = 0,
        disadvantageSkills = {"nerdstuff"}
    },
    {
        id = "countscards",
        name = "Counts Cards",
        description = "You aren't lucky. You're doing arithmetic and letting everyone at the table assume otherwise, which is the whole trick.",
        tier = 2,
        advantageSkills = {"gambling"}
    },
    {
        id = "dueforawin",
        name = "Due for a Win",
        description = "You've lost eleven hands running. By your reasoning this makes the twelfth a mathematical certainty. It does not.",
        tier = 0,
        disadvantageSkills = {"gambling"}
    },

    -- Exploration
    {
        id = "neverownedakey",
        name = "Never Owned a Key",
        description = "You've gotten into every building you've ever needed to and haven't carried a key since childhood. These two facts are related.",
        tier = 2,
        advantageSkills = {"lockpicking"}
    },
    {
        id = "hamfisted",
        name = "Ham-Fisted",
        description = "Every lock you lay hands on becomes, through sheer force of personality, a permanently sealed door.",
        tier = 0,
        disadvantageSkills = {"lockpicking"}
    },
    {
        id = "ateworse",
        name = "Ate Worse",
        description = "You have eaten things that would hospitalize a healthier person and you are, inexplicably, still standing here talking about it.",
        tier = 2,
        advantageSkills = {"survival"}
    },
    {
        id = "indoorkid",
        name = "Indoor Kid",
        description = "The wasteland is out there. You are aware of this. You would like it to remain out there, and you resent every minute spent in it.",
        tier = 0,
        disadvantageSkills = {"survival"}
    },
    {
        id = "percussivemaintenance",
        name = "Percussive Maintenance",
        description = "Your entire methodology is hitting it until it works. The infuriating part, to everyone watching, is that it works.",
        tier = 2,
        advantageSkills = {"repair"}
    },
    {
        id = "warrantyvoid",
        name = "Warranty Void",
        description = "Everything you repair comes back working, plus one exciting new problem that wasn't there before and that nobody can trace.",
        tier = 0,
        disadvantageSkills = {"repair"}
    },
    {
        id = "onemanstrash",
        name = "One Man's Trash",
        description = "You see value in piles other people walk straight past. Your living space reflects this and your friends have stopped commenting on it.",
        tier = 2,
        advantageSkills = {"scavenging"}
    },
    {
        id = "leftitbehind",
        name = "Left It Behind",
        description = "The good stuff was right there. You looked directly at it. You picked up the other thing and left feeling pleased with yourself.",
        tier = 0,
        disadvantageSkills = {"scavenging"}
    },
    {
        id = "daydreamer",
        name = "Daydreamer",
        description = "You are somewhere else most of the time, and by every account it's a considerably nicer place than this one.",
        tier = 0,
        disadvantageSkills = {"vigilance"}
    },
    {
        id = "cardio",
        name = "Cardio",
        description = "You run every morning, which everyone found ridiculous right up until the day it was the only reason any of you got out.",
        tier = 2,
        advantageSkills = {"athletics"}
    },
    {
        id = "twopacksaday",
        name = "Two Packs a Day",
        description = "Your lungs made their position clear years ago. You've chosen to respect their decision rather than fight it.",
        tier = 0,
        disadvantageSkills = {"athletics"}
    },
    {
        id = "stolencars",
        name = "Learned on Stolen Cars",
        description = "Nobody taught you properly, which is exactly why you're better at it than the people who were taught properly.",
        tier = 2,
        advantageSkills = {"piloting"}
    },
    {
        id = "nolicense",
        name = "No License",
        description = "Nobody ever taught you and you never saw the need to find out. This becomes apparent to your passengers within about four seconds.",
        tier = 0,
        disadvantageSkills = {"piloting"}
    },

    -- Social
    {
        id = "haggler",
        name = "Haggler",
        description = "You have never paid a listed price in your life and you will die on this hill, ideally after talking someone down on the cost of the hill.",
        tier = 2,
        advantageSkills = {"barter"}
    },
    {
        id = "paysaskingprice",
        name = "Pays Asking Price",
        description = "You have never once questioned a number said to you with enough confidence. Merchants have a particular look they get when you walk in.",
        tier = 0,
        disadvantageSkills = {"barter"}
    },
    {
        id = "restingthreatface",
        name = "Resting Threat Face",
        description = "You aren't angry. This is simply your face. People hand things over anyway and you've long since stopped correcting them.",
        tier = 2,
        advantageSkills = {"hardass"}
    },
    {
        id = "pleaseandthankyou",
        name = "Please and Thank You",
        description = "Somebody raised you far too well. You cannot issue a threat without softening it into a request, and it shows.",
        tier = 0,
        disadvantageSkills = {"hardass"}
    },
    {
        id = "shameless",
        name = "Shameless",
        description = "There is no compliment too transparent and no ass too large for you to kiss. You gave up your dignity years ago and have never once missed it.",
        tier = 2,
        advantageSkills = {"kissass"}
    },
    {
        id = "allergictoflattery",
        name = "Allergic to Flattery",
        description = "You are physically incapable of saying something nice that you don't mean, which has cost you more than you'll ever admit.",
        tier = 0,
        disadvantageSkills = {"kissass"}
    },
    {
        id = "loudestintheroom",
        name = "Loudest in the Room",
        description = "It wasn't the best plan available. You just said it first and with total conviction, and it turns out that's most of leadership.",
        tier = 2,
        advantageSkills = {"leadership"}
    },
    {
        id = "committeeofone",
        name = "Committee of One",
        description = "You struggle to get yourself to agree on a plan. Convincing several other armed people to follow it is well beyond you.",
        tier = 0,
        disadvantageSkills = {"leadership"}
    },
    {
        id = "greatliar",
        name = "Terrible Person, Great Liar",
        description = "Everyone who has known you longer than a month agrees on both halves of this. You've made peace with the arrangement.",
        tier = 2,
        advantageSkills = {"deception"}
    },
    {
        id = "awfulpokerface",
        name = "Awful Poker Face",
        description = "Every thought you have arrives on your face a full three seconds before it reaches your mouth, and it always gets there first.",
        tier = 0,
        disadvantageSkills = {"deception"}
    },

    -- more tier 1 filler, since pulling the drawbacks out to tier 0 left it thin. deliberately modest:
    -- a clean one is a single +1, and a give-and-take is +2 paid for with a -1 somewhere thematically
    -- linked. anything stronger belongs in tier 2, which is where the rewards live

    -- clean, no drawback
    {
        id = "greenthumb",
        name = "Green Thumb",
        description = "You can coax food out of dirt that has absolutely no business growing anything, and you've never fully explained how.",
        tier = 1,
        modifiers = {{type = "skill", target = "survival", amount = 1}}
    },
    {
        id = "greasemonkey",
        name = "Grease Monkey",
        description = "You were taking things apart before you could read, and putting most of them back together afterward.",
        tier = 1,
        modifiers = {{type = "skill", target = "repair", amount = 1}}
    },
    {
        id = "localknowledge",
        name = "Local Knowledge",
        description = "You grew up picking over this exact stretch of dirt, and you still remember which piles were worth the walk.",
        tier = 1,
        modifiers = {{type = "skill", target = "scavenging", amount = 1}}
    },
    {
        id = "lightsleeper",
        name = "Light Sleeper",
        description = "You haven't slept through a night since you were twelve. It has ruined your temper and saved your life about equally often.",
        tier = 1,
        modifiers = {{type = "skill", target = "vigilance", amount = 1}}
    },
    {
        id = "bedsidemanner",
        name = "Bedside Manner",
        description = "You talk people through it while you work. Half of them come away swearing that was the part that actually helped.",
        tier = 1,
        modifiers = {{type = "skill", target = "firstaid", amount = 1}}
    },
    {
        id = "knowsaguy",
        name = "Knows a Guy",
        description = "You always know a guy. Nobody has ever met the guy, nobody can describe the guy, but the prices you come back with are real.",
        tier = 1,
        modifiers = {{type = "skill", target = "barter", amount = 1}}
    },
    {
        id = "learnedonatractor",
        name = "Learned on a Tractor",
        description = "Nothing you've driven since has had fewer wheels or more dignity, and you've never once let that slow you down.",
        tier = 1,
        modifiers = {{type = "skill", target = "piloting", amount = 1}}
    },
    {
        id = "hoarderofmanuals",
        name = "Hoarder of Manuals",
        description = "You have read every instruction booklet you've ever found, cover to cover, including several in languages you cannot speak.",
        tier = 1,
        modifiers = {{type = "skill", target = "nerdstuff", amount = 1}}
    },
    {
        id = "knifework",
        name = "Knife Work",
        description = "Years of skinning, gutting, and the occasional disagreement. The motion turns out to be much the same either way.",
        tier = 1,
        modifiers = {{type = "skill", target = "melee", amount = 1}}
    },
    {
        id = "takestheblame",
        name = "Takes the Blame",
        description = "You step up when something goes wrong, which people remember considerably longer than they remember the mistake itself.",
        tier = 1,
        modifiers = {{type = "skill", target = "leadership", amount = 1}}
    },

    -- give-and-take: a real benefit paid for with a related cost
    {
        id = "allbark",
        name = "All Bark",
        description = "You can make a grown man reconsider his entire life in one sentence. You cannot, under any circumstances, be pleasant about it.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "hardass", amount = 2},
            {type = "skill", target = "kissass", amount = -1}
        }
    },
    {
        id = "yesman",
        name = "Yes-Man",
        description = "Agreeing enthusiastically with dangerous people has carried you further than a spine ever would have. You sleep fine.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "kissass", amount = 2},
            {type = "skill", target = "hardass", amount = -1}
        }
    },
    {
        id = "earsareshot",
        name = "Ears Are Shot",
        description = "You know exactly how much to use. You worked it out by using far too much, several times, and your hearing settled the bill.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "explosives", amount = 2},
            {type = "skill", target = "vigilance", amount = -1}
        }
    },
    {
        id = "neverbeenclose",
        name = "Never Been Close",
        description = "You've killed a great many people. You have never once been near enough to smell one, and you intend to keep that record clean.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "snipers", amount = 2},
            {type = "skill", target = "brawling", amount = -1},
            {type = "skill", target = "melee", amount = -1}
        }
    },
    {
        id = "subtleasabrick",
        name = "Subtle as a Brick",
        description = "Your answer to most problems weighs forty pounds and announces its arrival from roughly a mile out.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "bigguns", amount = 2}
        },
        disadvantageSkills = {"sneakyshit"}
    },
    {
        id = "solidstateonly",
        name = "Solid State Only",
        description = "You understand circuits perfectly and engines not at all. Anything with a moving part strikes you as a personal insult.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "energyweapons", amount = 2},
            {type = "skill", target = "repair", amount = -1}
        }
    },
    {
        id = "allbooksnolegs",
        name = "All Books, No Legs",
        description = "You know precisely how the human body works, in detail, and have gone your entire life without meaningfully using yours.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "nerdstuff", amount = 2},
            {type = "skill", target = "athletics", amount = -1}
        }
    },
    {
        id = "housemoney",
        name = "House Money",
        description = "Offered the choice, you would rather gamble someone for it than haggle with them over it. You are markedly better at the first thing.",
        tier = 1,
        modifiers = {
            {type = "skill", target = "gambling", amount = 2},
            {type = "skill", target = "barter", amount = -1}
        }
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
