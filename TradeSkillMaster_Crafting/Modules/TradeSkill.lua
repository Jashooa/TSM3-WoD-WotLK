-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local TradeSkill = TSM:NewModule("TradeSkill", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local private = {frame=nil, switchBtn=nil, currentProfession=nil, showThreadId=nil, noHide=nil, noShow=nil}



-- ============================================================================
-- Initialization Functions
-- ============================================================================

function TradeSkill:OnInitialize()
	for name, module in pairs(TradeSkill.modules) do
		TradeSkill[name] = module
	end
	TradeSkill:RegisterEvent("TRADE_SKILL_SHOW", "EventHandler")
	TradeSkill:RegisterEvent("TRADE_SKILL_CLOSE", "EventHandler")
	TradeSkill:RegisterEvent("GARRISON_TRADESKILL_NPC_CLOSED", "EventHandler")
	TradeSkill:RegisterEvent("TRADE_SKILL_UPDATE", "EventHandler")
	TradeSkill:RegisterEvent("TRADE_SKILL_FILTER_UPDATE", "EventHandler")
	TradeSkill:RegisterEvent("UPDATE_TRADESKILL_RECAST", "EventHandler")
	TradeSkill:RegisterEvent("CHAT_MSG_SKILL", "EventHandler")
	TradeSkill:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "EventHandler")
	TradeSkill:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "EventHandler")
	TradeSkill:RegisterEvent("UNIT_SPELLCAST_FAILED", "EventHandler")
	TradeSkill:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", "EventHandler")
	TradeSkill:RegisterEvent("BAG_UPDATE", "EventHandler")
	TSMAPI.Inventory:RegisterCallback(private.OnProfessionUpdate)
	TSMAPI.Threading:StartImmortal(private.LinkedProfessionScanThread, 0.5)
end



-- ============================================================================
-- General Module Functions
-- ============================================================================

function TradeSkill:EventHandler(event, ...)
	-- deal with TRADE_SKILL_SHOW / TRADE_SKILL_CLOSE specially
	if event == "TRADE_SKILL_SHOW" then
		private.OnShowThreadDone()
		private.showThreadId = TSMAPI.Threading:Start(private.ShowProfessionWindowThread, 0.8, private.OnShowThreadDone)
		if private.noShow then
			-- run it right away so we don't leave the tradeskillframe visible for one frame
			TSMAPI.Threading:Run(private.showThreadId)
		end
		return
	elseif event == "TRADE_SKILL_CLOSE" or event == "GARRISON_TRADESKILL_NPC_CLOSED" then
		TradeSkill.HideTradeSkill("EVENT")
		return
	end

	-- if we are changing professions or not currently shown, just ignore this event
	if not private.currentProfession or not TradeSkill:GetVisibilityInfo().frame or TSM:GetCurrentProfessionName() ~= private.currentProfession then return end

	if event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_FILTER_UPDATE" then
		local currentSelection = GetTradeSkillSelectionIndex()
		if event ~= "TRADE_SKILL_FILTER_UPDATE" and currentSelection > 1 and currentSelection <= GetNumTradeSkills() then
			TradeSkillFrame_SetSelection(currentSelection)
		else
			TradeSkillFrame_SetSelection(GetFirstTradeSkill())
		end
		TradeSkillFrame_Update()
		private:OnProfessionUpdate()
		private:UpdateCooldownsFrame()
	elseif event == "UPDATE_TRADESKILL_RECAST" then
		private.frame.professionsTab.craftInfoFrame.buttonsFrame.inputBox:SetNumber(GetTradeskillRepeatCount())
	elseif event == "CHAT_MSG_SKILL" then
		-- update the skill level of the player's tradeskill
		if IsTradeSkillGuild() or IsNPCCrafting() then return end
		local skillName = TSM:GetCurrentProfessionName()
		local level, maxLevel = select(2, GetTradeSkillLine())
		local isLinked, linkedPlayer = IsTradeSkillLinked()
		local playerName = linkedPlayer or UnitName("player")
		if skillName and skillName ~= "UNKNOWN" and not isLinked and TSM.db.factionrealm.playerProfessions[playerName] and TSM.db.factionrealm.playerProfessions[playerName][skillName] then
			TSM.db.factionrealm.playerProfessions[playerName][skillName].level = level
			TSM.db.factionrealm.playerProfessions[playerName][skillName].maxLevel = maxLevel
			TSMAPI.Sync:KeyUpdated(TSM.db.factionrealm.playerProfessions, playerName)
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, spellID = TSMAPI.Util:Select({1, 5}, ...)
		if unit ~= "player" or not TSM.db.factionrealm.crafts[spellID] then return end
		if not TradeSkill.isCrafting or TradeSkill.isCrafting.spellID ~= spellID then return end
		-- remove one from the queue
		if TSM.Queue:Remove(spellID, 1) then
			private:UpdateCooldownsFrame()
			private:OnProfessionUpdate()
		end
		TradeSkill.isCrafting.quantity = TradeSkill.isCrafting.quantity - 1
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" then
		local unit, spellID = TSMAPI.Util:Select({1, 5}, ...)
		if unit ~= "player" then return end

		if TradeSkill.isCrafting and spellID == TradeSkill.isCrafting.spellID then
			TradeSkill.isCrafting.quantity = 0
		end
	elseif event == "BAG_UPDATE" then
		private:UpdateCooldownsFrame()
		private:OnProfessionUpdate()
	else
		TSMAPI:Assert(false, "Unexpected event: "..tostring(event))
	end
