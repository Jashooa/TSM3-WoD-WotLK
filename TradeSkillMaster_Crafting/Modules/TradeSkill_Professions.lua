-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local TradeSkill = TSM:GetModule("TradeSkill")
local Professions = TradeSkill:NewModule("Professions", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local private = { priceTextCache = { lastClear = 0 }, craftTimeInfo = { timeout = 0, endTime = 0 } }



-- ============================================================================
-- Methods to Add to the TradeSkill Module
-- ============================================================================

function Professions:OnInitialize()
	-- initialize things specific to the professions tab
	Professions:RawHook("ChatEdit_InsertLink", private.InsertLinkHook, true)
	TSMAPI.Delay:AfterTime("craftTimeText", 0.5, private.UpdateCraftTimeText, 0.5)
	TSMAPI.Delay:AfterTime("craftingUpdateTradeSkill", 1, function() TradeSkill:UpdateSelectedTradeSkill() end, 0.1)
	Professions:RegisterEvent("TRADE_SKILL_UPDATE", private.UpdateProfessionDropdown)
end

function private.InitializeDropdown(self, level)
	local info = Lib_UIDropDownMenu_CreateInfo()
	if level == 1 then
		info.text = CRAFT_IS_MAKEABLE
		info.func = function()
			TradeSkillFrame.filterTbl.hasMaterials = not TradeSkillFrame.filterTbl.hasMaterials
			TradeSkillOnlyShowMakeable(TradeSkillFrame.filterTbl.hasMaterials)
			TradeSkillUpdateFilterBar()
		end
		info.keepShownOnClick = true
		info.checked = TradeSkillFrame.filterTbl.hasMaterials
		info.isNotRadio = true
		Lib_UIDropDownMenu_AddButton(info, level)
		
		local _, _, skillLineMaxRank = GetTradeSkillLine()
		local isNPCCrafting = IsNPCCrafting() and skillLineMaxRank == 0
		if (not IsTradeSkillGuild() and not isNPCCrafting) then
			info.text = TRADESKILL_FILTER_HAS_SKILL_UP
			info.func = function() 
				TradeSkillFrame.filterTbl.hasSkillUp  = not TradeSkillFrame.filterTbl.hasSkillUp
				TradeSkillOnlyShowSkillUps(TradeSkillFrame.filterTbl.hasSkillUp)
				TradeSkillUpdateFilterBar()
			end 
			info.keepShownOnClick = true
			info.checked = TradeSkillFrame.filterTbl.hasSkillUp
			info.isNotRadio = true
			Lib_UIDropDownMenu_AddButton(info, level)
		end
		
		info.checked = 	nil
		info.isNotRadio = nil
		info.text = TRADESKILL_FILTER_SLOTS
		info.func =  nil
		info.notCheckable = true
		info.keepShownOnClick = false
		info.hasArrow = true
		info.value = 1
		Lib_UIDropDownMenu_AddButton(info, level)
				
		info.text = TRADESKILL_FILTER_SUBCLASS
		info.func = nil
		info.notCheckable = true
		info.keepShownOnClick = false
		info.hasArrow = true
		info.value = 2
		Lib_UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		if LIB_UIDROPDOWNMENU_MENU_VALUE == 1 then
			local slots = {GetTradeSkillSubClassFilteredSlots(0)}
			local subslots = {}
			for i,slot in pairs(slots) do
				info.text = slot
				info.func = function() TradeSkillSetFilter(0, i, "", slots[i]) end
				info.notCheckable = true
				info.hasArrow = false
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		elseif LIB_UIDROPDOWNMENU_MENU_VALUE == 2 then
			local subClasses = {GetTradeSkillSubClasses()}
			local subslots = {}
			for i,subClass in pairs(subClasses) do
				info.text = subClass
				info.func = function() TradeSkillSetFilter(i, 0, subClasses[i], "", 0) end
				info.notCheckable = true
				subslots = {GetTradeSkillSubCategories(i)}
				info.hasArrow = #subslots > 1
				info.value = i
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		end
	elseif level == 3 then	
		local subClasses = {GetTradeSkillSubClasses()}
		local subslots
		subslots = {GetTradeSkillSubCategories(LIB_UIDROPDOWNMENU_MENU_VALUE)}
		for i,slot in pairs(subslots) do
			info.text = slot
			info.func = function() TradeSkillSetFilter(LIB_UIDROPDOWNMENU_MENU_VALUE, 0, subClasses[LIB_UIDROPDOWNMENU_MENU_VALUE], subslots[i], i) end
			info.notCheckable = true
			info.value = {LIB_UIDROPDOWNMENU_MENU_VALUE, i}
			Lib_UIDropDownMenu_AddButton(info, level)
		end
	end
end

function Professions:GetFrameInfo()
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local queueBtnTooltipColor = TSMAPI.Design:GetInlineColor("link")
	if not TSMTradeSkillFilterDropDown then
		TSMTradeSkillFilterDropDown = CreateFrame("Frame", "TSMTradeSkillFilterDropDown", TSMCraftingTradeSkillFrame, "Lib_UIDropDownMenuTemplate")
		Lib_UIDropDownMenu_Initialize(TSMTradeSkillFilterDropDown, private.InitializeDropdown, "MENU")
		TSMTradeSkillFilterDropDownText:SetJustifyH("CENTER")
		TSMTradeSkillFilterDropDownButton:Show()
	end
	return {
		type = "Frame",
		key = "professionsTab",
		hidden = true,
		points = { { "TOPLEFT", 0, -59 }, { "BOTTOMRIGHT" } },
		scripts = { "OnShow" },
		children = {
			{
				type = "Dropdown",
				key = "dropdown",
				points = { { "TOPLEFT", 3, -4 }, { "TOPRIGHT", -47, -4 } },
				scripts = { "OnValueChanged" },
				tooltip = L["Select one of your characters' professions to browse."],
			},
			{
				type = "Button",
				key = "linkBtn",
				text = L["Link"],
				textHeight = 14,
				size = { 44, 26 },
				points = { { "TOPRIGHT", -5, -4 } },
				scripts = { "OnClick" },
			},
			{
				type = "InputBox",
				key = "searchBar",
				name = "TSMCraftingSearchBar",
				text = SEARCH,
				textColor = { 1, 1, 1, 0.5 },
				size = { 240, 24 },
				points = { { "TOPLEFT", 5, -35 } },
				scripts = { "OnEditFocusGained", "OnEditFocusLost", "OnTextChanged", "OnEnterPressed" },
			},
			{
				type = "Button",
				key = "clearFilterBtn",
				text = L["Clear Filters"],
				textHeight = 14,
				size = { 80, 24 },
				points = { { "TOPLEFT", "searchBar", "TOPRIGHT", 5, 0 } },
				scripts = { "OnClick" },
			},
			{
				type = "Button",
				key = "filterBtn",
				name = "TSMCraftingFilterButton",
				text = L["Filters >>"],
				textHeight = 14,
				size = { nil, 24 },
				points = { { "TOPLEFT", "clearFilterBtn", "TOPRIGHT", 5, 0 }, { "TOPRIGHT", -5, -35 } },
				scripts = { "OnClick" },
			},
			{
				type = "HLine",
				offset = -64,
			},
			{
				type = "ScrollingTableFrame",
				key = "st",
				stCols = { { name = L["Name"], width = 0.8 }, { name = private:GetProfessionsTabPriceColumnText(), width = 0.2 } },
				points = { { "TOPLEFT", 5, -70 }, { "BOTTOMRIGHT", -5, 177 } },
				scripts = { "OnClick", "OnColumnClick" },
			},
			{
				type = "Frame",
				key = "craftInfoFrame",
				points = { { "TOPLEFT", "stContainer", "BOTTOMLEFT", 0, -4 }, { "BOTTOMRIGHT", -3, 3 } },
				children = {
					{
						type = "Frame",
						key = "infoFrame",
						points = { { "TOPLEFT", 3, -3 }, { "BOTTOMLEFT", 3, 53 }, { "TOPRIGHT", -220, -3 } },
						children = {
							{
								type = "IconButton",
								key = "icon",
								size = { 40, 40 },
								points = { { "TOPLEFT" } },
								scripts = { "OnEnter", "OnLeave", "OnClick" },
							},
							{
								type = "Text",
								key = "nameText",
								textHeight = 12,
								justify = { "LEFT" },
								points = { { "TOPLEFT", "icon", "TOPRIGHT", 4, 0 }, { "TOPRIGHT" } },
							},
							{
								type = "Text",
								key = "toolsText",
								textHeight = 12,
								justify = { "LEFT" },
								points = { { "TOPLEFT", "nameText", "BOTTOMLEFT", 0, -2 }, { "TOPRIGHT", "nameText", "BOTTOMRIGHT", 0, -2 } },
							},
							{
								type = "Text",
								key = "cooldownText",
								textHeight = 11,
								justify = { "LEFT" },
								points = { { "TOPLEFT", "toolsText", "BOTTOMLEFT", 0, -2 }, { "TOPRIGHT", "toolsText", "BOTTOMRIGHT", 0, -2 } },
							},
							{
								type = "Text",
								key = "descText",
								textHeight = 11,
								justify = { "LEFT", "TOP" },
								points = { { "TOPLEFT", "icon", "BOTTOMLEFT", 0, -2 }, { "BOTTOMRIGHT" } },
							},
						},
					},
					{
						type = "HLine",
						offset = 0,
						points = { { "TOPLEFT", "infoFrame", "BOTTOMLEFT", -1, 0 }, { "TOPRIGHT", "infoFrame", "BOTTOMRIGHT", 1, 0 } },
					},
					{
						type = "VLine",
						offset = 0,
						points = { { "TOPLEFT", "infoFrame", "TOPRIGHT", 1, 3 }, { "BOTTOMLEFT", "infoFrame", "BOTTOMRIGHT", 1, -53 } },
					},
					{
						type = "Frame",
						key = "matsFrame",
						points = { { "TOPLEFT", "infoFrame", "TOPRIGHT", 5, 0 }, { "TOPRIGHT" }, { "BOTTOMRIGHT" } },
						children = {
							{
								type = "IconButton",
								key = "sizer",
								icon = "Interface\\Addons\\TradeSkillMaster\\Media\\Sizer",
								size = { 16, 16 },
								points = { { "BOTTOMRIGHT", -2, 2 } },
								scripts = { "OnMouseDown", "OnMouseUp" },
							},
							{
								type = "Text",
								key = "castText",
								textSize = "small",
								justify = { "RIGHT", "BOTTOM" },
								size = { 0, 18 },
								points = { { "BOTTOMRIGHT", -22, 3 } },
							},
							{
								type = "Text",
								key = "matsText",
								text = TSMAPI.Design:GetInlineColor("link") .. L["Materials:"] .. "|r",
								textSize = "small",
								justify = { "LEFT", "TOP" },
								points = { { "TOPLEFT" }, { "TOPRIGHT" } },
							},
							{
								type = "WidgetVList",
								key = "reagentButtons",
								repeatCount = MAX_TRADE_SKILL_REAGENTS or 8,
								startPoints = { { "TOPLEFT", 0, -15 }, { "TOPRIGHT", 0, -15 } },
								repeatOffset = -3,
								widget = {
									type = "ItemLinkLabel",
									key = "linkLabel",
									text = "",
									textHeight = 13,
									justify = { "LEFT", "MIDDLE" },
									size = { 0, 13 },
								},
							},
						},
					},
					{
						type = "Frame",
						key = "buttonsFrame",
						points = { { "TOPRIGHT", "infoFrame", "BOTTOMRIGHT", -2, -5 }, { "BOTTOMLEFT", 2, 2 } },
						children = {
							{
								type = "TextureButton",
								key = "lessBtn",
								normalTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
								pushedTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down",
								disabledTexture = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-DisabledTexture",
								highlightTexture = "Interface\\Buttons\\UI-Common-MouseHilight",
								size = { 28, 28 },
								points = { { "TOPLEFT", -4, 4 } },
								scripts = { "OnClick" },
							},
							{
								type = "InputBox",
								key = "inputBox",
								numeric = true,
								name = "TSMCraftingCreateInputBox",
								size = { 40, 0 },
								points = { { "TOPLEFT", "lessBtn", "TOPRIGHT", -2, -4 }, { "BOTTOMLEFT", "lessBtn", "BOTTOMRIGHT", -2, 4 } },
								scripts = { "OnEditFocusGained" },
							},
							{
								type = "TextureButton",
								key = "moreBtn",
								normalTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
								pushedTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down",
								disabledTexture = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-DisabledTexture",
								highlightTexture = "Interface\\Buttons\\UI-Common-MouseHilight",
								size = { 28, 28 },
								points = { { "TOPLEFT", "inputBox", "TOPRIGHT", -2, 4 }, { "BOTTOMLEFT", "inputBox", "BOTTOMRIGHT", -2, -4 } },
								scripts = { "OnClick" },
							},
							{
								type = "Button",
								key = "queueBtn",
								text = L["Queue"],
								textHeight = 15,
								clicks = "AnyUp",
								tooltip = strjoin("\n", queueBtnTooltipColor .. L["Left-Click|r to add this craft to the queue."], queueBtnTooltipColor .. L["Shift-Left-Click|r to queue all you can craft."], queueBtnTooltipColor .. L["Right-Click|r to subtract this craft from the queue."], queueBtnTooltipColor .. L["Shift-Right-Click|r to remove all from queue."]),
								points = { { "TOPLEFT", "moreBtn", "TOPRIGHT", 0, -4 }, { "BOTTOMLEFT", "moreBtn", "BOTTOMRIGHT", 0, 4 }, { "TOPRIGHT" } },
								scripts = { "OnClick" },
							},
							{
								type = "Button",
								key = "createBtn",
								text = CREATE_PROFESSION,
								textHeight = 15,
								size = { 0, 20 },
								points = { { "BOTTOMLEFT" }, { "BOTTOMRIGHT", BFC.PARENT, "BOTTOM", -2, 0 } },
								scripts = { "OnClick" },
							},
							{
								type = "Button",
								key = "createAllBtn",
								text = CREATE_ALL,
								textHeight = 15,
								size = { 0, 20 },
								points = { { "BOTTOMLEFT", BFC.PARENT, "BOTTOM", 2, 0 }, { "BOTTOMRIGHT" } },
								scripts = { "OnClick" },
							},
						},
					},
				},
			},
		},
		handlers = {
			OnShow = function(self)
				private.frame = self:GetParent()
				if not TradeSkill:GetVisibilityInfo().frame then return end
				if not self.helpBtn then
					local helpPlateInfo = {
						FramePos = { x = 0, y = 0 },
						FrameSize = { width = private.frame:GetWidth(), height = private.frame:GetHeight() },
						{
							ButtonPos = { x = 80, y = 15 },
							HighLightBox = { x = 20, y = 0, width = 80, height = 25 },
							ToolTipDir = "UP",
							ToolTipText = L["This button will switch to the default profession UI. You can switch back by clicking the 'TSM' button at the top of the default profession UI."]
						},
						{
							ButtonPos = { x = 170, y = -18 },
							HighLightBox = { x = 0, y = -25, width = private.frame:GetWidth(), height = 30 },
							ToolTipDir = "UP",
							ToolTipText = L["You can change the current tab of the profession frame, start gathering materials for your queue, and show the queue using these buttons."]
						},
						{
							ButtonPos = { x = 50, y = -48 },
							HighLightBox = { x = 0, y = -55, width = private.frame:GetWidth(), height = 35 },
							ToolTipDir = "UP",
							ToolTipText = L["You can use this dropdown to switch between the current character's professions."]
						},
						{
							ButtonPos = { x = 300, y = -250 },
							HighLightBox = { x = 0, y = -90, width = private.frame:GetWidth(), height = 410 },
							ToolTipDir = "RIGHT",
							ToolTipText = L["This area of the profession tab works similarly to the default profession UI, but with some added features. These include the ability to easily add crafts to your queue, listing profit next to crafts, and displaying inventory information."]
						},
					}

					self.helpBtn = CreateFrame("Button", nil, private.frame.professionsTab, "MainHelpPlateButton")
					self.helpBtn:SetPoint("CENTER", private.frame, "TOPLEFT", 0, 0)
					self.helpBtn:SetScript("OnClick", function() TradeSkill:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, true) end)
					self.helpBtn:SetScript("OnHide", function() if HelpPlate_IsShowing(helpPlateInfo) then TradeSkill:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false) end end)
					if not TSM.db.global.helpPlatesShown.profession then
						TSM.db.global.helpPlatesShown.profession = true
						TradeSkill:ToggleHelpPlate(private.frame, helpPlateInfo, self.helpBtn, false)
					end
				end
				private.frame.groupsBtn:UnlockHighlight()
				private.frame.professionsBtn:LockHighlight()
				private.frame.groupsTab:Hide()
				Professions:UpdateST()
				private:UpdateProfessionDropdown()
			end,
			dropdown = {
				OnValueChanged = function(self, info)
					local playerName, profession = ("~"):split(info)
					if playerName == UnitName("player") then
						if profession == GetSpellInfo(TSM.MINING_SPELLID) then
							-- mining needs to be opened as smelting
							CastSpellByName(GetSpellInfo(TSM.SMELTING_SPELLID))
						else
							CastSpellByName(profession)
						end
					else
						local link = TSM.db.factionrealm.playerProfessions[playerName][profession].link
						TSMAPI:Assert(link, format("Profession data not found for %s on %s.", profession, playerName))
						local tradeString = strsub(select(3, ("|"):split(link)), 2)
						SetItemRef(tradeString, link) -- opens the profession from the link
					end
				end,
			},
			linkBtn = {
				OnClick = function(self)
					local link = GetTradeSkillListLink()
					if not link then return TSM:Print(L["Could not get link for profession."]) end

					local activeEditBox = ChatEdit_GetActiveWindow()
					if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
						local text = MacroFrameText:GetText() .. link
						if strlenutf8(text) <= 255 then
							MacroFrameText:Insert(link)
						end
					elseif activeEditBox then
						ChatEdit_InsertLink(link)
					end
				end,
			},
			searchBar = {
				OnEditFocusGained = function(self)
					self:SetTextColor(1, 1, 1, 1)
					if self:GetText() == SEARCH then
						self:SetText("")
					end
				end,
				OnEditFocusLost = function(self)
					if self:GetText() == "" or self:GetText() == SEARCH then
						self:SetTextColor(1, 1, 1, 0.5)
						self:SetText(SEARCH)
					end
				end,
				OnTextChanged = function(self)
					local text = self:GetText():trim()
					if text == SEARCH then
						text = ""
					end
					SetTradeSkillItemNameFilter(text)
				end,
				OnEnterPressed = function(self)
					self:ClearFocus()
				end,
			},
			clearFilterBtn = {
				OnClick = function(self)
					TradeSkill:ClearFilters()
				end,
			},
			filterBtn = {
				OnClick = function(self)
					Lib_ToggleDropDownMenu(1, nil, TSMTradeSkillFilterDropDown, "TSMCraftingFilterButton", self:GetWidth(), 0)
				end,
			},
			st = {
				OnClick = function(_, data, _, button)
					if data.isCollapseAll then
						TradeSkillCollapseAllButton:Click()
					elseif button == "LeftButton" then
						if IsModifiedClick() then
							HandleModifiedItemClick(GetTradeSkillRecipeLink(data.index))
						else
							TradeSkillFrame_SetSelection(data.index)
							TradeSkillFrame_Update()
							TradeSkill:UpdateSelectedTradeSkill(true)
						end
					end
				end,
				OnColumnClick = function(self)
					if self.colNum == 2 then
						TSM.db.global.priceColumn = TSM.db.global.priceColumn + 1
						TSM.db.global.priceColumn = TSM.db.global.priceColumn > 3 and 1 or TSM.db.global.priceColumn
						self:SetText(private:GetProfessionsTabPriceColumnText())
						wipe(private.priceTextCache)
						private.priceTextCache.lastClear = time()
						Professions:UpdateST()
					end
				end
			},
			-- craft info frame handlers
			craftInfoFrame = {
				infoFrame = {
					icon = {
						OnClick = function(self)
							if not self:GetParent():GetParent().index then return end
							HandleModifiedItemClick(GetTradeSkillItemLink(self:GetParent():GetParent().index))
						end,
						OnEnter = function(self)
							if not self:GetParent():GetParent().index then return end
							local spellID = TSM:GetSpellID(self:GetParent():GetParent().index)
							local itemString = spellID and TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].itemString
							if itemString then
								GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
								TSMAPI.Util:SafeTooltipLink(itemString)
							else
								GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
								GameTooltip:SetTradeSkillItem(self:GetParent():GetParent().index)
							end
						end,
						OnLeave = function(self)
							if not self:GetParent():GetParent().index then return end
							GameTooltip:Hide()
						end,
					},
				},
				matsFrame = {
					sizer = {
						OnMouseDown = function()
							private.frame:StartSizing("BOTTOMRIGHT")
						end,
						OnMouseUp = function()
							private.frame:StopMovingOrSizing()
						end,
					},
				},
				buttonsFrame = {
					lessBtn = {
						OnClick = function(self)
							local num = self:GetParent().inputBox:GetNumber() - 1
							self:GetParent().inputBox:SetNumber(max(num, 1))
						end,
					},
					inputBox = {
						OnEditFocusGained = function(self)
							self:HighlightText()
						end,
					},
					moreBtn = {
						OnClick = function(self)
							local num = self:GetParent().inputBox:GetNumber() + 1
							self:GetParent().inputBox:SetNumber(max(num, 1))
						end,
					},
					queueBtn = {
						OnClick = function(self, button)
							local index = self:GetParent():GetParent().index
							local spellID = TSM:GetSpellID(index)
							if not spellID or not TSM.db.factionrealm.crafts[spellID] then return end
							local inputBoxNum = max(floor(self:GetParent().inputBox:GetNumber()), 1)

							if button == "LeftButton" and IsModifiedClick() then
								-- queue all that can be crafted
								local numCanCraft = select(3, GetTradeSkillInfo(index)) or 0
								TSM.Queue:SetNumQueued(spellID, numCanCraft)
							elseif button == "LeftButton" then
								TSM.Queue:Add(spellID, inputBoxNum)
							elseif button == "RightButton" and IsModifiedClick() then
								TSM.Queue:SetNumQueued(spellID, 0)
							elseif button == "RightButton" then
								TSM.Queue:Remove(spellID, inputBoxNum)
							end
							TradeSkill.Queue:Update()
						end
					},
					createBtn = {
						OnClick = function(self)
							TradeSkill:CastTradeSkill(self:GetParent():GetParent().index, self:GetParent().inputBox:GetNumber())
						end
					},
					createAllBtn = {
						OnClick = function(self)
							local quantity = select(3, GetTradeSkillInfo(self:GetParent():GetParent().index))
							TradeSkill:CastTradeSkill(self:GetParent():GetParent().index, quantity, self.vellum)
							self:GetParent().inputBox:SetNumber(GetTradeskillRepeatCount())
						end
					},
				},
			},
		}
	}
