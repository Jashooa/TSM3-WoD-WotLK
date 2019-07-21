-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- general static data tables

local TSM = select(2, ...)
TSM.STATIC_DATA = {}
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster")
local WEAPON, ARMOR = GetAuctionItemClasses()



-- ============================================================================
-- Vendor-Bought Items / Costs
-- ============================================================================

TSM.STATIC_DATA.preloadedVendorCosts = {
    ["i:159"] = 25, -- Refreshing Spring Water
    ["i:1179"] = 125, -- Ice Cold Milk
    ["i:2320"] = 10, -- Coarse Thread
    ["i:2321"] = 100, -- Fine Thread
    ["i:2324"] = 25, -- Bleach
    ["i:2325"] = 1000, -- Black Dye
    ["i:2593"] = 150, -- Flask of Port
    ["i:2594"] = 1500, -- Flagon of Mead
    ["i:2596"] = 120, -- Skin of Dwarven Stout
    ["i:2604"] = 50, -- Red Dye
    ["i:2605"] = 100, -- Green Dye
    ["i:2678"] = 10, -- Mild Spices
    ["i:2880"] = 100, -- Weak Flux
    ["i:2901"] = 81, -- Mining Pick
    ["i:3371"] = 20, -- Empty Vial
    ["i:3372"] = 200, -- Leaded Vial
    ["i:3466"] = 2000, -- Strong Flux
    ["i:3857"] = 500, -- Coal
    ["i:4289"] = 50, -- Salt
    ["i:4291"] = 500, -- Silken Thread
    ["i:4340"] = 350, -- Gray Dye
    ["i:4341"] = 500, -- Yellow Dye
    ["i:4342"] = 2500, -- Purple Dye
    ["i:4399"] = 200, -- Wooden Stock
    ["i:4400"] = 2000, -- Heavy Stock
    ["i:4470"] = 38, -- Simple Wood
    ["i:5956"] = 18, -- Blacksmith Hammer
    ["i:6217"] = 124, -- Copper Rod
    ["i:6260"] = 50, -- Blue Dye
    ["i:6261"] = 1000, -- Orange Dye
    ["i:6530"] = 100, -- Nightcrawlers
    ["i:7005"] = 82, -- Skinning Knife
    ["i:8343"] = 2000, -- Heavy Silken Thread
    ["i:8925"] = 2500, -- Crystal Vial
    ["i:10290"] = 2500, -- Pink Dye
    ["i:10647"] = 2000, -- Engineer's Ink
    ["i:10648"] = 125, -- Common Parchment
    ["i:11291"] = 4500, -- Star Wood
    ["i:12037"] = 350, -- Mystery Meat
    ["i:14341"] = 5000, -- Rune Thread
    ["i:17020"] = 1000, -- Arcane Powder
    ["i:17034"] = 200, -- Maple Seed
    ["i:17035"] = 400, -- Stranglethorn Seed
    ["i:17194"] = 10, -- Holiday Spices
    ["i:17196"] = 50, -- Holiday Spirits
    ["i:17202"] = 10, -- Snowball
    ["i:18256"] = 20000, -- Imbued Vial
    ["i:18567"] = 150000, -- Elemental Flux
    ["i:27860"] = 6400, -- Purified Draenic Water
    ["i:30817"] = 25, -- Simple Flour
    ["i:34249"] = 1000000, -- Hula Girl Doll
    ["i:34412"] = 1000, -- Sparkling Apple Cider
    ["i:35948"] = 16000, -- Savory Snowplum
    ["i:35949"] = 8500, -- Tundra Berries
    ["i:38426"] = 30000, -- Eternium Thread
    ["i:39354"] = 15, -- Light Parchment
    ["i:39501"] = 1250, -- Heavy Parchment
    ["i:39502"] = 5000, -- Resilient Parchment
    ["i:39684"] = 9000, -- Hair Trigger
    ["i:40411"] = 50000, -- Enchanted Vial
    ["i:40533"] = 50000, -- Walnut Stock
    ["i:44499"] = 30000, -- Salvaged Iron Golem Parts
    ["i:44501"] = 10000, -- Goblin-machined Piston
    ["i:44835"] = 10, -- Autumnal Herbs
    ["i:44853"] = 25, -- Honey
    ["i:44854"] = 25, -- Tangy Wetland Cranberries
    ["i:44855"] = 25, -- Teldrassil Sweet Potato
    ["i:46784"] = 25, -- Ripe Elwynn Pumpkin
    ["i:46793"] = 25, -- Tangy Southfury Cranberries
    ["i:46796"] = 25, -- Ripe Tirisfal Pumpkin
    ["i:46797"] = 25, -- Mulgore Sweet Potato
}