end

function TradeSkill:GetVisibilityInfo()
	local result = {}
	result.frame = private.frame and private.frame:IsVisible()
	if result.frame then
		-- frame is created and visible, so populate visible status children
		for i, v in pairs(TSMCraftingTradeSkillFrame) do
			if type(v) == "table" and v.tsmFrameType == "Frame" then
				result[i] = v:IsVisible()
			end
		end
	end
	return result
end



-- ============================================================================
-- TradeSkill Creation Functions
-- ============================================================================

function private:Create()
	if private.frame then return end

	local frameDefaults = {
		x = 100,
		y = 300,
		width = 450,
		height = 500,
		scale = 1,
	}
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "MovableFrame",
		name = "TSMCraftingTradeSkillFrame",
		movableDefaults = frameDefaults,
		minResize = {400, 400},
		scripts = {"OnHide"},
		children = {
			{
				type = "Text",
				text = format("TSM_Crafting - %s", strfind(TSM._version, "@") and "Dev" or TSM._version),
				textFont = {TSMAPI.Design:GetContentFont(), 18},
				points = {{"TOP", 0, -3}},
			},
			{
				type = "HLine",
				offset = -24,
			},
			{
				type = "VLine",
				offset = 0,
				size = {2, 25},
				points = {{"TOPRIGHT", -25, -1}},
			},
			{
				type = "Button",
				key = "closeBtn",
				text = "X",
				textHeight = 18,
				size = {19, 19},
				points = {{"TOPRIGHT", -3, -3}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "professionsBtn",
				text = L["Professions"],
				textHeight = 16,
				size = {105, 20},
				points = {{"TOPLEFT", 5, -30}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "groupsBtn",
				text = L["TSM Groups"],
				textHeight = 16,
				size = {105, 0},
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}, {"BOTTOMLEFT", BFC.PREV, "BOTTOMRIGHT", 5, 0}},
				scripts = {"OnClick"},
			},
			{
				type = "VLine",
				offset = 0,
				points = {{"TOPLEFT", 224, -25}, {"BOTTOMLEFT", BFC.PARENT, "TOPLEFT", 224, -55}},
			},
			{
				type = "Button",
				key = "gatherBtn",
				text = L["Gather"],
				textHeight = 16,
				size = {80, 0},
				points = {{"TOPLEFT", "groupsBtn", "TOPRIGHT", 10, 0}, {"BOTTOMLEFT", "groupsBtn", "BOTTOMRIGHT", 10, 0}},
				scripts = {"OnClick"},
			},
			{
				type = "Button",
				key = "queueBtn",
				text = L["Show Queue"],
				textHeight = 16,
				points = {{"TOPLEFT", BFC.PREV, "TOPRIGHT", 5, 0}, {"BOTTOMLEFT", BFC.PREV, "BOTTOMRIGHT", 5, 0}, {"TOPRIGHT", -5, -5}},
				scripts = {"OnClick"},
			},
			{
				type = "HLine",
				offset = -54,
			},
			{
				type = "Frame",
				key = "prompt",
				hidden = true,
				points = "ALL",
				children = {
					{
						type = "Text",
						key = "text",
						text = L["Would you like to automatically create some TradeSkillMaster groups for this profession?"],
						textFont = {TSMAPI.Design:GetContentFont("normal")},
						size = {0, 100},
						points = {{"LEFT", 5, 50}, {"RIGHT", -5, 50}},
					},
					{
						type = "Button",
						key = "yesBtn",
						text = YES,
						textHeight = 16,
						size = {100, 20},
						points = {{"CENTER", -110, 0}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "laterBtn",
						text = L["Ask Later"],
						textHeight = 16,
						size = {100, 20},
						points = {{"CENTER"}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "noBtn",
						text = L["No Thanks"],
						textHeight = 16,
						size = {100, 20},
						points = {{"CENTER", 110, 0}},
						scripts = {"OnClick"},
					},
				},
			},
			{
				type = "Frame",
				key = "cooldowns",
				hidden = true,
				points = "ALL",
				scripts = {"OnMouseDown", "OnMouseUp"},
				children = {
					{
						type = "Text",
						text = L["Below is a list of crafts that have been smartly added. You can configure what crafts are listed here in the \"Cooldowns\" tab of the \"Crafting\" page within the main TSM window. Quest items can be removed through the TSM crafting options.\n\nSimply click on the row in the table below to craft it."],
						textFont = {TSMAPI.Design:GetContentFont("normal")},
						size = {0, 100},
						points = {{"TOPLEFT", 5, -20}, {"TOPRIGHT", -5, -20}},
					},
					{
						type = "ScrollingTableFrame",
						key = "craftST",
						headFontSize = 14,
						stCols = {{name = L["Smart Crafts"], width = 1, align="CENTER"}},
						stDisableSelection = true,
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -10}, {"BOTTOMRIGHT", -5, 40}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "continueBtn",
						text = L["Skip Smart Crafts and Continue to Profession"],
						textHeight = 18,
						size = {0, 30},
						points = {{"BOTTOMLEFT", 5, 5}, {"BOTTOMRIGHT", -5, 5}},
						scripts = {"OnClick"},
					},
				},
			},
			TradeSkill.Professions:GetFrameInfo(),
			TradeSkill.Groups:GetFrameInfo(),
			TradeSkill.Queue:GetFrameInfo(),
		},
		handlers = {
			OnHide = TradeSkill.HideTradeSkill,
			-- navigation button handlers
			closeBtn = {
				OnClick = function(self)
					private.frame:Hide()
				end,
			},
			professionsBtn = {
				OnClick = function(self)
					TradeSkill.Professions:OnButtonClicked(private.frame)
				end,
			},
			groupsBtn = {
				OnClick = function(self)
					TradeSkill.Groups:OnButtonClicked(private.frame)
				end,
			},
			gatherBtn = {
				OnClick = function(self)
					TradeSkill.Gather:OnButtonClicked()
				end,
			},
			queueBtn = {
				OnClick = function(self)
					TradeSkill.Queue:OnButtonClicked(private.frame)
				end,
			},
			-- prompt frame handlers
			prompt = {
				yesBtn = {
					OnClick = function(self)
						TSM.TradeSkillScanner:CreatePresetGroups()
						local playerName = UnitName("player")
						TSM.db.factionrealm.playerProfessions[playerName][TSM:GetCurrentProfessionName()].prompted = true
						TSMAPI.Sync:KeyUpdated(TSM.db.factionrealm.playerProfessions, playerName)
						self:GetParent():Hide()
						private.frame.professionsTab:Show()
					end,
				},
				laterBtn = {
					OnClick = function(self)
						self:GetParent():Hide()
						private.frame.professionsTab:Show()
					end,
				},
				noBtn = {
					OnClick = function(self)
						local playerName = UnitName("player")
						TSM.db.factionrealm.playerProfessions[playerName][TSM:GetCurrentProfessionName()].prompted = true
						TSMAPI.Sync:KeyUpdated(TSM.db.factionrealm.playerProfessions, playerName)
						self:GetParent():Hide()
						private.frame.professionsTab:Show()
					end,
				},
			},
			-- cooldown frame handlers
			cooldowns = {
				OnMouseDown = function(self)
					self:GetParent():StartMoving()
				end,
				OnMouseUp = function(self)
					self:GetParent():StopMovingOrSizing()
				end,
				continueBtn = {
					OnClick = function(self)
						self:GetParent():Hide()
						private.frame.professionsTab:Show()
						TradeSkill.Queue:UpdateFrameStatus(private.frame)
					end,
				},
				craftST = {
					OnClick = function(self, data, _, button)
						TradeSkill:CastTradeSkill(data.index, data.quantity)
					end,
				},
			},
		},
	}
	local frame = TSMAPI.GUI:BuildFrame(frameInfo)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	tinsert(UISpecialFrames, "TSMCraftingTradeSkillFrame")
	private.frame = frame

	-- prompt frame
	frame.prompt:EnableMouse(true)
	frame.prompt:SetFrameStrata("HIGH")
	TSMAPI.Design:SetFrameBackdropColor(frame.prompt)

	-- cooldowns frame
	frame.cooldowns:EnableMouse(true)
	frame.cooldowns:SetFrameStrata("HIGH")
	TSMAPI.Design:SetFrameBackdropColor(frame.cooldowns)

	-- queue frame
	frame.queue:EnableMouse(true)
	TSMAPI.Design:SetFrameBackdropColor(frame.queue)

	-- professions tab
	TSMAPI.Design:SetFrameColor(frame.professionsTab.craftInfoFrame)
