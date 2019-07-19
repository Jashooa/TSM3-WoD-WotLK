-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_AuctionDB", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table
local private = {region=nil, globalKeyLookup={}}

TSM.MAX_AVG_DAY = 1
local SECONDS_PER_DAY = 60 * 60 * 24

StaticPopupDialogs["TSM_AUCTIONDB_NO_DATA_POPUP"] = {
	text = "|cffff0000WARNING:|r TSM_AuctionDB doesn't currently have any pricing data for your realm. Run a manual scan in-game.",
	button1 = OKAY,
	timeout = 0,
	hideOnEscape = false,
}

local settingsInfo = {
	version = 2,
	realm = {
		lastSaveTime = { type = "number", default = 0, lastModifiedVersion = 1},
		lastCompleteScan = { type = "number", default = 0, lastModifiedVersion = 1},
		lastPartialScan = { type = "number", default = 0, lastModifiedVersion = 1},
		scanData = { type = "string", default = "", lastModifiedVersion = 1},
	},
	global = {
		showAHTab = { type = "boolean", default = true, lastModifiedVersion = 1},
	},
}
local tooltipDefaults = {
	_version = 2,
	minBuyout = true,
	marketValue = true,
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load settings
	TSM.db = TSMAPI.Settings:Init("TradeSkillMaster_AuctionDBDB", settingsInfo)

	-- make easier references to all the modules
	for moduleName, module in pairs(TSM.modules) do
		TSM[moduleName] = module
	end

	-- register this module with TSM
	TSM:RegisterModule()
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.priceSources = {
		{ key = "DBMarket", label = L["AuctionDB - Market Value"], callback = "GetRealmItemData", arg = "marketValue", takeItemString = true },
		{ key = "DBMinBuyout", label = L["AuctionDB - Minimum Buyout"], callback = "GetRealmItemData", arg = "minBuyout", takeItemString = true },
	}
	TSM.moduleOptions = {callback="Config:Load"}
	if TSM.db.global.showAHTab then
		TSM.auctionTab = { callbackShow = "GUI:Show", callbackHide = "GUI:Hide" }
	end
	TSM.moduleAPIs = {
		{ key = "lastCompleteScan", callback = TSM.GetLastCompleteScan },
		{ key = "lastCompleteScanTime", callback = TSM.GetLastCompleteScanTime },
	}
	TSM.tooltip = {callbackLoad="LoadTooltip", callbackOptions="Config:LoadTooltipOptions", defaults=tooltipDefaults}
	TSMAPI:NewModule(TSM)
end

function TSM:OnEnable()
	if TSMAPI.GetRegion then
		private.region = TSMAPI:GetRegion()
	else
		StaticPopupDialogs["TSM_AUCTIONDB_TSM_UPDATE"] = {
			text = "|cffff0000WARNING:|r TradeSkillMaster v3.3.18 or higher is required for TSM_AuctionDB to function properly. Please update your addons.",
			button1 = OKAY,
			timeout = 0,
			hideOnEscape = false,
		}
		TSMAPI.Util:ShowStaticPopupDialog("TSM_AUCTIONDB_TSM_UPDATE")
	end

	TSM.Compress:LoadRealmData()

	for itemString in pairs(TSM.realmData) do
		TSMAPI.Item:QueryInfo(itemString)
	end
	if not next(TSM.realmData) then
		TSMAPI.Util:ShowStaticPopupDialog("TSM_AUCTIONDB_NO_DATA_POPUP")
	end
end

function TSM:OnTSMDBShutdown()
	TSM.Compress:SaveRealmData()
end

local TOOLTIP_STRINGS = {
	minBuyout = {L["Min Buyout:"], L["Min Buyout x%s:"]},
	marketValue = {L["Market Value:"], L["Market Value x%s:"]},
}
local function TooltipMoneyFormat(value, quantity, moneyCoins)
	return TSMAPI:MoneyToString(value*quantity, "|cffffffff", "OPT_PAD", moneyCoins and "OPT_ICON" or nil)
end
local function TooltipX100Format(value)
	return "|cffffffff"..format("%0.2f", value/100).."|r"
end
local function InsertTooltipValueLine(itemString, quantity, key, scope, lines, options, formatter, ...)
	if not options[key] then return end
	local value = nil
	if scope == "global" then
		value = TSM:GetGlobalItemData(itemString, key)
	elseif scope == "region" then
		value = TSM:GetRegionItemData(itemString, key)
	elseif scope == "realm" then
		value = TSM:GetRealmItemData(itemString, key)
	else
		TSMAPI:Assert(false, "Invalid scope: "..tostring(scope))
	end
	if not value then return end
	local strings = TOOLTIP_STRINGS[key]
	TSMAPI:Assert(strings, "Could not find tooltip strings for :"..tostring(key))

	local leftStr = "  "..(quantity > 1 and format(strings[2], quantity) or strings[1])
	local rightStr = formatter(value, quantity, ...)
	tinsert(lines, {left=leftStr, right=rightStr})
end

function TSM:LoadTooltip(itemString, quantity, options, moneyCoins, lines)
	if not itemString then return end
	local numStartingLines = #lines

	-- add min buyout
	InsertTooltipValueLine(itemString, quantity, "minBuyout", "realm", lines, options, TooltipMoneyFormat, moneyCoins)
	-- add market value
	InsertTooltipValueLine(itemString, quantity, "marketValue", "realm", lines, options, TooltipMoneyFormat, moneyCoins)

	-- add the header if we've added at least one line
	if #lines > numStartingLines then
		local lastScan = TSM:GetRealmItemData(itemString, "lastScan")
		local rightStr = "|cffffffff"..L["Not Scanned"].."|r"
		if lastScan then
			local timeColor = (time() - lastScan) > 60*60*3 and "|cffff0000" or "|cff00ff00"
			local timeDiff = SecondsToTime(time() - lastScan)
			local numAuctions = TSM:GetRealmItemData(itemString, "numAuctions") or 0
			rightStr = format("%s (%s)", format("|cffffffff"..L["%d auctions"].."|r", numAuctions), format(timeColor..L["%s ago"].."|r", timeDiff))
		end
		tinsert(lines, numStartingLines+1, {left="|cffffff00TSM AuctionDB:|r", right=rightStr})
	end
end

function TSM:GetLastCompleteScan()
	local lastScan = {}
	for itemString, data in pairs(TSM.realmData) do
		if data.lastScan >= TSM.db.realm.lastCompleteScan and data.minBuyout then
			lastScan[itemString] = {marketValue=data.marketValue, minBuyout=data.minBuyout, numAuctions=data.numAuctions}
		end
	end

	return lastScan
end

function TSM:GetLastCompleteScanTime()
	return TSM.db.realm.lastCompleteScan
end

function private.GetItemDataHelper(tbl, key, itemString)
	if not itemString or not tbl then return end
	local value = nil
	if tbl[itemString] then
		value = tbl[itemString][key]
	else
        local _, _, iRarity = TSMAPI.Item:GetInfo(itemString)
        if iRarity and iRarity >= 3 then
            if strmatch(itemString, "^i:[0-9]+:[0-9%-]+:") then return end
        end
		local baseItemString = TSMAPI.Item:ToBaseItemString(itemString)
		if not baseItemString then return end
		value = tbl[baseItemString] and tbl[baseItemString][key]
	end
	if not value or value <= 0 then return end
	return value
end

function TSM:GetRealmItemData(itemString, key)
	return private.GetItemDataHelper(TSM.realmData, key, itemString)
end

function TSM:GetRegionItemData(itemString, key)
	if private.region == "US" then
		return private.GetItemDataHelper(TSM.regionDataUS, key, itemString)
	elseif private.region == "EU" then
		return private.GetItemDataHelper(TSM.regionDataEU, key, itemString)
	else
		-- unsupported region (or PTR)
		return
	end
end

function TSM:GetGlobalItemData(itemString, key)
	-- translate to region keys
	if not private.globalKeyLookup[key] then
		private.globalKeyLookup[key] = gsub(key, "^global", "region")
	end
	key = private.globalKeyLookup[key]
	local valueUS = private.GetItemDataHelper(TSM.regionDataUS, key, itemString)
	local valueEU = private.GetItemDataHelper(TSM.regionDataEU, key, itemString)
	if valueUS and valueEU then
		-- average the regions to get the global value
		return TSMAPI.Util:Round((valueUS + valueEU) / 2)
	elseif valueUS then
		return valueUS
	elseif valueEU then
		return valueEU
	else
		-- neither region has a valid price
		return
	end
end