-- ============================================================================
-- Non-Disenchantable Items
-- ============================================================================

TSM.STATIC_DATA.notDisenchantable = {
    ["i:11287"] = true, -- Lesser Magic Wand
    ["i:11288"] = true, -- Greater Magic Wand
    ["i:11289"] = true, -- Lesser Mystic Wand
    ["i:11290"] = true, -- Greater Mystic Wand
	["i:20406"] = true, -- Twilight Cultist Mantle
	["i:20407"] = true, -- Twilight Cultist Robe
	["i:20408"] = true, -- Twilight Cultist Cowl
    ["i:21766"] = true, -- Opal Necklace of Impact
	["i:52252"] = true, -- Tabard of the Lightbringer
}



-- ============================================================================
-- Disenchanting Ratios
-- ============================================================================

TSM.STATIC_DATA.disenchantInfo = {
	{
		desc = L["Dust"],
		["i:10940"] = { -- Strange Dust
			minLevel = 0,
			maxLevel = 24,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 5, maxItemLevel = 15, amountOfMats = 1.2},
				{itemType = ARMOR, rarity = 2, minItemLevel = 16, maxItemLevel = 20, amountOfMats = 1.875},
				{itemType = ARMOR, rarity = 2, minItemLevel = 21, maxItemLevel = 25, amountOfMats = 3.75},
				{itemType = WEAPON, rarity = 2, minItemLevel = 5, maxItemLevel = 15, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 16, maxItemLevel = 20, amountOfMats = 0.5},
				{itemType = WEAPON, rarity = 2, minItemLevel = 21, maxItemLevel = 25, amountOfMats = 0.75},
			},
		},
		["i:11083"] = { -- Soul Dust
			minLevel = 20,
			maxLevel = 30,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 1.125},
				{itemType = ARMOR, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 2.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 0.7},
			},
		},
		["i:11137"] = { -- Vision Dust
			minLevel = 30,
			maxLevel = 40,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 1.125},
				{itemType = ARMOR, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 2.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 0.7},
			},
		},
		["i:11176"] = { -- Dream Dust
			minLevel = 41,
			maxLevel = 50,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 1.125},
				{itemType = ARMOR, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 2.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 0.77},
			},
		},
		["i:16204"] = { -- Illusion Dust
			minLevel = 51,
			maxLevel = 60,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 1.125},
				{itemType = ARMOR, rarity = 2, minItemLevel = 61, maxItemLevel = 65, amountOfMats = 2.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 0.33},
				{itemType = WEAPON, rarity = 2, minItemLevel = 61, maxItemLevel = 65, amountOfMats = 0.77},
			},
		},
		["i:22445"] = { -- Arcane Dust
			minLevel = 57,
			maxLevel = 70,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 79, maxItemLevel = 79, amountOfMats = 1.5},
				{itemType = ARMOR, rarity = 2, minItemLevel = 80, maxItemLevel = 99, amountOfMats = 1.875},
				{itemType = ARMOR, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 2.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 80, maxItemLevel = 99, amountOfMats = 0.55},
				{itemType = WEAPON, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 0.77},
			},
		},
		["i:34054"] = { -- Infinite Dust
			minLevel = 67,
			maxLevel = 80,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 130, maxItemLevel = 151, amountOfMats = 1.5},
				{itemType = ARMOR, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 3.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 130, maxItemLevel = 151, amountOfMats = 0.55},
				{itemType = WEAPON, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 1.1},
			},
		},
	},
	{
		desc = L["Essences"],
		["i:10939"] = { -- Greater Magic Essence
			minLevel = 1,
			maxLevel = 15,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 5, maxItemLevel = 15, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 2, minItemLevel = 16, maxItemLevel = 20, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 5, maxItemLevel = 15, amountOfMats = 0.4},
				{itemType = WEAPON, rarity = 2, minItemLevel = 16, maxItemLevel = 20, amountOfMats = 1.125},
			},
		},
		["i:11082"] = { -- Greater Astral Essence
			minLevel = 16,
			maxLevel = 25,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 21, maxItemLevel = 25, amountOfMats = .075},
				{itemType = ARMOR, rarity = 2, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 21, maxItemLevel = 25, amountOfMats = 0.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 1.125},
			},
		},
		["i:11135"] = { -- Greater Mystic Essence
			minLevel = 26,
			maxLevel = 35,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 0.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 1.125},
			},
		},
		["i:11175"] = { -- Greater Nether Essence
			minLevel = 36,
			maxLevel = 45,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 0.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 1.125},
			},
		},
		["i:16203"] = { -- Greater Eternal Essence
			minLevel = 46,
			maxLevel = 60,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 2, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 0.3},
				{itemType = ARMOR, rarity = 2, minItemLevel = 61, maxItemLevel = 65, amountOfMats = 0.5},
				{itemType = WEAPON, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 0.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 0.125},
				{itemType = WEAPON, rarity = 2, minItemLevel = 61, maxItemLevel = 65, amountOfMats = 1.875},
			},
		},
		["i:22446"] = { -- Greater Planar Essence
			minLevel = 58,
			maxLevel = 70,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 66, maxItemLevel = 99, amountOfMats = 0.167},
				{itemType = ARMOR, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 79, maxItemLevel = 79, amountOfMats = 0.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 80, maxItemLevel = 99, amountOfMats = 0.625},
				{itemType = WEAPON, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 1.125},
			},
		},
		["i:34055"] = { -- Greater Cosmic Essence
			minLevel = 67,
			maxLevel = 80,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 130, maxItemLevel = 151, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 0.3},
				{itemType = WEAPON, rarity = 2, minItemLevel = 130, maxItemLevel = 151, amountOfMats = 0.375},
				{itemType = WEAPON, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 1.125},
			},
		},
	},
	{
		desc = L["Shards"],
		["i:10978"] = { -- Small Glimmering Shard
			minLevel = 1,
			maxLevel = 20,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 1, maxItemLevel = 20, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 2, minItemLevel = 21, maxItemLevel = 25, amountOfMats = 0.1},
				{itemType = ARMOR, rarity = 3, minItemLevel = 1, maxItemLevel = 25, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 3, minItemLevel = 1, maxItemLevel = 25, amountOfMats = 1.000},
			},
		},
		["i:11084"] = { -- Large Glimmering Shard
			minLevel = 16,
			maxLevel = 25,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 3, minItemLevel = 26, maxItemLevel = 30, amountOfMats = 1.000},
			},
		},
		["i:11138"] = { -- Small Glowing Shard
			minLevel = 26,
			maxLevel = 30,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 2, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 31, maxItemLevel = 35, amountOfMats = 1.000},
			},
		},
		["i:11139"] = { -- Large Glowing Shard
			minLevel = 31,
			maxLevel = 35,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 2, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 1.000},
			},
		},
		["i:11177"] = { -- Small Radiant Shard
			minLevel = 36,
			maxLevel = 40,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 1.000},
				{itemType = ARMOR, rarity = 4, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 3},
				{itemType = ARMOR, rarity = 4, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 3.5},
				{itemType = WEAPON, rarity = 2, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 4, minItemLevel = 36, maxItemLevel = 40, amountOfMats = 3},
				{itemType = WEAPON, rarity = 4, minItemLevel = 41, maxItemLevel = 45, amountOfMats = 3.5},
			},
		},
		["i:11178"] = { -- Large Radiant Shard
			minLevel = 41,
			maxLevel = 45,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 1.000},
				{itemType = ARMOR, rarity = 4, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 3.5},
				{itemType = WEAPON, rarity = 2, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 4, minItemLevel = 46, maxItemLevel = 50, amountOfMats = 3.5},
			},
		},
		["i:14343"] = { -- Small Brilliant Shard
			minLevel = 46,
			maxLevel = 50,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 1.000},
				{itemType = ARMOR, rarity = 4, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 3.5},
				{itemType = WEAPON, rarity = 2, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 4, minItemLevel = 51, maxItemLevel = 55, amountOfMats = 3.5},
			},
		},
		["i:14344"] = { -- Large Brilliant Shard
			minLevel = 56,
			maxLevel = 75,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 56, maxItemLevel = 65, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 56, maxItemLevel = 65, amountOfMats = 0.995},
				{itemType = WEAPON, rarity = 2, minItemLevel = 56, maxItemLevel = 65, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 56, maxItemLevel = 65, amountOfMats = 0.995},
			},
		},
		["i:22449"] = { -- Large Prismatic Shard
			minLevel = 56,
			maxLevel = 70,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 66, maxItemLevel = 99, amountOfMats = 0.0167},
				{itemType = ARMOR, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 66, maxItemLevel = 99, amountOfMats = 0.33},
				{itemType = ARMOR, rarity = 3, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 1},
				{itemType = WEAPON, rarity = 2, minItemLevel = 66, maxItemLevel = 99, amountOfMats = 0.0167},
				{itemType = WEAPON, rarity = 2, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 66, maxItemLevel = 99, amountOfMats = 0.33},
				{itemType = WEAPON, rarity = 3, minItemLevel = 100, maxItemLevel = 120, amountOfMats = 1},
			},
		},
		["i:34052"] = { -- Dream Shard
			minLevel = 68,
			maxLevel = 80,
			sourceInfo = {
				{itemType = ARMOR, rarity = 2, minItemLevel = 121, maxItemLevel = 151, amountOfMats = 0.0167},
				{itemType = ARMOR, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 0.05},
				{itemType = ARMOR, rarity = 3, minItemLevel = 121, maxItemLevel = 164, amountOfMats = 0.33},
				{itemType = ARMOR, rarity = 3, minItemLevel = 165, maxItemLevel = 200, amountOfMats = 1},
				{itemType = WEAPON, rarity = 2, minItemLevel = 121, maxItemLevel = 151, amountOfMats = 0.0167},
				{itemType = WEAPON, rarity = 2, minItemLevel = 152, maxItemLevel = 200, amountOfMats = 0.05},
				{itemType = WEAPON, rarity = 3, minItemLevel = 121, maxItemLevel = 164, amountOfMats = 0.33},
				{itemType = WEAPON, rarity = 3, minItemLevel = 165, maxItemLevel = 200, amountOfMats = 1},
			},
		},
	},
	{
		desc = L["Crystals"],
		["i:20725"] = { -- Nexus Crystal
			minLevel = 56,
			maxLevel = 60,
			sourceInfo = {
				{itemType = ARMOR, rarity = 4, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 1.000},
				{itemType = ARMOR, rarity = 4, minItemLevel = 61, maxItemLevel = 94, amountOfMats = 1.5},
				{itemType = WEAPON, rarity = 4, minItemLevel = 56, maxItemLevel = 60, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 4, minItemLevel = 61, maxItemLevel = 94, amountOfMats = 1.5},
			},
		},
		["i:22450"] = { -- Void Crystal
			minLevel = 70,
			maxLevel = 70,
			sourceInfo = {
				{itemType = ARMOR, rarity = 4, minItemLevel = 95, maxItemLevel = 99, amountOfMats = 1},
				{itemType = ARMOR, rarity = 4, minItemLevel = 100, maxItemLevel = 164, amountOfMats = 1.5},
				{itemType = WEAPON, rarity = 4, minItemLevel = 95, maxItemLevel = 99, amountOfMats = 1},
				{itemType = WEAPON, rarity = 4, minItemLevel = 100, maxItemLevel = 164, amountOfMats = 1.5},
			},
		},
		["i:34057"] = { -- Abyss Crystal
			minLevel = 80,
			maxLevel = 80,
			sourceInfo = {
				{itemType = ARMOR, rarity = 4, minItemLevel = 165, maxItemLevel = 299, amountOfMats = 1.000},
				{itemType = WEAPON, rarity = 4, minItemLevel = 165, maxItemLevel = 299, amountOfMats = 1.000},
			},
		},
	},
}