end

function TradeSkill:ToggleHelpPlate(frame, info, btn, isUser)
	if not HelpPlate_IsShowing(info) then
		HelpPlate:SetParent(frame)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Show(info, frame, btn, isUser)
	else
		HelpPlate:SetParent(UIParent)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Hide(isUser)
	end
end

function private:CreateSwitchButton()
	if private.switchBtn then return end
	local frameInfo = {
		type = "Button",
		parent = UIParent,
		text = "",
		textHeight = 16,
		scripts = {"OnClick"},
		handlers = {
			OnClick = function(self)
				private.noHide = true
				if TSM.db.global.showingDefaultFrame then
					TSM.db.global.showingDefaultFrame = nil
					TradeSkill:EventHandler("TRADE_SKILL_SHOW")
				else
					TSM.db.global.showingDefaultFrame = true
					ShowUIPanel(TradeSkillFrame)
					private.frame:Hide()
				end
				private.noHide = nil
				self:Update()
			end,
		},
	}

	local btn = TSMAPI.GUI:BuildFrame(frameInfo)
	btn:Hide()
	-- can't specify an OnShow handler on a button built via TSMAPI.GUI:BuildFrame(), so let's hook it
	TradeSkill:HookScript(btn, "OnShow", function() btn:Update() end)
	btn.Update = function(self)
		if TSM.db.global.showingDefaultFrame then
			self:ClearAllPoints()
			self:SetParent(TradeSkillFrame)
			self:SetPoint("TOPLEFT", 55, -3)
			self:SetWidth(60)
			self:SetHeight(18)
			self:SetText(TSMAPI.Design:GetInlineColor("link").."TSM|r")
		else
			if not TradeSkill:GetVisibilityInfo().frame then
				TSMAPI.Delay:AfterFrame("craftingSwitchBtn", 2, function() self:Update() end)
				return
			end
			self:ClearAllPoints()
			self:SetParent(private.frame)
			self:SetPoint("TOPLEFT", 25, -4)
			self:SetWidth(60)
			self:SetHeight(18)
			self:SetText("|cffff0000"..DEFAULT.."|r")
		end
		self:Show()
	end
	private.switchBtn = btn