end

function Professions:OnButtonClicked(frame)
	private.frame = private.frame or frame
	private.frame.professionsTab:Show()
end


-- ============================================================================
-- Professions Tab Update Functions
-- ============================================================================

function private.InsertLinkHook(link)
	local putIntoChat = Professions.hooks.ChatEdit_InsertLink(link)
	if not putIntoChat and TradeSkill:GetVisibilityInfo().professionsTab and not strfind(GetMouseFocus() and GetMouseFocus():GetName() or "", "MerchantItem([0-9]+)ItemButton") then
		local name = TSMAPI.Item:GetInfo(link)
		if name then
			private.frame.professionsTab.searchBar:SetText(name)
			private.frame.professionsTab.searchBar:SetTextColor(1, 1, 1, 1)
			return true
		end
	end
	return putIntoChat
end

function private:FormatTime(seconds)
	if seconds == 0 then return end
	local hours = floor(seconds / 3600)
	local mins = floor((seconds % 3600) / 60)
	local secs = seconds % 60

	local str = ""
	if hours > 0 then
		str = str .. format("%dh", hours)
	end
	if mins > 0 then
		str = str .. format("%dm", mins)
	end
	if secs > 0 then
		str = str .. format("%ds", secs)
	end
	return str
end

function private:UpdateCraftTimeText()
	if not TradeSkill:GetVisibilityInfo().professionsTab then return end
	local startTime, endTime, isTradeSkill = select(5, UnitCastingInfo("player"))
	if isTradeSkill then
		local timePerCraft = endTime - startTime
		endTime = endTime + (timePerCraft * (GetTradeskillRepeatCount() - 1))
		private.craftTimeInfo.endTime = ceil(endTime / 1000)
	elseif not startTime then
		-- not casting a tradeskill
		if private.craftTimeInfo.endTime > GetTime() then
			private.craftTimeInfo.timeout = private.craftTimeInfo.timeout + 1
			if private.craftTimeInfo.timeout > 3 then
				private.craftTimeInfo.endTime = 0
				private.craftTimeInfo.timeout = 0
			end
		else
			private.craftTimeInfo.timeout = 0
		end
	end

	if private.craftTimeInfo.endTime > GetTime() then
		private.frame.professionsTab.craftInfoFrame.matsFrame.castText:SetText(private:FormatTime(private.craftTimeInfo.endTime - GetTime()))
	else
		private.frame.professionsTab.craftInfoFrame.matsFrame.castText:SetText()
	end
