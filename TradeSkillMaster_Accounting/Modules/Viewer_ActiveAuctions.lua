-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local ActiveAuctions = TSM.modules.Viewer:NewModule("ActiveAuctions")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table
local private = {filters={}}
local SECONDS_PER_DAY = 24 * 60 * 60



-- ============================================================================
-- ScrollingTable Columns
-- ============================================================================

local ITEM_AUCTION_ST_COLS = {
	{name=L["Item Name"], width=0.3, headAlign="LEFT"},
    {name=L["Player"], width=0.15, headAlign="LEFT"},
    {name="Bid", width=0.1, headAlign="LEFT"},
    {name="Buyout", width=0.1, headAlign="LEFT"},
	{name=L["Stack"], width=0.05, headAlign="LEFT"},
    {name=L["Aucs"], width=0.05, headAlign="LEFT"},
    {name="Duration", width=0.1, headAlign="LEFT"},
	{name=L["Time"], width=0.15, headAlign="LEFT"},
	defaultSort = -8,
}



-- ============================================================================
-- Module Functions
-- ============================================================================

function ActiveAuctions:Draw(container)
	--[[local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Expired"], value = 1 }, { text = L["Cancelled"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		TSM.Viewer:HideScrollingTables()
		if value == 1 then
			TSM.Viewer:GetItemFiltersInfo(self, "expired", {}, private.GetAuctionSTData, ITEM_AUCTION_ST_COLS, 7, value)
		elseif value == 2 then
			TSM.Viewer:GetItemFiltersInfo(self, "auctions", {}, private.GetCancelSTData, ITEM_AUCTION_ST_COLS, 7, value)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.ViewerUtil:PopulateDataCaches()
    tabGroup:SelectTab(1)]]--
    TSM.Viewer:GetItemFiltersInfo(container, "auctions", {}, private.GetAuctionSTData, ITEM_AUCTION_ST_COLS, 7, value)
end



-- ============================================================================
-- Helper Functions
-- ============================================================================

function private.GetAuctionSTData(filters)
	local stData = {}
    if #TSM.auctions > 0 then
        for _, record in ipairs(TSM.auctions) do
            if not TSM.ViewerUtil:IsItemFiltered(record.itemString, filters) and TSM.ViewerUtil:IsRecordFiltered(record, filters) then
                local name = select(2, TSMAPI.Item:GetInfo(record.itemString)) or record.itemString
                local row = {
                    cols = {
                        {
                            value = name,
                            sortArg = name or record.itemString,
                        },
                        {
                            value = record.player,
                            sortArg = record.player,
                        },
                        {
                            value = TSMAPI:MoneyToString(record.bid),
                            sortArg = record.bid,
                        },
                        {
                            value = TSMAPI:MoneyToString(record.buyout),
                            sortArg = record.buyout,
                        },
                        {
                            value = record.stackSize,
                            sortArg = record.stackSize,
                        },
                        {
                            value = record.numStacks,
                            sortArg = record.numStacks,
                        },
                        {
                            value = record.duration,
                            sortArg = record.duration,
                        },
                        {
                            value = TSM.ViewerUtil:GetFormattedTime(record.time),
                            sortArg = record.time,
                        },
                    },
                    itemString = record.itemString
                }
                tinsert(stData, row)
            end
        end
    end
	return stData
end