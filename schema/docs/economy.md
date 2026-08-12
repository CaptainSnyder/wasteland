# Item Economy Reference

Junkify payouts and prices by item category. **Read this before adding new items** — the tiers
differ per category, and it's easy to apply the wrong table.

Original notation from the design doc was `min|max [price]` — e.g. `Common Crafting - 1|5 [5]`
means junkify pays 1-5 and the item costs 5. Ammo is the exception: it's written as
`Small [price] | Carton(x6) [price]`, listing prices for the two pack sizes with no junkify range.

## Which table applies?

| Item kind | Table to use |
|---|---|
| Food & Drinks | Consumable |
| Drugs (alcohol, cigarettes) & Medicine | Medical |
| Crafting materials | Craft |
| Junk with no crafting use | Trash |
| Skill Books | Skill Book |

Note the split: **drugs follow the medical table, not the consumable table**, even though they're
consumed. Food and drink are the only things on the consumable table.

## Consumable (Food & Drinks)

| Tier | Price | Junkify |
|---|---|---|
| Common | 5 | 1-5 |
| Uncommon | 10 | 3-7 |
| Rare | 30 | 4-10 |

## Medical (Medicine & Drugs)

| Tier | Price | Junkify |
|---|---|---|
| Common | 20 | 4-10 |
| Uncommon | 75 | 8-30 |
| Rare | 150 | 15-50 |

Cigarettes are drugs but do **not** use this table — see Cigarettes below.

## Craft (crafting materials)

| Tier | Price | Junkify |
|---|---|---|
| Common | 5 | 1-5 |
| Uncommon | 20 | 4-10 |
| Rare | 50 | 5-20 |

## Trash (`schema/items/junk/`)

Anything that has no crafting use at all.

| Price | Junkify |
|---|---|
| 0 | 1-3 |

## Skill Books

| Type | Price | Junkify |
|---|---|---|
| True Skill Book (single skill) | 1500 | 200-400 |
| Category Skill Book (pick any in category) | 2000 | 200-400 |

## Weapons

Split into Sidearms and Primaries, each with their own tiers. The tier numbers below still stand —
only the weapons that filled them have changed.

**There are currently no weapon items in the schema.** The Fallout Weapons Project set that used to
occupy these tiers was removed when that addon was dropped, so `items/weapons/` no longer exists.
The replacement set lives in `addons/TFA Generic Wasteland` as SWEPs but has not been given schema
items yet. All eight of them are energy weapons firing Energy Charges, and all spawn with an empty
magazine, so a charge has to be found before any of them does anything.

### Sidearms

| Tier | Price | Junkify |
|---|---|---|
| Common | 250 | 25-75 |
| Uncommon | 500 | 50-200 |
| Rare | 1,000 | 100-400 |

### Primaries

| Tier | Price | Junkify |
|---|---|---|
| Common | 400 | 25-100 |
| Uncommon | 850 | 75-300 |
| Rare | 1,500 | 125-500 |

## Cigarettes (own scale)

Cigarettes get a unique scale because the containers nest: a pack holds 20 cigarettes, a carton
holds 8 packs (160 cigarettes). Rather than assigning each tier its own range, everything derives
from the single-cigarette value, so a container is worth exactly what's still inside it.

| Item | Price | Junkify | Max junkify |
|---|---|---|---|
| Cigarette | 5 | 1-3 | 3 |
| Cigarette Pack (20 cigarettes) | 75 | 1-3 per remaining cigarette | 60 |
| Cigarette Carton (8 packs) | 550 | 1-3 per remaining cigarette | 480 |

The per-cigarette value is kept deliberately low since cigarettes are meant to be common. Partially
used containers are handled exactly rather than by percentage — a pack with 7 left rolls 7 times,
no scaling approximation.

Prices sit above each item's **maximum** junkify roll, so selling always beats scrapping even on a
lucky roll. They also bulk-discount downward per cigarette (5 each loose → 3.75 in a pack → 3.44 in
a carton), so buying in bulk stays worthwhile.

## Ammo

Priced by pack size. **Ammo is intentionally not junkifiable** — none of the ammo items define a
`Junkify` function, and new ones shouldn't either.