end

function private:GetProfessionsTabPriceColumnText()
	if TSM.db.global.priceColumn == 1 then
		return L["Crafting Cost"]
	elseif TSM.db.global.priceColumn == 2 then
		return L["Item Value"]
	elseif TSM.db.global.priceColumn == 3 then
		return L["Profit"]
	end
end

function private:UpdateProfessionDropdown()
	if not private.frame then return end
	local list = TSM.TradeSkillScanner:GetProfessionList()
	local playerName = select(2, IsTradeSkillLinked()) or UnitName("player")
	local professionName = TSM:GetCurrentProfessionName()
	local level, maxLevel = select(2, GetTradeSkillLine())
	local currentSelection = playerName .. "~" .. professionName
	private.frame.professionsTab.dropdown:SetList(list)
	private.frame.professionsTab.dropdown:SetValue(currentSelection)
	if not list[currentSelection] then
		if IsNPCCrafting() then
			private.frame.professionsTab.dropdown:SetText(format("%s - %s", professionName, playerName))
		else
			private.frame.professionsTab.dropdown:SetText(format("%s %d/%d - %s", professionName, level, maxLevel, playerName))
		end
	end
end

function private:RGBPercToHex(tbl)
	local r = tbl.r <= 1 and tbl.r >= 0 and tbl.r or 0
	local g = tbl.g <= 1 and tbl.g >= 0 and tbl.g or 0
	local b = tbl.b <= 1 and tbl.b >= 0 and tbl.b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function Professions:UpdateST()
	if not TradeSkill:GetVisibilityInfo().professionsTab or not GetTradeSkillInfo(1) then return end
	TSM:UpdateCraftReverseLookup()
	local stData = {}

	if private.priceTextCache.lastClear + 60 < time() then
		wipe(private.priceTextCache)
		private.priceTextCache.lastClear = time()
	end

	-- add collapse all row
	tinsert(stData, { cols = { { value = "|cff" .. private:RGBPercToHex(TradeSkillTypeColor.header) .. ALL .. " [" .. (TradeSkillCollapseAllButton.collapsed and "+" or "-") .. "]|r" }, { value = "" } }, isCollapseAll = true })

	-- go through tradeskills and populate data
	local leader = ""
	local numAvailableAllCache = {}
	local inventoryTotals = select(4, TSM:GetInventoryTotals())
	for i = 1, GetNumTradeSkills() do
		local skillName, skillType, numAvailable, isExpanded, _, numSkillUps, _, showProgressBar, currentRank, maxRank, _, isUnavailable, unavailableString = GetTradeSkillInfo(i)
		if IsNPCCrafting() and skillType ~= "header" and skillType ~= "subheader" then
			skillType = "nodifficulty"
		end
		TSMAPI:Assert(skillName, "No skill name found for index " .. i)
		local spellID = TSM:GetSpellID(i)
		local numAvailableAll, priceText = nil, nil
		local craft = TSM.db.factionrealm.crafts[spellID]
		if spellID then
			-- calculate the total we are able to craft including other inventory
			if craft then
				local vendorMatCount = nil
				for itemString, quantity in pairs(craft.mats) do
					local isVendorItem = TSMAPI.Item:GetVendorCost(itemString) and true or false
					if isVendorItem then
						vendorMatCount = min((vendorMatCount or math.huge), floor((inventoryTotals[itemString] or 0) / quantity))
					else
						numAvailableAll = min((numAvailableAll or math.huge), floor((inventoryTotals[itemString] or 0) / quantity))
					end
				end
				if vendorMatCount and not numAvailableAll then
					-- this craft has ONLY vendor-bought mats, so don't treat them specially (otherwise we could craft infinite numbers)
					numAvailableAll = vendorMatCount
				end
			end

			-- get the price text
			priceText = private.priceTextCache[spellID]
			if not priceText then
				local cost, buyout, profit = TSM.Cost:GetSpellCraftPrices(spellID)
				if TSM.db.global.priceColumn == 1 and cost and cost > 0 then
					cost = cost * craft.numResult
					priceText = TSMAPI:MoneyToString(cost, TSMAPI.Design:GetInlineColor("link"))
				elseif TSM.db.global.priceColumn == 2 and buyout and buyout > 0 then
					buyout = buyout * craft.numResult
					priceText = TSMAPI:MoneyToString(buyout, TSMAPI.Design:GetInlineColor("link"))
				elseif TSM.db.global.priceColumn == 3 and profit then
					profit = profit * craft.numResult
					priceText = (profit < 0) and ("|cffff0000-|r" .. TSMAPI:MoneyToString(-profit, "|cffff0000")) or TSMAPI:MoneyToString(profit, "|cff00ff00")
				end
				if priceText then
					private.priceTextCache[spellID] = priceText
				else
					priceText = "---"
				end
			end
		else
			priceText = ""
		end

		-- update cooldown end time
		local cooldown = GetTradeSkillCooldown(i)
		if not isUnavailable and craft and craft.hasCD then
			craft.cooldownTimes = craft.cooldownTimes or {}
			craft.cooldownTimes[UnitName("player")] = craft.cooldownTimes[UnitName("player")] or {endTime=nil, prompt=nil}
			if cooldown then
				craft.cooldownTimes[UnitName("player")].endTime = time() + floor(cooldown)
			else
				craft.cooldownTimes[UnitName("player")].endTime = 0
			end
		end

		-- set the leader for this row
		if skillType == "header" then
			leader = ""
		elseif skillType == "subheader" then
			-- first index should always be a header - this is a Blizzard bug introduced in 6.0.2
			leader = (i == 1) and "" or "  "
		end

		-- add text for header
		if skillType == "header" or skillType == "subheader" then
			if showProgressBar then
				skillName = skillName .. " (" .. currentRank .. "/" .. maxRank .. ") " .. (isExpanded and " [-]" or " [+]")
			else
				skillName = skillName .. (isExpanded and " [-]" or " [+]")
			end
		end

		-- add text for multiple skill-ups
		if numSkillUps > 1 and skillType == "optimal" then
			skillName = skillName .. " <" .. numSkillUps .. ">"
		end

		-- set the text for the number available if necessary, add color, and all the leader
		if numAvailable > 0 or (numAvailableAll and numAvailableAll > 0) then
			local availableText = numAvailable .. " (" .. (numAvailableAll or 0) .. ")"
			skillName = leader .. "|cff" .. private:RGBPercToHex(TradeSkillTypeColor[skillType]) .. skillName .. " [" .. availableText .. "]|r"
		else
			skillName = leader .. "|cff" .. private:RGBPercToHex(TradeSkillTypeColor[skillType]) .. skillName .. "|r"
		end

		-- set the leader for the next row after a header/subheader to be indented one extra
		if skillType == "header" or skillType == "subheader" then
			leader = leader .. "  "
		end

		tinsert(stData, { cols = { { value = skillName }, { value = priceText } }, index = i })
	end

	private.frame.professionsTab.st:SetData(stData)
	TradeSkill:UpdateSelectedTradeSkill(true)
	private.frame.professionsTab.craftInfoFrame.buttonsFrame.inputBox:SetNumber(GetTradeskillRepeatCount())