end

function private:UpdateCooldownsFrame()
	if not private.frame.cooldowns:IsVisible() then return end
	local potentialCrafts = {}
	local stData = {}
	local currentPlayer = UnitName("player")

	if TSM.db.global.questSmartCrafting then
		local numEntries, numQuests = GetNumQuestLogEntries()

		for q = 1, numEntries do
			local title, level, suggestedGroup, isHeader = GetQuestLogTitle(q)
			if not isHeader then
				for l = 1, GetNumQuestLeaderBoards(q) do
					local text, type, finished = GetQuestLogLeaderBoard(l,q)

					if not finished and type == "item" then
						local have, need, item = string.match(text,"(%d+)/(%d+) (.+)")

						if have ~= nil and need ~= nil and item ~= nil then
							if need - have > 0 then
								tinsert(potentialCrafts, { need = need - have, item = item })
							end
						end
					end
				end
			end
		end
	end

	for i=1, GetNumTradeSkills() do
		local name, _, numAvailable = GetTradeSkillInfo(i)
		local spellID = TSM:GetSpellID(i)
		local craft = spellID and TSM.db.factionrealm.crafts[spellID]
		local cooldown, hasCD = GetTradeSkillCooldown(i)
		if not cooldown and hasCD and craft and craft.cooldownTimes and craft.cooldownTimes[currentPlayer] and craft.cooldownTimes[currentPlayer].prompt then
			if numAvailable > 0 then
				tinsert(stData, {cols={{value="|cff00ff00"..name.."|r"}}, index=i, quantity = 1})
				numAvailable = numAvailable - 1
			else
				-- we don't have the mats on-hand, so add it to the queue
				TSM.Queue:SetNumQueued(spellID, 1)
			end
		end

		local totalNeeded = 0
		for _,pc in pairs(potentialCrafts) do
			if pc.item == name then
				totalNeeded = totalNeeded + pc.need
			end
		end

		if totalNeeded > 0 then
			local spellID = TSM:GetSpellID(i)

			if numAvailable >= totalNeeded then
				tinsert(stData, {cols={{value=format("|cff00ff00%s|r%s",name,totalNeeded == 1 and '' or ' ('..tostring(totalNeeded)..')') }}, index=i, quantity = totalNeeded})
			else
				TSM.Queue:SetNumQueued(spellID, totalNeeded)
			end
		end
	end

	private.frame.cooldowns.craftST:SetData(stData)
	if #stData == 0 then
		private.frame.cooldowns:Hide()
		private.frame.professionsTab:Show()
		TradeSkill.Queue:UpdateFrameStatus(private.frame)
	else
		private.frame.queue:Hide()
	end