-- ============================================================================
-- Static Pre-Defined Conversions
-- ============================================================================

TSM.STATIC_DATA.predefinedConversions = {
	-- ======================================= Common Pigments =======================================
	["i:39151"] = { -- Alabaster Pigment (Ivory / Moonglow Ink)
		{"i:765", 0.5, "mill"},
		{"i:2447", 0.5, "mill"},
		{"i:2449", 0.6, "mill"},
    },
	["i:39334"] = { -- Dusky Pigment (Midnight Ink)
		{"i:785", 0.5, "mill"},
		{"i:2450", 0.5, "mill"},
		{"i:2452", 0.5, "mill"},
		{"i:2453", 0.6, "mill"},
		{"i:3820", 0.6, "mill"},
    },
	["i:39338"] = { -- Golden Pigment (Lion's Ink)
		{"i:3355", 0.5, "mill"},
		{"i:3369", 0.5, "mill"},
		{"i:3356", 0.6, "mill"},
		{"i:3357", 0.6, "mill"},
	},
    ["i:39339"] = { -- Emerald Pigment (Jadefire Ink)
        {"i:3818", 0.5, "mill"},
        {"i:3821", 0.5, "mill"},
        {"i:3358", 0.6, "mill"},
        {"i:3819", 0.6, "mill"},
    },
    ["i:39340"] = { -- Violet Pigment (Celestial Ink)
        {"i:4625", 0.5, "mill"},
        {"i:8831", 0.5, "mill"},
        {"i:8838", 0.5, "mill"},
        {"i:8839", 0.6, "mill"},
        {"i:8845", 0.6, "mill"},
        {"i:8846", 0.6, "mill"},
    },
	["i:39341"] = { -- Silvery Pigment (Shimmering Ink)
		{"i:13463", 0.5, "mill"},
		{"i:13464", 0.5, "mill"},
		{"i:13465", 0.6, "mill"},
		{"i:13466", 0.6, "mill"},
		{"i:13467", 0.6, "mill"},
	},
    ["i:39342"] = { -- Nether Pigment (Ethereal Ink)
        {"i:22785", 0.5, "mill"},
        {"i:22786", 0.5, "mill"},
        {"i:22787", 0.5, "mill"},
        {"i:22789", 0.5, "mill"},
        {"i:22790", 0.6, "mill"},
        {"i:22791", 0.6, "mill"},
        {"i:22792", 0.6, "mill"},
        {"i:22793", 0.6, "mill"},
    },
	["i:39343"] = { -- Azure Pigment (Ink of the Sea)
		{"i:39969", 0.5, "mill"},
		{"i:36904", 0.5, "mill"},
		{"i:36907", 0.5, "mill"},
		{"i:36901", 0.5, "mill"},
		{"i:39970", 0.5, "mill"},
		{"i:37921", 0.5, "mill"},
		{"i:36905", 0.6, "mill"},
		{"i:36906", 0.6, "mill"},
		{"i:36903", 0.6, "mill"},
    },
	-- ======================================= Rare Pigments =======================================
	["i:43103"] = { -- Verdant Pigment (Hunter's Ink)
		{"i:2453", 0.1, "mill"},
		{"i:3820", 0.1, "mill"},
		{"i:2450", 0.05, "mill"},
		{"i:785", 0.05, "mill"},
		{"i:2452", 0.05, "mill"},
	},
	["i:43104"] = { -- Burnt Pigment (Dawnstar Ink)
		{"i:3356", 0.1, "mill"},
		{"i:3357", 0.1, "mill"},
		{"i:3369", 0.05, "mill"},
		{"i:3355", 0.05, "mill"},
    },
	["i:43105"] = { -- Indigo Pigment (Royal Ink)
		{"i:3358", 0.1, "mill"},
		{"i:3819", 0.1, "mill"},
		{"i:3821", 0.05, "mill"},
		{"i:3818", 0.05, "mill"},
    },
	["i:43106"] = { -- Ruby Pigment (Fiery Ink)
		{"i:4625", 0.05, "mill"},
		{"i:8838", 0.05, "mill"},
		{"i:8831", 0.05, "mill"},
		{"i:8845", 0.1, "mill"},
		{"i:8846", 0.1, "mill"},
		{"i:8839", 0.1, "mill"},
	},
	["i:43107"] = { -- Sapphire Pigment (Ink of the Sky)
		{"i:13463", 0.05, "mill"},
		{"i:13464", 0.05, "mill"},
		{"i:13465", 0.1, "mill"},
		{"i:13466", 0.1, "mill"},
		{"i:13467", 0.1, "mill"},
	},
	["i:43108"] = { -- Ebon Pigment (Darkflame Ink)
		{"i:22792", 0.1, "mill"},
		{"i:22790", 0.1, "mill"},
		{"i:22791", 0.1, "mill"},
		{"i:22793", 0.1, "mill"},
		{"i:22786", 0.05, "mill"},
		{"i:22785", 0.05, "mill"},
		{"i:22787", 0.05, "mill"},
		{"i:22789", 0.05, "mill"},
    },
	["i:43109"] = { -- Icy Pigment (Snowfall Ink)
		{"i:39969", 0.05, "mill"},
		{"i:36904", 0.05, "mill"},
		{"i:36907", 0.05, "mill"},
		{"i:36901", 0.05, "mill"},
		{"i:39970", 0.05, "mill"},
		{"i:37921", 0.05, "mill"},
		{"i:36905", 0.1, "mill"},
		{"i:36906", 0.1, "mill"},
		{"i:36903", 0.1, "mill"},
	},
	-- ======================================== Vanilla Gems =======================================
	["i:774"] = { -- Malachite
		{"i:2770", 0.1, "prospect"},
	},
	["i:818"] = { -- Tigerseye
		{"i:2770", 0.1, "prospect"},
    },
	["i:1206"] = { -- Moss Agate
		{"i:2771", 0.06, "prospect"},
	},
	["i:1210"] = {  -- Shadowgem
		{"i:2771", 0.08, "prospect"},
		{"i:2770", 0.02, "prospect"},
    },
	["i:1529"] = { -- Jade
		{"i:2772", 0.08, "prospect"},
		{"i:2771", 0.006, "prospect"},
	},
	["i:1705"] = { -- Lesser Moonstone
		{"i:2771", 0.08, "prospect"},
		{"i:2772", 0.06, "prospect"},
	},
	["i:3864"] = { -- Citrine
		{"i:2772", 0.08, "prospect"},
		{"i:3858", 0.06, "prospect"},
		{"i:2771", 0.006, "prospect"},
	},
	["i:7909"] = { -- Aquamarine
		{"i:3858", 0.06, "prospect"},
		{"i:2772", 0.01, "prospect"},
		{"i:2771", 0.006, "prospect"},
	},
	["i:7910"] = { -- Star Ruby
		{"i:3858", 0.08, "prospect"},
		{"i:10620", 0.02, "prospect"},
		{"i:2772", 0.01, "prospect"},
	},
	["i:12361"] = { -- Blue Sapphire
		{"i:10620", 0.06, "prospect"},
		{"i:3858", 0.006, "prospect"},
    },
	["i:12364"] = { -- Huge Emerald
		{"i:10620", 0.06, "prospect"},
		{"i:3858", 0.004, "prospect"},
	},
	["i:12799"] = { -- Large Opal
		{"i:10620", 0.06, "prospect"},
		{"i:3858", 0.006, "prospect"},
	},
	["i:12800"] = { -- Azerothian Diamond
		{"i:10620", 0.06, "prospect"},
		{"i:3858", 0.004, "prospect"},
	},
    -- ======================================== Uncommon Gems ======================================
	["i:21929"] = { -- Flame Spessarite
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
    },
	["i:23077"] = { -- Blood Garnet
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
	},
	["i:23079"] = { -- Deep Peridot
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
	},
	["i:23107"] = { -- Shadow Draenite
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
	},
	["i:23112"] = { -- Golden Draenite
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
    },
	["i:23117"] = { -- Azure Moonstone
		{"i:23424", 0.04, "prospect"},
		{"i:23425", 0.04, "prospect"},
	},
	["i:36917"] = { -- Bloodstone
		{"i:36909", 0.05, "prospect"},
		{"i:36912", 0.04, "prospect"},
		{"i:36910", 0.05, "prospect"},
    },
    ["i:36920"] = { -- Sun Crystal
        {"i:36909", 0.05, "prospect"},
        {"i:36912", 0.04, "prospect"},
        {"i:36910", 0.04, "prospect"},
    },
	["i:36923"] = { -- Chalcedony
		{"i:36909", 0.05, "prospect"},
		{"i:36912", 0.04, "prospect"},
		{"i:36910", 0.05, "prospect"},
    },
	["i:36926"] = { -- Shadow Crystal
		{"i:36909", 0.05, "prospect"},
		{"i:36912", 0.04, "prospect"},
		{"i:36910", 0.05, "prospect"},
    },
	["i:36929"] = { -- Huge Citrine
		{"i:36909", 0.05, "prospect"},
		{"i:36912", 0.04, "prospect"},
		{"i:36910", 0.05, "prospect"},
	},
	["i:36932"] = { -- Dark Jade
		{"i:36909", 0.05, "prospect"},
		{"i:36912", 0.04, "prospect"},
		{"i:36910", 0.05, "prospect"},
	},
	-- ========================================== Rare Gems ========================================
	["i:23440"] = { -- Dawnstone
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:23436"] = { -- Living Ruby
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:23441"] = { -- Nightseye
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:23439"] = { -- Noble Topaz
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:23438"] = { -- Star of Elune
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:23437"] = { -- Talasite
		{"i:23424", 0.002, "prospect"},
		{"i:23425", 0.008, "prospect"},
	},
	["i:36921"] = { -- Autumn's Glow
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},
	["i:36933"] = { -- Forest Emerald
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},
	["i:36930"] = { -- Monarch Topaz
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},
	["i:36918"] = { -- Scarlet Ruby
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},
	["i:36924"] = { -- Sky Sapphire
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},
	["i:36927"] = { -- Twilight Opal
		{"i:36909", 0.002, "prospect"},
		{"i:36912", 0.008, "prospect"},
		{"i:36910", 0.008, "prospect"},
	},

	-- =========================================== Essences ========================================
	["i:34055"] = {{"i:34056", 1/3, "transform"}}, -- Cosmic Essence
	["i:34056"] = {{"i:34055", 3, "transform"}}, -- Cosmic Essence
	["i:22446"] = {{"i:22447", 1/3, "transform"}}, -- Planar Essence
	["i:22447"] = {{"i:22446", 3, "transform"}}, -- Planar Essence
	["i:16203"] = {{"i:16202", 1/3, "transform"}}, -- Eternal Essence
	["i:16202"] = {{"i:16203", 3, "transform"}}, -- Eternal Essence
	["i:11175"] = {{"i:11174", 1/3, "transform"}}, -- Nether Essence
	["i:11174"] = {{"i:11175", 3, "transform"}}, -- Nether Essence
	["i:11135"] = {{"i:11134", 1/3, "transform"}}, -- Mystic Essence
	["i:11134"] = {{"i:11135", 3, "transform"}}, -- Mystic Essence
	["i:11082"] = {{"i:10998", 1/3, "transform"}}, -- Astral Essence
	["i:10998"] = {{"i:11082", 3, "transform"}}, -- Astral Essence
	["i:10939"] = {{"i:10938", 1/3, "transform"}}, -- Magic Essence
	["i:10938"] = {{"i:10939", 3, "transform"}}, -- Magic Essence
	-- ============================================ Shards =========================================
	["i:34052"] = {{"i:34053", 1/3, "transform"}}, -- Dream Shard
	-- ======================================== Primals / Motes ====================================
	["i:21885"] = {{"i:22578", 0.1, "transform"}}, -- Water
	["i:22456"] = {{"i:22577", 0.1, "transform"}}, -- Shadow
	["i:22457"] = {{"i:22576", 0.1, "transform"}}, -- Mana
	["i:21886"] = {{"i:22575", 0.1, "transform"}}, -- Life
	["i:21884"] = {{"i:22574", 0.1, "transform"}}, -- Fire
	["i:22452"] = {{"i:22573", 0.1, "transform"}}, -- Earth
	["i:22451"] = {{"i:22572", 0.1, "transform"}}, -- Air
	-- ===================================== Crystalized / Eternal =================================
	["i:37700"] = {{"i:35623", 10, "transform"}}, -- Air
	["i:35623"] = {{"i:37700", 0.1, "transform"}}, -- Air
	["i:37701"] = {{"i:35624", 10, "transform"}}, -- Earth
	["i:35624"] = {{"i:37701", 0.1, "transform"}}, -- Earth
	["i:37702"] = {{"i:36860", 10, "transform"}}, -- Fire
	["i:36860"] = {{"i:37702", 0.1, "transform"}}, -- Fire
	["i:37703"] = {{"i:35627", 10, "transform"}}, -- Shadow
	["i:35627"] = {{"i:37703", 0.1, "transform"}}, -- Shadow
	["i:37704"] = {{"i:35625", 10, "transform"}}, -- Life
	["i:35625"] = {{"i:37704", 0.1, "transform"}}, -- Life
	["i:37705"] = {{"i:35622", 10, "transform"}}, -- Water
	["i:35622"] = {{"i:37705", 0.1, "transform"}}, -- Water
	-- ========================================= Vendor Trades =====================================
	["i:37101"] = {{"i:43126", 1, "vendortrade"}},   -- Ivory Ink
	["i:39469"] = {{"i:43126", 1, "vendortrade"}},   -- Moonglow Ink
	["i:39774"] = {{"i:43126", 1, "vendortrade"}},   -- Midnight Ink
	["i:43116"] = {{"i:43126", 1, "vendortrade"}},   -- Lion's Ink
	["i:43118"] = {{"i:43126", 1, "vendortrade"}},   -- Jadefire Ink
	["i:43120"] = {{"i:43126", 1, "vendortrade"}},   -- Celestial Ink
	["i:43122"] = {{"i:43126", 1, "vendortrade"}},   -- Shimmering Ink
	["i:43124"] = {{"i:43126", 1, "vendortrade"}},   -- Ethereal Ink
	["i:43127"] = {{"i:43126", 0.1, "vendortrade"}}, -- Snowfall Ink
}