end

function TradeSkill:UpdateSelectedTradeSkill(forceUpdate)
	if not TradeSkill:GetVisibilityInfo().professionsTab then return end
	local frame = private.frame.professionsTab
	if GetTradeSkillSelectionIndex() == 0 then
		TradeSkillFrame.selectedSkill = GetFirstTradeSkill()
	else
		TradeSkillFrame.selectedSkill = GetTradeSkillSelectionIndex()
	end
	if forceUpdate or (frame.st:GetSelection() or 0) - 1 ~= TradeSkillFrame.selectedSkill then
		frame.st:SetSelection(TradeSkillFrame.selectedSkill + 1)
		local skillIndex = TradeSkillFrame.selectedSkill
		local name, numAvailable, altVerb, isUnavailable, unavailableString = TSMAPI.Util:Select({ 1, 3, 5, 12, 13 }, GetTradeSkillInfo(skillIndex))
		-- Enable display of items created
		local lNum, hNum = GetTradeSkillNumMade(skillIndex)
		--workaround for incorrect values returned for Temporal Crystal
		if GetTradeSkillLine() == GetSpellInfo(7411) then
			local spellLink = GetTradeSkillRecipeLink(skillIndex)
			local spellID = TSM:GetSpellID(spellLink)
			local itemString = spellID and TSM.db.factionrealm.crafts[spellID] and TSM.db.factionrealm.crafts[spellID].itemString
			if spellID == 169092 and itemString == "i:113588" then
				lNum, hNum = 1, 1
			end
		end
		local numMade = floor(((lNum or 1) + (hNum or 1)) / 2)
		if altVerb == ENSCRIBE then
			numMade = 1
		end
		if numMade > 1 then
			name = numMade .. " x " .. name
		end
		frame.craftInfoFrame.index = skillIndex
		frame.craftInfoFrame.infoFrame.icon:SetTexture(GetTradeSkillIcon(skillIndex))
		frame.craftInfoFrame.infoFrame.nameText:SetText(TSMAPI.Design:GetInlineColor("link") .. (name or "") .. "|r")
		frame.craftInfoFrame.infoFrame.descText:SetText(GetTradeSkillDescription(skillIndex))

		-- The code below is heavily based on the code in Blizzard_TradeSkillUI.lua
		local toolsInfo = BuildColoredListString(GetTradeSkillTools(skillIndex))
		frame.craftInfoFrame.infoFrame.toolsText:SetText(toolsInfo and REQUIRES_LABEL .. " " .. toolsInfo or "")
		local cooldown, isDaily = GetTradeSkillCooldown(skillIndex)
		if isUnavailable then
			frame.craftInfoFrame.infoFrame.cooldownText:SetText("|cffff0000" .. unavailableString .. "|r")
		elseif not cooldown then
			frame.craftInfoFrame.infoFrame.cooldownText:SetText("")
		elseif cooldown > 60 * 60 * 24 then -- cooldown is greater than 1 day
			frame.craftInfoFrame.infoFrame.cooldownText:SetText("|cffff0000" .. COOLDOWN_REMAINING .. " " .. SecondsToTime(cooldown, true, false, 1, true) .. "|r")
		elseif isDaily then
			frame.craftInfoFrame.infoFrame.cooldownText:SetText("|cffff0000" .. COOLDOWN_EXPIRES_AT_MIDNIGHT .. "|r")
		else
			frame.craftInfoFrame.infoFrame.cooldownText:SetText("|cffff0000" .. COOLDOWN_REMAINING .. " " .. SecondsToTime(cooldown) .. "|r")
		end

		for i, btn in ipairs(frame.craftInfoFrame.matsFrame.reagentButtons) do
			local name, texture, needed, player = GetTradeSkillReagentInfo(skillIndex, i)
			if name then
				btn:Show()
				btn.link = GetTradeSkillReagentItemLink(skillIndex, i)
				local linkText = (texture and "|T" .. texture .. ":0|t" or "") .. " " .. (GetTradeSkillReagentItemLink(skillIndex, i) or name)
				local color = (needed > player) and "|cffff0000" or "|cff00ff00"
				btn:SetText(format("%s(%d/%d) %s|r", color, player, needed, linkText))
			else
				btn:Hide()
				btn:SetText("")
			end
		end

		if altVerb == ENSCRIBE then
			frame.craftInfoFrame.buttonsFrame.createAllBtn:SetText(L["Enchant Vellum"])
			frame.craftInfoFrame.buttonsFrame.createAllBtn.vellum = TSMAPI.Item:GetInfo(TSM.VELLUM_ITEM_STRING)
		else
			frame.craftInfoFrame.buttonsFrame.createAllBtn:SetText(CREATE_ALL)
			frame.craftInfoFrame.buttonsFrame.createAllBtn.vellum = nil
		end

		if numAvailable > 0 and not IsTradeSkillLinked() then
			local num = frame.craftInfoFrame.buttonsFrame.inputBox:GetNumber()
			frame.craftInfoFrame.buttonsFrame.inputBox:SetNumber(max(min(num, numAvailable), 1))
		else
			frame.craftInfoFrame.buttonsFrame.inputBox:SetNumber(1)
			isUnavailable = true
		end
		if isUnavailable then
			frame.craftInfoFrame.buttonsFrame.createBtn:Disable()
			frame.craftInfoFrame.buttonsFrame.createAllBtn:Disable()
		else
			frame.craftInfoFrame.buttonsFrame.createBtn:Enable()
			frame.craftInfoFrame.buttonsFrame.createAllBtn:Enable()
		end
	end
end