end



-- ============================================================================
-- TradeSkill Show / Hide Functions
-- ============================================================================

function private.ShowProfessionWindowThread(self)
	self:SetThreadName("SHOW_PROFESSION_WINDOW")
	-- wait for the the trade skill to load
	private.currentProfession = nil
	while not TradeSkillFrame or not GetNumTradeSkills() or TSM:GetCurrentProfessionName() == "UNKNOWN" or InCombatLockdown() do self:Yield(true) end

	-- hide our frame if it's currently visible
	if TradeSkill:GetVisibilityInfo().frame then
		private.noHide = true
		private.frame:Hide()
		private.noHide = nil
	end
	
	-- create the switch button if it doesn't exist and then show it
	private:CreateSwitchButton()
	private.switchBtn:Show()
		
	-- check if we it's runeforging or a guild profession
	local isLinked, linkedPlayer = IsTradeSkillLinked()
	if TSM:GetCurrentProfessionName() == GetSpellInfo(53428) or IsTradeSkillGuild() or (isLinked and (not TSMAPI.Player:GetCharacters()[linkedPlayer] or IsNPCCrafting())) then
		-- don't show the TSM_Crafting frame
		TSM:LOG_INFO("Aborting for unsupported profession (isRuneforging=%s, isGuild=%s, linkedPlayer=%s)", TSM:GetCurrentProfessionName() == GetSpellInfo(53428), IsTradeSkillGuild(), tostring(linkedPlayer))
		private.switchBtn:Hide()
		private.noShow = nil
		return
	end

	-- if we are showing the default frame then return here
	if TSM.db.global.showingDefaultFrame then
		TSM:LOG_INFO("Showing default frame")
		private.noShow = nil
		return
	end

	-- we will be showing our crafting frame, so hide Blizzard's
	TradeSkillFrame:SetScript("OnHide", nil)
	HideUIPanel(TradeSkillFrame)
	TradeSkillFrame:SetScript("OnHide", TradeSkill.HideTradeSkill)

	-- clear filters and then wait for the profession to fully load
	TradeSkill:ClearFilters()
	while TradeSkillCollapseAllButton.collapsed do TradeSkill:ClearFilters() self:Yield(true) end
	while TSM:GetCurrentProfessionName() == "UNKNOWN" or GetNumTradeSkills() <= 0 do self:Yield(true) end

	-- scan profession
	local playerName = linkedPlayer or UnitName("player")
	local professionName = TSM:GetCurrentProfessionName()
	local scanSuccess = nil
	local scanThreadId = TSM.TradeSkillScanner:ScanProfession(professionName, playerName, isLinked, function() scanSuccess = true end)
	self:WaitForThread(scanThreadId)
	TSM:LOG_INFO("TradeSkill scanned (success=%s)", tostring(scanSuccess))
	if not scanSuccess and not private.noShow then
		TSM:Print(L["Crafting failed to scan your profession. Please close and re-open it to to allow Crafting to scan and provide pricing info for this profession."])
	end

	if private.noShow then
		TradeSkill.HideTradeSkill(TradeSkillFrame)
		private.noShow = nil
		return
	end

	private.currentProfession = professionName
	-- create GUI if it doesn't exist
	private:Create()
	-- open GUI to the profession tab
	private.frame:Show()
	private.frame.professionsBtn:Enable()
	TradeSkill.Queue:UpdateFrameStatus(private.frame)
	if not isLinked and TSM.db.factionrealm.playerProfessions[playerName][professionName] and not TSM.db.factionrealm.playerProfessions[playerName][professionName].prompted then
		private.frame.prompt:Show()
	else
		-- show the cooldowns frame first, the profession frame will show automatically if there's no CD crafts to prompt for
		private.frame.cooldowns:Show()
		private:UpdateCooldownsFrame()
	end
	private.switchBtn:Update()
