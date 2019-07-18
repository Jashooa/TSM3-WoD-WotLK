-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local TradeSkill = TSM:GetModule("TradeSkill")
local Groups = TradeSkill:NewModule("Groups")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local private = {}



-- ============================================================================
-- Module Functions
-- ============================================================================

function Groups:GetFrameInfo()
	return {
		type = "Frame",
		key = "groupsTab",
		hidden = true,
		points = {{"TOPLEFT", 0, -59}, {"BOTTOMRIGHT"}},
		scripts = {"OnShow"},
		children = {
			{
				type = "GroupTreeFrame",
				key = "groupTree",
				groupTreeInfo = {"Crafting", "Crafting_Profession"},
				points = {{"TOPLEFT", 5, -5}, {"BOTTOMRIGHT", -5, 35}},
			},
			{
				type = "Button",
				key = "createBtn",
				text = L["Create Profession Groups"],
				textHeight = 13,
				size = {160, 24},
				points = {{"BOTTOMLEFT", 5, 5}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "restockBtn",
				text = L["Restock Selected Groups"],
				textHeight = 20,
				size = {0, 24},
				points = {{"BOTTOMLEFT", "createBtn", "BOTTOMRIGHT", 5, 0}, {"BOTTOMRIGHT", -5, 5}},
				scripts = {"OnClick"},
			},
		},
		handlers = {
			OnShow = function(self)
				private.frame = self:GetParent()
				if not TradeSkill:GetVisibilityInfo().frame then return end
				self.createBtn:SetDisabled(IsTradeSkillLinked())
				private.frame.groupsBtn:LockHighlight()
				private.frame.professionsBtn:UnlockHighlight()
				private.frame.professionsTab:Hide()
			end,
			createBtn = {
				OnClick = function(self)
					local profession = TSM:GetCurrentProfessionName()
					if profession == "UNKNOWN" then return end
					TSM.TradeSkillScanner:CreatePresetGroups()
					local playerName = UnitName("player")
					TSMAPI:Assert(playerName)
					TSMAPI:Assert(profession)
					TSMAPI:Assert(TSM.db.factionrealm.playerProfessions[playerName][profession])
					TSM.db.factionrealm.playerProfessions[playerName][profession].prompted = true
					TSMAPI.Sync:KeyUpdated(TSM.db.factionrealm.playerProfessions, playerName)
				end,
			},
			restockBtn = {
				OnClick = function(self)
					TSM.Queue:DoRestock(self:GetParent().groupTree:GetSelectedGroupInfo())
					TradeSkill.Queue:Update()
				end,
			},
		},
	}
end

function Groups:OnButtonClicked(frame)
	private.frame = private.frame or frame
	private.frame.groupsTab:Show()
end