### Ammo types

`ITEM.ammo` must name a **registered ammo type**, not an entity class. Every caliber here is
registered by the `TFA Generic Roleplay Ammo` addon under a `gr_` prefix — `gr_9mm`, `gr_556`,
`gr_308` and so on — which also provides the matching spawnable pickups.

This distinction bit the schema once already. The items used to point at `tfa_9mm_ammo`,
`tfa_45_ammo`, `item_ammo_357` and similar, which are **entity class names** from the Fallout
Weapons Project, not ammo types. `GiveAmmo` fails silently on an unregistered type — no error, no
ammo — so every ammo item in the schema handed out nothing. If you add a caliber, add its row to
that addon first and use the `gr_` name here.

The x6 carton is priced as "buy 5, get 1 free" rather than a straight 6x multiple (e.g. common
small is 25, so the carton is 125 rather than 150).

| Tier | Small | Carton (x6) | Calibers |
|---|---|---|---|
| Common | 25 | 125 | 9mm, 12g, .38, 5.56, 7.62 |
| Uncommon | 40 | 200 | .357, .308, .44, .45 |
| Rare | 65 | 325 | Energy Charge |

**Every caliber here has a weapon that fires it, with one deliberate exception.** 5mm, 10mm, .50 MG,
12.7mm and Microfusion Cells were removed — they were inherited from the Fallout weapon lineup and
nothing in the current packs chambers them, so they were pure dead loot. `.357` is kept despite
having no weapon yet, on purpose.

**7.62 and .308 are not the same round.** `gr_762` is 7.62x39, the AK cartridge — the AKM, RPK and
SKS. `gr_308` is 7.62x51 NATO, a far heavier round for the battle rifles and bolt guns. They were
briefly folded together, which is why 7.62 appeared to be missing.

**Energy Charge** is the exception to the two-size rule — it exists only at one size (100 charges,
65). It feeds every weapon in the `TFA Generic Wasteland` pack, whose ammo type `wl_energycharge` is
registered by that addon rather than by the schema.

A charge is not a shot. Every one of those weapons holds 100 charges, but draws per shot in
proportion to its wattage — one for the 20 Watt up to four for the 80 Watt — so a single cell buys
anywhere from 100 shots down to 25. Two attachments shift that further: the Recycling Chip halves
the draw for 30% less damage, the Overcharge Chip doubles it for 50% more.

## Charge-based items

Items with a `charges` counter (Cigarette Pack, Cigarette Carton) pay out per unit still inside,
rather than scaling a single roll by a percentage — counting the actual contents is both simpler and
exact:

```lua
local charges = itemTable:GetData("charges", MAX_CHARGES)
local amount = 0

for i = 1, charges do
	amount = amount + math.random(min, max)
end

character:GiveMoney(ix.config.Get("rationTokens", math.max(1, amount)))
```

The Carton multiplies the loop bound by `CIGARETTES_PER_PACK`, since each pack it holds is itself
worth its 20 cigarettes. The `math.max(1, ...)` floor means an empty container still pays at least 1,
never nothing.

`ITEM:OnInstanced()` sets the starting charge count. That hook only fires from `ix.item.Instance`
(true first creation — admin spawn, vendor stock, a carton dispensing a pack), never from
`ix.item.New` when the database restores a partially-used item, so a saved half-empty pack keeps its
real count.

## Conventions

- Every item gets a `Junkify` function, even non-junk items.
- Descriptions are tagged with their tier: `"[COMMON] A loaf of bread..."`.
- Filenames encode the tier: `sh_craft_uncom_leather.lua`, `sh_foods_com_bread.lua`. Helix derives
  an item's uniqueID from the filename (minus the `sh_` prefix and `.lua`), so **renaming a file
  changes its uniqueID** and orphans any copies already saved in player inventories.
- Junkify sound is `physics/metal/metal_box_break1.wav` across the board, regardless of material.
- Currency is Scrap (set in `sh_schema.lua` via `ix.currency.Set`), despite the config key in
  Junkify calls still being named `rationTokens`.