end

function private.ShowProfessionWindowNoProfessionThread(self)
	self:SetThreadName("SHOW_PROFESSION_WINDOW_NONE")
	private.currentProfession = nil

	-- hide the switch button since there's no actual profession being shown
	if private.switchBtn then
		private.switchBtn:Hide()
	end

	local playerName = UnitName("player")
	if not TSM.db.factionrealm.playerProfessions[playerName] then
		TSMAPI.Sync:SetKeyValue(TSM.db.factionrealm.playerProfessions, playerName, {})
	end
	private.currentProfession = "UNKNOWN"

	-- create GUI if it doesn't exist
	private:Create()
	-- open GUI to the groups tab
	private.frame:Show()
	private.frame.professionsBtn:Disable()
	private.frame.groupsTab:Show()
	TradeSkill.Queue:UpdateFrameStatus(private.frame)
end

function private.OnShowThreadDone()
	TSMAPI.Threading:Kill(private.showThreadId)
	private.showThreadId = nil
end

function TradeSkill.HideTradeSkill(source)
	if private.noHide then return end
	if source == TSMCraftingTradeSkillFrame then
		Lib_CloseDropDownMenus()
		private.frame:Hide()
		if TradeSkillFrame then
			TradeSkillFrame:Show()
			TradeSkillFrame:Hide()
		end
	elseif source == "EVENT" then
		if not private.frame or not private.frame:IsVisible() then return end
		private.frame:Hide()
	elseif source == TradeSkillFrame then
		CloseTradeSkill()
		C_Garrison.CloseGarrisonTradeskillNPC()
	else
		TSMAPI:Assert(false, "Window was hidden from an unexpected source: "..tostring(source))
	end
end



-- ============================================================================
-- TradeSkill Action Functions
-- ============================================================================

function private:OnProfessionUpdate()
	TSMAPI.Delay:AfterFrame("craftingProfessionUpdateThrottle", 5, TradeSkill.Professions.UpdateST)
	TSMAPI.Delay:AfterFrame("craftingQueueUpdateThrottle", 5, TradeSkill.Queue.Update)
end

