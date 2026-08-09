-- One-time narrative character setup. Each stage has options granting attribute points,
-- skill starting levels, an optional trait, an optional bonus skill (paired with traits that
-- carry an attribute penalty), and optional starting items (left empty as placeholders for now).
PLUGIN.charSetupStages = {
    {
        id = "origin",
        title = "Origin",
        prompt = "Where did you come from?",
        options = {
            {
                id = "agriculturalcenter",
                name = "Agricultural Center",
                description = "You grew up behind the high adobe walls of the Agricultural Center, a farming settlement built around the bones of an old satellite relay station that somehow survived the war intact. The dish still worked, and the old crew who'd manned it stayed on after the bombs fell, teaching anyone who'd listen the old-world science buried in its systems, right alongside the day-to-day work of keeping crops alive behind barbed wire and scorched walls. It wasn't exactly peaceful - mutated things came out of the desert for the fields more often than anyone liked - but between the tech and the constant watch-keeping, you came out of it both sharper and more alert than most people your age. You learned early that survival and old-world knowledge weren't as separate as people assumed.",
                attributes = {{target = "intelligence", amount = 2}, {target = "awareness", amount = 1}}
            },
            {
                id = "outofstate",
                name = "From Out of State",
                description = "You didn't grow up here. Wherever you came from, it wasn't Arizona, and you've never been in much of a hurry to explain exactly how you ended up in this stretch of wasteland instead of wherever home used to be. Whatever happened on the way taught you to adapt fast to places and people you didn't understand yet, picking up new ways of doing things without much choice in the matter. It's left you a little hard to place, an outsider even among people who've never known anything but the wasteland themselves, but it also means you've never been boxed in by the way things are \"supposed\" to be done around here. Some folks find that unsettling. You've learned to make it work for you.",
                attributes = {{target = "coordination", amount = 2}, {target = "luck", amount = 1}}
            },
            {
                id = "caravaner",
                name = "Caravaner",
                description = "You grew up on the move, riding in the back of a caravan long before you were old enough to walk beside it. Every settlement was a stopover, every face a stranger you'd likely never see again, and every night around the fire meant learning to read people fast - who to trust, who to charm, who to avoid. You learned the roads better than most people learn their own hometown, and you picked up the rhythm of talking your way past trouble instead of fighting through it. That constant motion also sharpened your reflexes; standing still never felt natural to you. By the time you were old enough to strike out on your own, you already knew how to move fast and talk faster.",
                attributes = {{target = "charisma", amount = 2}, {target = "speed", amount = 1}}
            },
            {
                id = "takenin",
                name = "Taken In",
                description = "You don't remember much about your real parents - just vague, fading pieces that might not even be true anymore. What you do remember clearly is the raiders who killed them and decided you were more useful alive than dead, dragging you along afterward instead of leaving you in the dirt. They didn't raise you so much as use you - running messages, picking locks, squeezing through gaps too small for grown men, doing whatever needed a body nobody would miss if it went wrong. You grew up surrounded by casual violence that never quite touched you directly, watching people who'd killed your family laugh around a fire like it was nothing, because to them, it was. Whatever you are now, some of that camp never really washed off.",
                attributes = {{target = "coordination", amount = 2}, {target = "awareness", amount = 1}}
            },
            {
                id = "rangercenter",
                name = "Ranger Center",
                description = "You grew up inside the walls of the Ranger Center, the old federal prison the Desert Rangers converted into their headquarters generations back - this was still back when it was their headquarters, years before they ever relocated to the Ranger Citadel, and it might be the safest upbringing anyone gets out here. Behind those old reinforced walls and light-industrial workshops, you had actual structure - lessons, drills, work rotations - without ever having to face the wasteland outside them the way most kids do. The Rangers who raised you treated discipline and community in equal measure, and you came out of it well-rounded in a way that's hard to fake: sharp enough to think things through, personable enough to get along with strangers, and steady enough with your hands to be useful. You never had to earn your safety the hard way, and you know it - which is exactly why you've never taken it for granted.",
                attributes = {{target = "intelligence", amount = 1}, {target = "charisma", amount = 1}, {target = "coordination", amount = 1}}
            },
            {
                id = "quartz",
                name = "Quartz",
                description = "You grew up in Quartz, a small town far enough from any real military target that nobody expected the war to touch it at all - and yet the earthquakes and the low-level fallout came anyway, cracking foundations and poisoning wells that were supposed to be safe. The town held together regardless, stubborn in the way small places sometimes are, and growing up in its aftermath taught you to notice the cracks other people walked past - in buildings, in people, in situations that were about to go bad. There's a persistent, slightly superstitious streak in everyone from Quartz, the sense that surviving what shouldn't have touched you at all has to count for something. You've never quite shaken that feeling, or the luck that seems to come with it.",
                attributes = {{target = "luck", amount = 2}, {target = "awareness", amount = 1}}
            },
            {
                id = "lasvegas",
                name = "Las Vegas",
                description = "You grew up in Las Vegas, one of the strange places the missiles somehow missed entirely, and the city never let anyone forget it - the house doesn't lose, and neither, as far as Vegas is concerned, did Vegas. You came up around casino floors and the desert rabble who found steady work as enforcers and staff once the dust settled, learning fast how to read a room, work a crowd, and understand that everything in this city runs on odds and nerve in equal measure. It gave you a natural charm and a gambler's instinct for when the odds were actually in your favor, whether you were placing a bet or just placing your trust in the wrong person. Vegas taught you that confidence and luck look a lot alike from the outside, and after a childhood there, you've got plenty of both.",
                attributes = {{target = "charisma", amount = 1}, {target = "luck", amount = 2}}
            },
            {
                id = "slavery",
                name = "Slavery",
                description = "You were born into slavery, plain and simple, and there's no dressing that up into something easier to hear. From as early as you can remember, your life belonged to someone else - your labor, your time, your body all spoken for before you ever had a say in the matter. You learned to work through exhaustion because the alternative was worse, and you learned to read a master's mood before they'd even finished walking into the room, because getting that wrong cost more than it was ever worth. It built a kind of toughness into you that nobody should have to earn that way, and an instinct for watching everyone around you that's never really switched off. Whatever freedom you've got now, you know exactly what it's worth, because you remember what it was like without it.",
                attributes = {{target = "strength", amount = 2}, {target = "awareness", amount = 1}}
            }
        }
    },
    {
        id = "childhood",
        title = "Childhood",
        prompt = "What did you like to do as a kid?",
        options = {
            {
                id = "tinkering",
                name = "Tinkering",
                description = "You were always taking apart old radios, busted terminals, and anything else with wires just to see how it worked - and more often than you'd like to admit, you couldn't quite get it back together. Broken machines fascinated you more than toys ever did, and you spent hours elbow-deep in scrap trying to coax a spark of life out of something everyone else had given up on. It taught you patience with problems that didn't have an obvious solution, and a real feel for how things fit together. By the time you were old enough to leave home, you'd already fixed more busted junk than most adults ever bother trying.",
                attributes = {{target = "intelligence", amount = 1}},
                skills = {{target = "repair", amount = 2}}
            },
            {
                id = "playingranger",
                name = "Playing Ranger",
                description = "Every kid in your settlement wanted to be a Desert Ranger at some point, but you were the one who never really grew out of it. You organized patrols around the fence line that weren't really patrols at all, appointed lookouts who weren't really guarding anything, and took the whole thing dead seriously even when everyone else had moved on to some other game. It probably looked ridiculous to the adults watching, but the habit of always knowing what's happening around you stuck around long after the pretend badges did. You've never quite lost the sense that someone ought to be keeping watch, and it might as well be you.",
                attributes = {{target = "awareness", amount = 1}},
                skills = {{target = "vigilance", amount = 2}}
            },
            {
                id = "fivefingerdiscount",
                name = "Five-Finger Discount",
                description = "You got good at lifting things from vendors and other kids without them ever noticing - a coin here, a trinket there, nothing anyone would miss until it was already gone. It started as a game, seeing how close you could get without getting caught, but the thrill of it never quite left you even as you got older. Your hands got quicker and quieter with practice, and you learned to read a crowd well enough to know exactly when to move. Nobody ever really taught you that it was wrong; you just got very, very good at it.",
                attributes = {{target = "coordination", amount = 1}},
                skills = {{target = "sneakyshit", amount = 2}}
            },
            {
                id = "playingnurse",
                name = "Playing Nurse",
                description = "Whether it was a sick neighbor, a hurt stray dog, or a friend who'd scraped a knee too deep, you were always the one who stepped in to patch things up. You picked up bits of real medical knowledge wherever you could find it, practicing on anyone who'd let you and plenty who didn't have much choice. It came naturally to you - a steady hand, a calm voice, and a genuine want to make someone's pain go away. People started coming to you before they went to anyone else, and that trust meant something to you, even as a kid.",
                attributes = {{target = "charisma", amount = 1}},
                skills = {{target = "firstaid", amount = 2}}
            },
            {
                id = "bottlecapgames",
                name = "Bottle Cap Games",
                description = "You spent more time than you probably should have gambling scraps and bottle caps with the other kids, and somewhere in all those games you developed a real feel for the odds. You learned to read a bluff, know when to push your luck and when to fold, and walk away with more caps than you started with more often than not. It wasn't always about the caps themselves - it was the rush of the game, the small thrill of coming out ahead. That instinct for risk and reward has stuck with you ever since.",
                attributes = {{target = "luck", amount = 1}},
                skills = {{target = "gambling", amount = 2}}
            },
            {
                id = "scraprunner",
                name = "Scrap Runner",
                description = "You spent your childhood darting through the ruins on the edge of town, sent out by adults too busy or too tired to go themselves, always racing the sun back home before dark caught up with you. You got fast doing it - genuinely fast - weaving through collapsed buildings and half-buried debris like you'd mapped every inch of it in your head. Along the way you picked up a real eye for what was worth grabbing and what wasn't, the kind of instinct that only comes from digging through other people's leftovers for half your life. It wasn't glamorous work, but it taught you plenty that stuck.",
                attributes = {{target = "speed", amount = 1}},
                skills = {{target = "scavenging", amount = 2}}
            },
            {
                id = "curioushands",
                name = "Curious Hands",
                description = "You couldn't leave a locked door, box, or footlocker alone if your life depended on it, and you spent half your childhood taking apart every latch and padlock you could get your hands on just to see how they worked. Most of the time you got caught before you figured it out, but often enough you didn't, and the feeling of a stubborn lock finally giving way never really got old. Nobody taught you properly - you just kept at it until your fingers learned what your eyes couldn't quite explain. It's a strange thing to be proud of, but you are anyway - useful hands, you learned early, tend to get put to use one way or another.",
                attributes = {{target = "coordination", amount = 1}},
                skills = {{target = "lockpicking", amount = 2}}
            },
            {
                id = "bookworm",
                name = "Book Worm",
                description = "While other kids were out getting into trouble, you were curled up with whatever pre-war books, manuals, and half-rotted magazines you could scrounge, soaking up a world that didn't exist anymore. You didn't just read for fun - you actually retained the strange, oddly specific trivia buried in those pages, the kind of stuff that never seems useful until suddenly it is. It made you a bit of an odd kid, more comfortable with old words than new people, but it gave you a mind stuffed full of things nobody else around you ever bothered to learn. That habit never really faded.",
                attributes = {{target = "intelligence", amount = 1}},
                skills = {{target = "nerdstuff", amount = 2}}
            },
            {
                id = "childslavery",
                name = "Slavery",
                description = "There wasn't much room for playing as a kid when your days were already spoken for. You spent your childhood doing whatever forced labor you were put to - hauling, digging, whatever kept you useful enough to feed - and you got physically tougher for it long before you had any say in the matter. What free time you did scrape together went into learning how to get by on nothing, because scraps and leftovers were the only things anyone was willing to spare you. It sucked, plain and simple, and no amount of looking back on it kindly is going to change that. Some people are just born unlucky, and you learned that lesson a lot earlier than most.",
                attributes = {{target = "strength", amount = 1}},
                skills = {{target = "survival", amount = 1}},
                traitID = "unlucky"
            }
        }
    },
    {
        id = "comingofage",
        title = "Coming of Age",
        prompt = "How did you prove yourself?",
        options = {
            {
                id = "firstblood",
                name = "First Blood",
                description = "Your first real fight wasn't a schoolyard scuffle - it was the first time someone stood over you, waiting to see if you'd actually go through with hurting another person to make it home alive. Whatever happened that day, it changed something in you; you came out the other side stronger, faster, and a lot less afraid of violence than you used to be. You started throwing yourself into physical confrontation more readily after that, learning through bruises and split knuckles rather than any real training. It made you dangerous in a fight, but it came at a cost - you stopped thinking things through as carefully as you used to, especially when your temper got involved.",
                attributes = {{target = "strength", amount = 2}, {target = "speed", amount = 2}},
                skills = {{target = "athletics", amount = 1}},
                traitID = "brawler",
                bonusSkill = {target = "melee", amount = 2}
            },
            {
                id = "thebigscore",
                name = "The Big Score",
                description = "Your first real heist actually worked - against every reasonable expectation, you pulled it off clean. Whatever you took, and whoever you took it from, it proved to you that you had a talent for slipping past locks and lies alike, and you never looked back. You got sharper with your hands and quicker with your tongue, learning that a good story could open just as many doors as a good lockpick. The one thing it cost you was your reputation among people who valued trust - word travels, and yours started to precede you in exactly the wrong way.",
                attributes = {{target = "coordination", amount = 2}, {target = "luck", amount = 1}},
                traitID = "criminal",
                bonusSkill = {target = "deception", amount = 2}
            },
            {
                id = "steadyhands",
                name = "Steady Hands",
                description = "You spent so much of your teenage years patching up everyone around you that you never really got around to working on yourself. Every scrape, every fever, every wound in the settlement seemed to end up in your hands, and you got good - genuinely good - at keeping people alive. It came at the cost of your own conditioning; while you were tending to others, you weren't exactly building yourself up physically, and it shows. Still, the skill you built treating others has more than made up for it, and people trust you with their lives in a way they don't trust most.",
                attributes = {{target = "intelligence", amount = 2}, {target = "charisma", amount = 1}},
                traitID = "frail",
                bonusSkill = {target = "firstaid", amount = 2}
            },
            {
                id = "takingcharge",
                name = "Taking Charge",
                description = "You learned to talk your way to the front of the group - not always because people wanted to follow you, but because you made sure they didn't have much choice. Somewhere along the way you figured out how to read a room, project confidence you didn't always feel, and get people moving in the direction you wanted. It wasn't leadership built on trust so much as leadership built on force of personality, and it worked more often than it probably should have. You came out of it sharper, more perceptive, and a lot more comfortable being the loudest voice in any conversation.",
                attributes = {{target = "charisma", amount = 3}, {target = "awareness", amount = 1}}
            },
            {
                id = "lostandfound",
                name = "Lost and Found",
                description = "You wandered off more times than anyone could count as a teenager, disappearing for hours or days at a stretch and somehow always finding your way back. Every time you got yourself lost, you learned a little more about reading the land, tracking the sun, and trusting your own sense of direction over anyone else's map. It built a sharp awareness of your surroundings that never really faded, along with an odd, persistent streak of luck that always seemed to bring you home in one piece. People stopped worrying when you disappeared - they just figured you'd turn up eventually, and you always did.",
                attributes = {{target = "awareness", amount = 3}, {target = "luck", amount = 1}}
            },
            {
                id = "provingground",
                name = "Proving Ground",
                description = "Every kid in your settlement was sent out alone once they came of age, expected to survive three days in open wasteland with nothing but what they could carry - most made it back rattled but fine, and a few didn't make it back at all. You spent those three days pushing your body harder than you ever had, forcing yourself through exhaustion and thirst rather than turning back and admitting you couldn't hack it. By the time you stumbled back through the gate, something in you had hardened for good, and you'd learned to read danger in the wasteland before it read you. It's the kind of test people either pass or don't, and you walked away from it sure of exactly what you were capable of.",
                attributes = {{target = "strength", amount = 2}, {target = "awareness", amount = 2}}
            },
            {
                id = "standingyourground",
                name = "Standing Your Ground",
                description = "Someone tried to push you around in front of everyone who mattered, and instead of backing down like they expected, you didn't budge an inch. It wasn't about winning a fight - it was about making it clear, once and for all, that you weren't someone people could walk over. Word got around fast, and people started thinking twice before testing you again. You came out of it physically tougher and considerably harder to intimidate, with a reputation you've been happy to lean on ever since.",
                attributes = {{target = "strength", amount = 2}, {target = "charisma", amount = 1}},
                skills = {{target = "hardass", amount = 1}}
            },
            {
                id = "behindthewheel",
                name = "Behind the Wheel",
                description = "You got behind the controls of something you had no business driving, with people's lives on the line and no time to think twice about it. Somehow you got everyone out alive, weaving through wreckage and worse at speeds that still make your stomach drop to think about. It wasn't skill so much as pure necessity the first time, but you chased that feeling afterward until the necessity became genuine talent. These days, handing you the wheel in a bad situation isn't a gamble - it's just the smart move.",
                attributes = {{target = "speed", amount = 2}, {target = "awareness", amount = 1}},
                skills = {{target = "piloting", amount = 2}}
            },
            {
                id = "branded",
                name = "Branded",
                description = "Someone owned you once, and they made sure you'd never forget it - the brand they left on you saw to that. Every time you tried to push back against what was done to you, it was answered with a beating harder than the last, until you stopped pushing back at all. You came out the other side physically hardened by the labor, but the part of you that used to stand up for itself never fully came back online, and you've been looking over your shoulder ever since.",
                attributes = {{target = "strength", amount = 1}},
                traitIDs = {"branded", "paranoid"}
            },
            {
                id = "firstpatrol",
                name = "First Patrol",
                description = "You'd been drilling with the Rangers for what felt like forever when they finally let you come along on an actual patrol instead of another training exercise, and you spent every mile of it terrified you'd freeze up the second something real happened. Something real did happen, eventually, and you didn't freeze - you did exactly what you'd been trained to do, and the Ranger walking point clapped you on the shoulder afterward like you'd actually earned it. It wasn't your star, not even close, but it was the first time anyone treated you like you might actually make it that far. You've been chasing that feeling ever since.",
                attributes = {{target = "awareness", amount = 2}, {target = "coordination", amount = 1}}
            }
        }
    },
    {
        id = "earlytrauma",
        title = "Early Trauma",
        prompt = "What darkened your outlook on the world?",
        options = {
            {
                id = "watchedsomeonedie",
                name = "Watched Someone Die",
                description = "You watched someone close to you die, and there wasn't a single thing you could do to stop it. Whatever happened in that moment burned itself into you, and you've never let your guard down the same way since - you notice everything now, because you remember exactly what it cost you the one time you didn't. It sharpened your mind too, in a colder way; you started thinking through worst-case scenarios before they happened, turning grief into something closer to vigilance. The one thing it seemed to take from you was your sense that things would simply work out - that easy optimism just isn't there anymore.",
                attributes = {{target = "awareness", amount = 2}, {target = "intelligence", amount = 1}},
                traitID = "unlucky",
                bonusSkill = {target = "vigilance", amount = 2}
            },
            {
                id = "betrayal",
                name = "Betrayal",
                description = "Someone trusted you completely, and when the moment came, you sold them out without much hesitation at all. Maybe it was caps, maybe it was your own safety, maybe it was just easier than the alternative - whatever the reason, you did it, and you've made peace with that a lot faster than you probably should have. It taught you exactly how convincing a lie can be when it needs to be, and you've gotten better at telling them since. What it cost you is any real instinct for leading people honestly; you know how to get someone to follow you, but you've lost the knack for making them want to.",
                attributes = {{target = "charisma", amount = 2}, {target = "luck", amount = 1}},
                traitID = "twofaced"
            },
            {
                id = "leftfordead",
                name = "Left for Dead",
                description = "Your own group abandoned you the moment you stopped being useful to them, leaving you to fend for yourself with nothing but whatever you could scrape together. You clawed your way back from that - alone, half-starved, and furious - and it hardened you in a way that never really softened afterward. The experience built raw physical toughness into you, forged out of sheer necessity rather than training. It also taught you a hard lesson about self-reliance out in the wasteland, and you came out the other side knowing how to survive on nothing better than most people ever will.",
                attributes = {{target = "strength", amount = 3}},
                traitID = "slowlearner",
                bonusSkill = {target = "survival", amount = 2}
            },
            {
                id = "savedastranger",
                name = "Saved a Stranger",
                description = "You risked everything to save someone you'd never met before, with no promise of a reward and no guarantee you'd both make it out alive. Somehow, it worked out, and something about that moment stuck with you - a quiet confidence that you're the kind of person who steps up when it counts. People who hear the story tend to warm to you a little faster after that, like the act itself says something true about who you are. It didn't cost you anything you can point to; if anything, it just confirmed the kind of person you already were.",
                attributes = {{target = "charisma", amount = 2}, {target = "awareness", amount = 1}},
                traitID = "charming"
            },
            {
                id = "brokeunderpressure",
                name = "Broke Under Pressure",
                description = "When it mattered most, you froze, and someone else paid the price for your hesitation. You've replayed that moment more times than you'd like to admit, trying to understand why your body simply refused to move when it counted. It made you sharper afterward, more careful, more prone to overthinking every angle before committing to anything, and it left you determined to never be caught flat-footed again. What it cost you was your presence - people can sense that hesitation in you now, and it's made it harder for anyone to look to you when they need someone to take charge.",
                attributes = {{target = "intelligence", amount = 2}, {target = "speed", amount = 1}},
                traitID = "offputting",
                bonusSkill = {target = "leadership", amount = 2}
            },
            {
                id = "chasingthehigh",
                name = "Chasing the High",
                description = "After everything that happened, someone offered you something to take the edge off, and for the first time in longer than you could remember, the edge actually went away. It didn't fix anything, but it made the wasteland bearable in a way sobriety hadn't managed in months, and you kept chasing that feeling long after the original pain should have faded. You got good at functioning around the habit, learning to read a room and steady your hands even when you needed a fix more than you needed anything else. What it cost you is something you'll be paying off for a long time - your body doesn't let you forget what it wants, and it never really stops asking.",
                attributes = {{target = "charisma", amount = 2}, {target = "coordination", amount = 1}},
                traitID = "drugaddict"
            },
            {
                id = "blastsurvivor",
                name = "Blast Survivor",
                description = "An explosion went off close enough to take people you knew and leave you deaf in one ear for a week, and you've never quite stopped flinching at loud, sudden noises since. Rather than let the fear win, you started taking apart old ordnance and studying how the things that almost killed you actually worked, determined to never be caught off guard by one again. It left you constantly scanning for danger in a way that's hard to switch off, and not always easy to be around, but it also made you genuinely dangerous with anything that goes bang. You'd rather understand a threat completely than just be afraid of it.",
                attributes = {{target = "intelligence", amount = 2}, {target = "awareness", amount = 1}},
                traitID = "hypervigilant",
                bonusSkill = {target = "explosives", amount = 2}
            },
            {
                id = "learningtoflatter",
                name = "Learning to Flatter",
                description = "You learned, fast and the hard way, that flattering the person holding power over you could keep you fed, safe, or simply alive when standing up to them would have gotten you hurt. It wasn't dignified, and you knew it even as you did it, smiling and agreeing with things you didn't believe just to keep the peace. The habit stuck long after the danger passed - you're quicker to charm than to think these days, and it shows. People who actually respect you have started to notice the difference.",
                attributes = {{target = "charisma", amount = 1}, {target = "luck", amount = 1}},
                traitID = "smoothbrain"
            },
            {
                id = "freedom",
                name = "Freedom",
                description = "The Desert Rangers found you before your owner ever expected anyone would bother looking. Whatever they were actually out there for, they didn't leave without you - cutting you loose, pressing a pack of basic supplies and a few scraps of gear into your hands, and pointing you toward the nearest settlement instead of just riding on. It wasn't much, barely enough to give you a fighting chance instead of nothing at all, but after everything, it might as well have been everything. You've never forgotten what it felt like walking away under your own power for the first time - uncertain, underequipped, and finally, entirely your own.",
                attributes = {{target = "awareness", amount = 2}, {target = "luck", amount = 1}},
                bonusSkill = {target = "survival", amount = 2},
                traitID = "unbroken",
                items = {} -- TODO: basic supplies and gear from the Rangers
            }
        }
    },
    {
        id = "recentpast",
        title = "Recent Past",
        prompt = "What have you been doing since?",
        options = {
            {
                id = "mercenary",
                name = "Mercenary",
                description = "You spent the last few years taking work wherever caps were offered, no questions asked about who was paying or why. Guns for hire don't get to be picky, and you learned to handle yourself and your weapon well enough to keep getting hired, job after job. The work built you up physically and sharpened your aim considerably, since a merc who can't shoot straight doesn't stay employed for long. It's not glamorous work, and it's left you without much of a permanent home, but it's kept you fed and armed.",
                attributes = {{target = "strength", amount = 2}, {target = "coordination", amount = 1}},
                skills = {{target = "smallarms", amount = 2}},
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "homesteader",
                name = "Homesteader",
                description = "You found a plot of land and a community willing to take you in, and you spent your time helping build something that actually lasted. Fences, crops, trade routes - whatever needed doing, you did it, and you did it well enough that people started trusting you with the harder conversations too, like striking deals with traders passing through. That work built up your ability to read people and negotiate fairly, along with a strange, persistent good fortune that seemed to follow the honest effort you put in. It's given you something most wastelanders don't have: a place that actually feels like home.",
                attributes = {{target = "charisma", amount = 2}, {target = "luck", amount = 2}},
                skills = {{target = "barter", amount = 1}},
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "lonewanderer",
                name = "Lone Wanderer",
                description = "You struck out on your own, learning to survive without leaning on anyone else for anything. Every meal, every safe place to sleep, every threat avoided - all of it came down to your own two hands and your own good sense. That kind of solitary survival sharpened your instincts considerably, teaching you to read danger before it found you and to live off land that would kill someone less careful. It's a lonely way to live, but it's made you sharp in ways that people who've never had to rely purely on themselves usually aren't.",
                attributes = {{target = "awareness", amount = 2}, {target = "luck", amount = 1}},
                skills = {{target = "survival", amount = 2}},
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "apprentice",
                name = "Apprentice",
                description = "You spent years under a craftsman's wing, learning a trade properly before striking out to make your own way. Whatever they were teaching you, you soaked it up eagerly, learning to take apart broken machinery and put it back together better than it started. That kind of hands-on mentorship gave you a real foundation in fixing things that most people only ever learn to break. When you finally left, your mentor sent you off with the tools of the trade - a fitting send-off for the time you put in.",
                attributes = {{target = "intelligence", amount = 1}},
                skills = {{target = "repair", amount = 3}},
                items = {} -- TODO: starting item(s) for this option (e.g. a toolkit)
            },
            {
                id = "raider",
                name = "Raider",
                description = "You ran with a gang for a while, taking what you needed and never looking back at what - or who - you left behind, including whatever life you might have had before it. It built you up physically and taught you to move fast when things went bad, which they often did. Somewhere along the way, someone in the gang introduced you to something that helped take the edge off after a rough job, and you never really managed to shake the habit since. The life toughened you considerably, even if it's left you carrying more baggage than most people your age.",
                attributes = {{target = "strength", amount = 2}, {target = "speed", amount = 2}},
                skills = {{target = "melee", amount = 2}, {target = "sneakyshit", amount = 1}},
                items = {} -- TODO: starting item(s) for this option (e.g. chems)
            },
            {
                id = "smuggler",
                name = "Smuggler",
                description = "You've spent the last stretch moving goods that other people would rather not ask too many questions about, slipping through checkpoints and around patrols with a practiced, easy calm. It's taught you how to keep a straight face under pressure and how to strike a deal fast when a situation calls for it, along with a knack for making yourself scarce the moment things go sideways. The caps have been decent, and the work's kept you sharp in ways a regular job never could have. It's not exactly reputable, but reputable doesn't put food on the table out here.",
                attributes = {{target = "coordination", amount = 1}, {target = "luck", amount = 1}},
                skills = {{target = "sneakyshit", amount = 2}, {target = "barter", amount = 1}},
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "fieldmedic",
                name = "Field Medic",
                description = "You've spent your recent years patching up whoever needed it - caravan guards, settlers, the occasional wounded raider too far gone to be a threat - because someone had to, and you turned out to be good at it. There's never enough supplies and never enough time, so you learned to work fast and calm under pressure most people can't stomach. It's thankless, exhausting work, but it's earned you a reputation as someone worth having around when things go wrong, which out here is worth more than caps.",
                attributes = {{target = "intelligence", amount = 1}, {target = "charisma", amount = 1}},
                skills = {{target = "firstaid", amount = 3}},
                -- shares its name with the trait for a reason: this background is the trained medic,
                -- so it hands over the healing bonus that goes with it
                traitID = "fieldmedic",
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "wastelandguide",
                name = "Wasteland Guide",
                description = "You've made your recent living leading caravans and desperate travelers through territory they had no business crossing alone, reading terrain and trouble well enough to get people through in one piece. Behind the wheel of whatever beat-up vehicle you could keep running, you learned to handle rough ground and rougher company without losing your nerve. It's built up a genuine feel for both the roads and the dangers that wait along them, and clients keep coming back because you've got a track record of getting people where they're going.",
                attributes = {{target = "awareness", amount = 1}, {target = "luck", amount = 1}},
                skills = {{target = "piloting", amount = 1}, {target = "survival", amount = 2}},
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "settlingthescore",
                name = "Settling the Score",
                description = "You were enslaved once, and getting free of it wasn't the end of the story as far as you're concerned. Ever since, you've spent your time hunting down the people responsible, one by one, wherever the trail leads. It's ugly, personal work, and you've never pretended otherwise to yourself or anyone else who's asked. Every one you've caught up with has made you faster, more dangerous, and a little more certain that this is exactly what you're supposed to be doing with the freedom you fought so hard to get back.",
                attributes = {{target = "strength", amount = 1}, {target = "speed", amount = 1}},
                skills = {{target = "melee", amount = 2}, {target = "smallarms", amount = 1}},
                traitID = "onelasttarget",
                items = {} -- TODO: starting item(s) for this option
            },
            {
                id = "earningyourstar",
                name = "Working on Earning Your Star",
                description = "You've spent the time since as a Ranger recruit, doing every unglamorous job nobody else wants in exchange for the chance to actually earn your star someday - running escorts, standing watch, patching up whoever needs it after a bad patrol, and hauling supplies to settlements too far out for anyone else to bother with. Nobody's handed you the badge yet, and you've stopped assuming anybody ever will, but you keep showing up anyway, because the alternative is admitting you don't actually believe in what they're trying to build out here. The senior Rangers say it takes as long as it takes, and that the ones who rush it usually don't make it to wear the star at all. You're trying very hard to be patient about that.",
                attributes = {{target = "charisma", amount = 1}, {target = "awareness", amount = 1}},
                skills = {{target = "smallarms", amount = 1}, {target = "leadership", amount = 1}},
                traitID = "rangertraining",
                items = {} -- TODO: starting item(s) for this option
            }
        }
    },
    {
        id = "preferredweapon",
        title = "What's Your Preferred Weapon?",
        prompt = "How do you fight?",
        options = {
            {
                id = "automaticweapons",
                name = "Automatic Weapons",
                description = "You've always preferred to put more rounds downrange than the other guy, trusting volume of fire over precision. Whatever training or trial-and-error got you here, you've gotten comfortable spraying a target down rather than lining up a careful shot. It's not always the most efficient way to fight, but it's kept you alive more than once, and you've grown attached to the feeling of a weapon that just won't stop firing.",
                skills = {{target = "automaticweapons", amount = 2}},
                items = {} -- TODO: starting weapon + ammo
            },
            {
                id = "bigguns",
                name = "Big Guns",
                description = "Subtlety was never really your style - if a problem needs solving, you'd rather bring something loud enough to solve it all at once. You've spent time learning to handle weapons most people can barely lift, let alone aim, and you've gotten good at making the most of that raw stopping power. It's not a quiet way to fight, but it tends to end arguments fast.",
                skills = {{target = "bigguns", amount = 2}},
                items = {} -- TODO: starting weapon + ammo
            },
            {
                id = "brawling",
                name = "Brawling",
                description = "You've never needed a weapon to handle yourself - your fists have gotten you out of more scrapes than any gun ever could. Somewhere along the way you picked up real technique instead of just throwing wild punches, and it shows in how you carry yourself now. There's something satisfying about settling things up close, on your own terms, with nothing but your hands.",
                skills = {{target = "brawling", amount = 2}},
                items = {} -- TODO: starting item (no ammo needed)
            },
            {
                id = "melee",
                name = "Melee",
                description = "A good blade never runs out of ammo, and that's the philosophy you've built your fighting style around. You've spent real time learning to handle something with an edge, whether that's a knife, a machete, or whatever else you could get sharpened properly. It's an intimate, close-range way to fight, and you've made peace with exactly how close that means getting.",
                skills = {{target = "melee", amount = 2}},
                items = {} -- TODO: starting weapon (no ammo needed)
            },
            {
                id = "smallarms",
                name = "Small Arms",
                description = "A pistol at your hip has gotten you out of more trouble than anything else you own, and you've put in the time to make sure your aim is worth trusting. You favor something light, reliable, and easy to keep close, rather than anything flashy or oversized. It's served you well enough that you've never really felt the need to carry anything bigger.",
                skills = {{target = "smallarms", amount = 2}},
                items = {} -- TODO: starting weapon + ammo
            },
            {
                id = "snipers",
                name = "Snipers",
                description = "You'd rather end a fight before the other person even knows it started, and that means a steady hand, a good scope, and the patience to wait for the right shot. You've spent time learning to read wind, distance, and timing well enough to make a single shot count instead of relying on a dozen wasted ones. It's a quiet, patient way to fight, and it suits you better than getting up close ever could.",
                skills = {{target = "snipers", amount = 2}},
                items = {} -- TODO: starting weapon + ammo
            },
            {
                id = "energyweapons",
                name = "Energy Weapons",
                description = "Pre-war tech doesn't scare you the way it scares most wastelanders - if anything, you've made a point of learning to use it properly. Energy weapons take a different touch than regular guns, and you've put in the time to understand how to keep one running and firing true. It's rarer, stranger technology, and that suits you just fine.",
                skills = {{target = "energyweapons", amount = 2}},
                items = {} -- TODO: starting weapon + energy ammo
            },
            {
                id = "throwing",
                name = "Throwing",
                description = "Why get close or reload at all, when you can just throw the problem away from you entirely? You've gotten genuinely good at putting a grenade, knife, or whatever else you're carrying exactly where it needs to go, at exactly the right moment. It's a different kind of precision than aiming down a sight, and you've made it your own.",
                skills = {{target = "throwing", amount = 2}},
                items = {} -- TODO: starting throwables (act as their own ammo)
            }
        }
    }
}