-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing") -- loads the localization table
local BankUI = TSM:NewModule("BankUI", "AceEvent-3.0")
local private = {frame=nil, currentBank=nil}

function BankUI:OnEnable()
	BankUI:RegisterEvent("GUILDBANKFRAME_OPENED", function() private.currentBank = "guildbank" end)
	BankUI:RegisterEvent("BANKFRAME_OPENED", function(event) private.currentBank = "bank" end)
	BankUI:RegisterEvent("GUILDBANKFRAME_CLOSED", function() private.currentBank = nil end)
	BankUI:RegisterEvent("BANKFRAME_CLOSED", function() private.currentBank = nil end)
end

function BankUI:createTab(parent)
	if private.frame then return private.frame end

	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		parent = parent,
		hidden = true,
		points = "ALL",
		children = {
			{
				type = "GroupTreeFrame",
				key = "groupTree",
				groupTreeInfo = {"Warehousing", "Warehousing_Bank"},
				points = {{"TOPLEFT"}, {"BOTTOMRIGHT", 0, 137}},
			},
			{
				type = "Frame",
				key = "buttonFrame",
				points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, 0}, {"BOTTOMRIGHT"}},
				children = {
					{
						type = "Button",
						key = "btnToBank",
						text = L["Move Group to Bank"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", 5, -5}, {"TOPRIGHT", -5, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnToBags",
						text = L["Move Group to Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "HLine",
						size = {0, 2},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", -5, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 5, -5}},
					},
					{
						type = "Button",
						key = "btnRestock",
						text = L["Restock Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 5, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", -5, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnReagents",
						text = L["Deposit Reagents"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnEmpty",
						text = L["Empty Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", "btnReagents", "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", "btnReagents", "BOTTOM", -3, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnRestore",
						text = L["Restore Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", "btnReagents", "BOTTOM", 3, -5}, {"TOPRIGHT", "btnReagents", "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
				},
			},
		},
		handlers = {
			buttonFrame = {
				btnToBank = {
					OnClick = function() TSM.move:groupTree(private.frame.groupTree:GetSelectedGroupInfo(), "bags", private.currentBank) end,
				},
				btnToBags = {
					OnClick = function() TSM.move:groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnRestock = {
					OnClick = function() TSM.move:restockGroup(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnReagents = {
					OnClick = function()
						if private.currentBank == "bank" then
							if IsReagentBankUnlocked() then
								DepositReagentBank()
							else
								TSMAPI.Util:ShowStaticPopupDialog("CONFIRM_BUY_REAGENTBANK_TAB");
							end
						end
					end,
				},
				btnEmpty = {
					OnClick = function() TSM.move:EmptyRestore(private.currentBank) end,
				},
				btnRestore = {
					OnClick = function() TSM.move:EmptyRestore(private.currentBank, true) end,
				},
			},
		},
	}

    private.frame = TSMAPI.GUI:BuildFrame(frameInfo)

	return private.frame
end
