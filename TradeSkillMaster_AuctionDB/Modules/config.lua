-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Config = TSM:NewModule("Config")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table



-- ============================================================================
-- Module Options
-- ============================================================================

function Config:Load(container)
	local lastScanInfo
	if TSM.db.realm.lastCompleteScan > 0 then
		lastScanInfo = format(L["Last updated from in-game scan %s ago."], SecondsToTime(time() - TSM.db.realm.lastCompleteScan))
	else
		lastScanInfo = L["No scans found."]
	end
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					title = L["Last Update Time"],
					layout = "Flow",
					children = {
						{
							type = "Label",
							text = lastScanInfo,
							relativeWidth = 1,
						},
					},
				},
				{
					type = "InlineGroup",
					title = L["General Options"],
					layout = "Flow",
					children = {
						{
							type = "CheckBox",
							label = L["Show AuctionDB AH Tab (Requires Reload)"],
							settingInfo = { TSM.db.global, "showAHTab" },
							relativeWidth = 0.5,
							tooltip = L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."],
						},
					},
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end



-- ============================================================================
-- Tooltip Options
-- ============================================================================

function Config:LoadTooltipOptions(container, options)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Display min buyout in tooltip."],
					settingInfo = { options, "minBuyout" },
					relativeWidth = 1,
					tooltip = L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."],
				},
				{
					type = "CheckBox",
					label = L["Display market value in tooltip."],
					settingInfo = { options, "marketValue" },
					relativeWidth = 1,
					tooltip = L["If checked, the market value of the item will be displayed"],
				},
			},
		},
	}

	TSMAPI.GUI:BuildOptions(container, page)
end