function TradeSkill:ClearFilters()
	Lib_CloseDropDownMenus()
	local id = TradeSkillLinkDropDown:GetID()
	local skillupButton = _G["DropDownList" .. id .. "Button1"]
	if skillupButton and skillupButton.checked and skillupButton.value == CRAFT_IS_MAKEABLE then
		UIDropDownMenuButton_OnClick(skillupButton)
	end
	local makeableButton = _G["DropDownList" .. id .. "Button2"]
	if makeableButton and makeableButton.checked and makeableButton.value == TRADESKILL_FILTER_HAS_SKILL_UP then
		UIDropDownMenuButton_OnClick(makeableButton)
	end
	TradeSkillOnlyShowMakeable(false)
	TradeSkillOnlyShowSkillUps(false)
	TradeSkillSetFilter(-1, -1)
	SetTradeSkillItemNameFilter("")
	if TradeSkillCollapseAllButton.collapsed then
		TradeSkillCollapseAllButton:Click()
	end
	ExpandTradeSkillSubClass(0)
	TradeSkillFrame_Update()
	if private.frame then
		-- reset the search bar
		private.frame.professionsTab.searchBar:SetTextColor(1, 1, 1, 0.5)
		private.frame.professionsTab.searchBar:ClearFocus()
		private.frame.professionsTab.searchBar:SetText(SEARCH)
	end
end

function TradeSkill:CastTradeSkill(index, quantity, vellum)
	SelectTradeSkill(index)
	quantity = vellum and 1 or quantity
	DoTradeSkill(index, quantity)
	TradeSkill.isCrafting = {quantity=quantity, spellID=TSM:GetSpellID(index)}
	if vellum then
		UseItemByName(vellum)
	end
end

function TradeSkill:OpenFirstProfession()
	local playerName = UnitName("player")
	if not playerName then return end
	local secondaryProfession
	if TSM.db.factionrealm.playerProfessions[playerName] then
		for profession, data in pairs(TSM.db.factionrealm.playerProfessions[playerName]) do
			if data.isSecondary then
				secondaryProfession = profession
			else
				CastSpellByName(profession)
				return
			end
		end
	end
	if secondaryProfession then
		CastSpellByName(secondaryProfession)
		return
	end
	-- they don't have any professions
	private.OnShowThreadDone()
	private.showThreadId = TSMAPI.Threading:Start(private.ShowProfessionWindowNoProfessionThread, 0.8, private.OnShowThreadDone)
end


function private.LinkedProfessionScanThread(self)
	self:SetThreadName("CRAFTING_LINKED_PROFESSION_SCAN")
	self:Sleep(5)

	local accountPlayers = TSMAPI.Player:GetCharacters(true)
	local scanInfo = {}
	while true do
		for playerName, professions in pairs(TSM.db.factionrealm.playerProfessions) do
			local connectedPlayer, lastUpdate = TSMAPI.Sync:GetStatus(TSM.db.factionrealm.playerProfessions, playerName)
			if not accountPlayers[playerName] and connectedPlayer == playerName then
				for professionName, data in pairs(professions) do
					if data.link then
						if scanInfo[data.link] then
							scanInfo[data.link].hasUpdate = lastUpdate ~= scanInfo[data.link].lastUpdate
							scanInfo[data.link].lastUpdate = lastUpdate
						else
							scanInfo[data.link] = {player=playerName, profession=professionName, hasUpdate=true, lastUpdate=lastUpdate}
						end
					end
				end
			end
		end

		-- wait for a free moment to do the scan
		while (TradeSkillFrame and TradeSkillFrame:IsVisible()) or TradeSkill:GetVisibilityInfo().frame or TSM:GetCurrentProfessionName() ~= "UNKNOWN" or InCombatLockdown() or GetUIPanel("left") or GetUIPanel("doublewide") or GetUIPanel("center") or GetUIPanel("fullscreen") do self:Yield(true) end

		-- show the linked professions
		for link, info in pairs(scanInfo) do
			if info.hasUpdate then
				private.noShow = true
				local tradeString = strsub(select(3, ("|"):split(link)), 2)
				SetItemRef(tradeString, link) -- opens the profession from the link

				while private.noShow do self:Yield(true) end
				TSM:LOG_INFO("Scanned linked profession (%s from %s)!", info.profession, info.player)
				info.hasUpdate = nil
				self:Sleep(1)
			end
		end
		self:Sleep(2)
	end
end