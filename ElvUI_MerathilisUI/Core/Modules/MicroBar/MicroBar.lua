local MER, F, E, L, V, P, G = unpack(ElvUI_MerathilisUI)
local module = MER:GetModule('MER_MicroBar')
local S = MER:GetModule('MER_Skins')
local DT = E:GetModule('DataTexts')

-- Credits: fang2hou - ElvUI_Windtools (and me for the initial idea ^^)
local _G = _G
local collectgarbage = collectgarbage
local date = date
local floor = floor
local format = format
local gsub = gsub
local ipairs = ipairs
local max = max
local min = min
local mod = mod
local pairs = pairs
local select = select
local strfind = strfind
local strjoin = strjoin
local tinsert = tinsert
local tonumber = tonumber
local tostring = tostring
local type = type
local unpack = unpack

local BNGetNumFriends = BNGetNumFriends
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local CreateFromMixins = CreateFromMixins
local GetGameTime = GetGameTime
local GetItemCooldown = GetItemCooldown
local GetItemCount = GetItemCount
local GetItemIcon = GetItemIcon
local GetNumGuildMembers = GetNumGuildMembers
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsInGuild = IsInGuild
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ItemMixin = ItemMixin
local PlayerHasToy = PlayerHasToy
local PlaySound = PlaySound
local RegisterStateDriver = RegisterStateDriver
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local Screenshot = Screenshot
local ShowUIPanel = ShowUIPanel
local ToggleCalendar = ToggleCalendar
local ToggleCharacter = ToggleCharacter
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleSpellBook = ToggleSpellBook
local ToggleTimeManager = ToggleTimeManager
local UnregisterStateDriver = UnregisterStateDriver

local C_BattleNet_GetFriendAccountInfo = C_BattleNet and C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet and C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet and C_BattleNet.GetFriendNumGameAccounts
local C_Covenants_GetActiveCovenantID = C_Covenants and C_Covenants.GetActiveCovenantID
local C_CovenantSanctumUI_GetRenownLevel = C_CovenantSanctumUI and C_CovenantSanctumUI.GetRenownLevel
local C_CVar_GetCVar = C_CVar.GetCVar
local C_CVar_GetCVarBool = C_CVar.GetCVarBool
local C_CVar_SetCVar = C_CVar.SetCVar
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_Garrison_GetCompleteMissions = C_Garrison and C_Garrison.GetCompleteMissions
local C_Timer_NewTicker = C_Timer.NewTicker
local C_ToyBox_IsToyUsable = C_ToyBox and C_ToyBox.IsToyUsable

local FollowerType_8_0 = Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower
local FollowerType_9_0 = Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower

local NUM_PANEL_BUTTONS = 7
local IconString = "|T%s:16:18:0:0:64:64:4:60:7:57"
local LeftButtonIcon = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t"
local RightButtonIcon = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t"
local ScrollButtonIcon = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t"

local friendOnline = gsub(_G.ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", "")
local friendOffline = gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "")

local hearthstones = {
	6948,
	54452,
	64488,
	93672,
	142542,
	162973,
	163045,
	165669,
	165670,
	165802,
	166746,
	166747,
	168907,
	172179,
	188952,
	190237,
	193588,
	200630
}

local hearthstoneAndToyIDList = {
	6948,
	54452,
	64488,
	93672,
	110560,
	140192,
	141605,
	142542,
	162973,
	163045,
	165669,
	165670,
	165802,
	166746,
	166747,
	168907,
	172179,
	180290,
	182773,
	183716,
	184353,
	188952,
	190237,
	193588,
	200630,
	---------------------
	48933,
	87215,
	132517,
	132524,
	151652,
	168807,
	168808,
	172924,
	180817,
	198156
}

local hearthstonesAndToysData
local availableHearthstones

local function AddDoubleLineForItem(itemID, prefix)
	local isRandomHearthstone
	if type(itemID) == "string" then
		if itemID == "RANDOM" then
			isRandomHearthstone = true
			itemID = 6948
		else
			itemID = tonumber(itemID)
		end
	end

	prefix = prefix and prefix .. " " or ""

	local name = hearthstonesAndToysData[tostring(itemID)]
	if not name then
		return
	end

	local texture = GetItemIcon(itemID)
	local icon = format(IconString .. ":255:255:255|t", texture)
	local startTime, duration = GetItemCooldown(itemID)
	local cooldownTime = startTime + duration - GetTime()
	local canUse = cooldownTime <= 0
	local cooldownTimeString
	if not canUse then
		local min = floor(cooldownTime / 60)
		local sec = floor(mod(cooldownTime, 60))
		cooldownTimeString = format("%02d:%02d", min, sec)
	end

	if itemID == 180817 then
		local charge = GetItemCount(itemID, nil, true)
		name = name .. format(" (%d)", charge)
	end

	if isRandomHearthstone then
		name = L["Random Hearthstone"]
	end

	DT.tooltip:AddDoubleLine(prefix .. icon .. " " .. name, canUse and L["Ready"] or cooldownTimeString, 1, 1, 1, canUse and 0 or 1, canUse and 1 or 0, 0)
end

-- Fake DataText for no errors throwed from ElvUI
local VirtualDTEvent = {
	Friends = nil,
	Guild = "GUILD_ROSTER_UPDATE"
}

local VirtualDT = {
	Friends = {
		name = "Friends",
		text = {
			SetFormattedText = E.noop
		}
	},
	System = {
		name = "System"
	},
	Time = {
		name = "Time",
		text = {
			SetFormattedText = E.noop
		}
	},
	Guild = {
		name = "Guild",
		text = {
			SetFormattedText = E.noop,
			SetText = E.noop
		},
		GetScript = function()
			return E.noop
		end,
		IsMouseOver = function()
			return false
		end
	}
}

local ButtonTypes = {
	ACHIEVEMENTS = {
		name = L["Achievements"],
		icon = MER.Media.Icons.barAchievements,
		macro = {
			LeftButton = _G.SLASH_ACHIEVEMENTUI1
		},
		tooltips = {
			L["Achievements"]
		}
	},
	BAGS = {
		name = L["Bags"],
		icon = MER.Media.Icons.barBags,
		click = {
			LeftButton = function()
				_G.ToggleAllBags()
			end
		},
		tooltips = "Bags"
	},
	BLIZZARD_SHOP = {
		name = L["Blizzard Shop"],
		icon = MER.Media.Icons.barBlizzardShop,
		click = {
			LeftButton = function()
				_G.StoreMicroButton:Click()
			end
		},
		tooltips = {
			L["Blizzard Shop"]
		}
	},
	CHARACTER = {
		name = L["Character"],
		icon = MER.Media.Icons.barCharacter,
		click = {
			LeftButton = function()
				if not InCombatLockdown() then
					ToggleCharacter("PaperDollFrame")
				else
					_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				end
			end
		},
		tooltips = {
			L["Character"]
		}
	},
	COLLECTIONS = {
		name = L["Collections"],
		icon = MER.Media.Icons.barCollections,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab1",
			RightButton = "/run CollectionsJournal_LoadUI()\n/click MountJournalSummonRandomFavoriteButton"
		},
		tooltips = {
			L["Collections"],
			"\n",
			LeftButtonIcon .. " " .. L["Show Collections"],
			RightButtonIcon .. " " .. L["Random Favorite Mount"]
		}
	},
	ENCOUNTER_JOURNAL = {
		name = L["Encounter Journal"],
		icon = MER.Media.Icons.barEncounterJournal,
		macro = {
			LeftButton = "/click EJMicroButton",
			RightButton = "/run WeeklyRewards_ShowUI()"
		},
		tooltips = {
			LeftButtonIcon .. " " .. L["Encounter Journal"],
			RightButtonIcon .. " " .. L["Weekly Rewards"]
		}
	},
	FRIENDS = {
		name = L["Friend List"],
		icon = MER.Media.Icons.barFriends,
		click = {
			LeftButton = function()
				if not InCombatLockdown() then
					ToggleFriendsFrame(1)
				else
					_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				end
			end
		},
		additionalText = function()
			local numBNOnlineFriend = select(2, BNGetNumFriends())

			if module and module.db and module.db.friends and module.db.friends.showAllFriends then
				local friendsOnline = C_FriendList_GetNumFriends() or 0
				local totalOnline = friendsOnline + numBNOnlineFriend
				return totalOnline
			end

			local number = C_FriendList_GetNumOnlineFriends() or 0

			for i = 1, numBNOnlineFriend do
				local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
				if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
					local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
					if numGameAccounts and numGameAccounts > 0 then
						for j = 1, numGameAccounts do
							local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, j)
							if gameAccountInfo.clientProgram and gameAccountInfo.clientProgram == "WoW" then
								number = number + 1
							end
						end
					elseif accountInfo.gameAccountInfo.clientProgram == "WoW" then
						number = number + 1
					end
				end
			end

			return number > 0 and number or ""
		end,
		tooltips = "Friends",
		events = {
			"BN_FRIEND_ACCOUNT_ONLINE",
			"BN_FRIEND_ACCOUNT_OFFLINE",
			"BN_FRIEND_INFO_CHANGED",
			"FRIENDLIST_UPDATE",
			"CHAT_MSG_SYSTEM"
		},
		eventHandler = function(button, event, message)
			if event == "CHAT_MSG_SYSTEM" then
				if not (strfind(message, friendOnline) or strfind(message, friendOffline)) then
					return
				end
			end
			button.additionalText:SetFormattedText(button.additionalTextFormat, button.additionalTextFunc())
		end
	},
	GAMEMENU = {
		name = L["Game Menu"],
		icon = MER.Media.Icons.barGameMenu,
		click = {
			LeftButton = function()
				if not InCombatLockdown() then
					-- Open game menu | From ElvUI
					if not _G.GameMenuFrame:IsShown() then
						CloseMenus()
						CloseAllWindows()
						PlaySound(850) --IG_MAINMENU_OPEN
						ShowUIPanel(_G.GameMenuFrame)
					else
						PlaySound(854) --IG_MAINMENU_QUIT
						HideUIPanel(_G.GameMenuFrame)
					end
				else
					_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				end
			end
		},
		tooltips = {
			L["Game Menu"]
		}
	},
	GROUP_FINDER = {
		name = L["Group Finder"],
		icon = MER.Media.Icons.barGroupFinder,
		macro = {
			LeftButton = "/click LFDMicroButton"
		},
		tooltips = {
			L["Group Finder"]
		}
	},
	GUILD = {
		name = L["Guild"],
		icon = MER.Media.Icons.barGuild,
		macro = {
			LeftButton = "/click GuildMicroButton",
			RightButton = "/script if not InCombatLockdown() then if not GuildFrame then GuildFrame_LoadUI() end ToggleFrame(GuildFrame) end"
		},
		additionalText = function()
			return IsInGuild() and select(2, GetNumGuildMembers()) or ""
		end,
		tooltips = "Guild",
		events = {
			"GUILD_ROSTER_UPDATE",
			"PLAYER_GUILD_UPDATE"
		},
		eventHandler = function(button, event, message)
			button.additionalText:SetFormattedText(button.additionalTextFormat, button.additionalTextFunc())
		end,
		notification = true
	},
	HOME = {
		name = L["Home"],
		icon = MER.Media.Icons.barHome,
		item = {},
		tooltips = function(button)
			DT.tooltip:ClearLines()
			DT.tooltip:SetText(L["Home"])
			DT.tooltip:AddLine("\n")
			AddDoubleLineForItem(module.db.home.left, LeftButtonIcon)
			AddDoubleLineForItem(module.db.home.right, RightButtonIcon)
			DT.tooltip:Show()

			button.tooltipsUpdateTimer =
			C_Timer_NewTicker(
				1,
				function()
					DT.tooltip:ClearLines()
					DT.tooltip:SetText(L["Home"])
					DT.tooltip:AddLine("\n")
					AddDoubleLineForItem(module.db.home.left, LeftButtonIcon)
					AddDoubleLineForItem(module.db.home.right, RightButtonIcon)
					DT.tooltip:Show()
				end
			)
		end,
		tooltipsLeave = function(button)
			if button.tooltipsUpdateTimer and button.tooltipsUpdateTimer.Cancel then
				button.tooltipsUpdateTimer:Cancel()
			end
		end
	},
	MISSION_REPORTS = {
		name = L["Mission Reports"],
		icon = MER.Media.Icons.barMissionReports,
		click = {
			LeftButton = function(button)
				DT.RegisteredDataTexts["Missions"].onClick(button)
			end
		},
		additionalText = function()
			local numMissions = #C_Garrison_GetCompleteMissions(FollowerType_9_0) + #C_Garrison_GetCompleteMissions(FollowerType_8_0)
			if numMissions == 0 then
				numMissions = ""
			end
			return numMissions
		end,
		tooltips = "Missions"
	},
	NONE = {
		name = L["None"]
	},
	PET_JOURNAL = {
		name = L["Pet Journal"],
		icon = MER.Media.Icons.barPetJournal,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab2",
			RightButton = "/run CollectionsJournal_LoadUI()\n/click PetJournalSummonRandomFavoritePetButton"
		},
		tooltips = {
			L["Pet Journal"],
			"\n",
			LeftButtonIcon .. " " .. L["Show Pet Journal"],
			RightButtonIcon .. " " .. L["Random Favorite Pet"]
		}
	},
	PROFESSION = {
		name = L["Profession"],
		icon = MER.Media.Icons.barProfession,
		click = {
			LeftButton = function()
				if not InCombatLockdown() then
					ToggleSpellBook(_G.BOOKTYPE_PROFESSION)
				else
					_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				end
			end
		},
		tooltips = {
			L["Profession"]
		}
	},
	SCREENSHOT = {
		name = L["Screenshot"],
		icon = MER.Media.Icons.barScreenShot,
		click = {
			LeftButton = function()
				DT.tooltip:Hide()
				Screenshot()
			end,
			RightButton = function()
				E:Delay(2, Screenshot)
			end
		},
		tooltips = {
			L["Screenshot"],
			"\n",
			LeftButtonIcon .. " " .. L["Screenshot immediately"],
			RightButtonIcon .. " " .. L["Screenshot after 2 secs"]
		}
	},
	SPELLBOOK = {
		name = L["Spell Book"],
		icon = MER.Media.Icons.barSpellBook,
		macro = {
			LeftButton = "/click SpellbookMicroButton"
		},
		tooltips = {
			L["Spell Book"]
		}
	},
	TALENTS = {
		name = L["Talents"],
		icon = MER.Media.Icons.barTalents,
		macro = {
			LeftButton = "/click TalentMicroButton"
		},
		tooltips = {
			L["Talents"]
		}
	},
	TOY_BOX = {
		name = L["Toy Box"],
		icon = MER.Media.Icons.barToyBox,
		macro = {
			LeftButton = "/click CollectionsJournalCloseButton\n/click CollectionsMicroButton\n/click CollectionsJournalTab3"
		},
		tooltips = {
			L["Toy Box"]
		}
	},
	VOLUME = {
		name = L["Volume"],
		icon = MER.Media.Icons.barVolume,
		click = {
			LeftButton = function()
				local vol = C_CVar_GetCVar("Sound_MasterVolume")
				vol = vol and tonumber(vol) or 0
				C_CVar_SetCVar("Sound_MasterVolume", min(vol + 0.1, 1))
			end,
			MiddleButton = function()
				local enabled = tonumber(C_CVar_GetCVar("Sound_EnableAllSound")) == 1
				C_CVar_SetCVar("Sound_EnableAllSound", enabled and 0 or 1)
			end,
			RightButton = function()
				local vol = C_CVar_GetCVar("Sound_MasterVolume")
				vol = vol and tonumber(vol) or 0
				C_CVar_SetCVar("Sound_MasterVolume", max(vol - 0.1, 0))
			end
		},
		tooltips = function(button)
			local vol = C_CVar_GetCVar("Sound_MasterVolume")
			vol = vol and tonumber(vol) or 0
			DT.tooltip:ClearLines()
			DT.tooltip:SetText(L["Volume"] .. format(": %d%%", vol * 100))
			DT.tooltip:AddLine("\n")
			DT.tooltip:AddLine(LeftButtonIcon .. " " .. L["Increase the volume"] .. " (+10%)", 1, 1, 1)
			DT.tooltip:AddLine(RightButtonIcon .. " " .. L["Decrease the volume"] .. " (-10%)", 1, 1, 1)
			DT.tooltip:AddLine(ScrollButtonIcon .. " " .. L["Sound ON/OFF"], 1, 1, 1)
			DT.tooltip:Show()

			button.tooltipsUpdateTimer = C_Timer_NewTicker(0.3, function()
				local vol = C_CVar_GetCVar("Sound_MasterVolume")
				vol = vol and tonumber(vol) or 0
				DT.tooltip:ClearLines()
				DT.tooltip:SetText(L["Volume"] .. format(": %d%%", vol * 100))
				DT.tooltip:AddLine("\n")
				DT.tooltip:AddLine(LeftButtonIcon .. " " .. L["Increase the volume"] .. " (+10%)", 1, 1, 1)
				DT.tooltip:AddLine(RightButtonIcon .. " " .. L["Decrease the volume"] .. " (-10%)", 1, 1, 1)
				DT.tooltip:AddLine(ScrollButtonIcon .. " " .. L["Sound ON/OFF"], 1, 1, 1)
				DT.tooltip:Show()
			end)
		end,
		tooltipsLeave = function(button)
			if button.tooltipsUpdateTimer and button.tooltipsUpdateTimer.Cancel then
				button.tooltipsUpdateTimer:Cancel()
			end
		end
	}
}

function module:ShowAdvancedTimeTooltip(panel)
	DT.RegisteredDataTexts["Time"].onEnter()
	DT.RegisteredDataTexts["Time"].onLeave()
	-- DT.tooltip:ClearLines()
	-- DT.tooltip:SetText(L["Time"])
	-- DT.tooltip:AddLine("\n", 1, 1, 1)
	-- DT.tooltip:AddLine(LeftButtonIcon .. " " .. L["Calendar"], 1, 1, 1)
	-- DT.tooltip:AddLine(RightButtonIcon .. " " .. L["Time Manager"], 1, 1, 1)
	-- DT.tooltip:AddLine("\n")
	-- DT.tooltip:AddLine(L["(Modifer Click) Collect Garbage"], unpack(E.media.rgbvaluecolor))
	-- DT.tooltip:Show()
end

function module:ConstructBar()
	if self.bar then
		return
	end

	local bar = CreateFrame("Frame", "MER_MicroBar", E.UIParent)
	bar:SetSize(800, 60)
	bar:SetPoint("TOP", 0, -20)
	bar:SetFrameStrata("MEDIUM")

	bar:SetScript("OnEnter", function(bar)
		if self.db and self.db.mouseOver then
			E:UIFrameFadeIn(bar, self.db.fadeTime, bar:GetAlpha(), 1)
		end
	end)

	bar:SetScript("OnLeave", function(bar)
		if self.db and self.db.mouseOver then
			E:UIFrameFadeOut(bar, self.db.fadeTime, bar:GetAlpha(), 0)
		end
	end)

	local middlePanel = CreateFrame("Button", "MicroBarMiddlePanel", bar, "SecureActionButtonTemplate")
	middlePanel:SetSize(81, 50)
	middlePanel:SetPoint("CENTER")
	middlePanel:CreateBackdrop("Transparent")
	middlePanel.backdrop:Styling()
	middlePanel:RegisterForClicks(MER.UseKeyDown and "AnyDown" or "AnyUp")
	bar.middlePanel = middlePanel

	local leftPanel = CreateFrame("Frame", "MicroBarLeftPanel", bar)
	leftPanel:SetSize(300, 40)
	leftPanel:SetPoint("RIGHT", middlePanel, "LEFT", -10, 0)
	leftPanel:CreateBackdrop("Transparent")
	leftPanel.backdrop:Styling()
	bar.leftPanel = leftPanel

	local rightPanel = CreateFrame("Frame", "MicroBarRightPanel", bar)
	rightPanel:SetSize(300, 40)
	rightPanel:SetPoint("LEFT", middlePanel, "RIGHT", 10, 0)
	rightPanel:CreateBackdrop("Transparent")
	rightPanel.backdrop:Styling()
	bar.rightPanel = rightPanel

	S:CreateShadowModule(leftPanel.backdrop)
	S:CreateShadowModule(middlePanel.backdrop)
	S:CreateShadowModule(rightPanel.backdrop)

	self.bar = bar

	E:CreateMover(self.bar, "MicroBarAnchor", L["MicroBar"], nil, nil, nil, "ALL,MERATHILISUI", function() return module.db and module.db.enable end, "mui,modules,microBar,general")
end

function module:UpdateBar()
	if self.db and self.db.mouseOver then
		self.bar:SetAlpha(0)
	else
		self.bar:SetAlpha(1)
	end

	RegisterStateDriver(self.bar, "visibility", self.db.visibility)
end

function module:ConstructTimeArea()
	local colon = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(colon, self.db.time.font)
	colon:SetPoint("CENTER")
	self.bar.middlePanel.colon = colon

	local hour = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(hour, self.db.time.font)
	hour:SetPoint("RIGHT", colon, "LEFT", 1, 0)
	self.bar.middlePanel.hour = hour

	local hourHover = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(hourHover, self.db.time.font)
	hourHover:SetPoint("RIGHT", colon, "LEFT", 1, 0)
	hourHover:SetAlpha(0)
	self.bar.middlePanel.hourHover = hourHover

	local minutes = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(minutes, self.db.time.font)
	minutes:SetPoint("LEFT", colon, "RIGHT", 0, 0)
	self.bar.middlePanel.minutes = minutes

	local minutesHover = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(minutesHover, self.db.time.font)
	minutesHover:SetPoint("LEFT", colon, "RIGHT", 0, 0)
	minutesHover:SetAlpha(0)
	self.bar.middlePanel.minutesHover = minutesHover

	local text = self.bar.middlePanel:CreateFontString(nil, "OVERLAY")
	F.SetFontDB(text, self.db.additionalText.font)
	text:SetPoint("TOP", self.bar, "BOTTOM", 0, -5)
	text:SetAlpha(self.db.time.alwaysSystemInfo and 1 or 0)
	self.bar.middlePanel.text = text

	self.bar.middlePanel:SetSize(self.db.timeAreaWidth, self.db.timeAreaHeight)

	self:UpdateTimeFormat()
	self:UpdateTime()
	self.timeAreaUpdateTimer = C_Timer_NewTicker(self.db.time.interval, function() module:UpdateTime() end)

	DT.RegisteredDataTexts["System"].onUpdate(self.bar.middlePanel, 10)

	if self.db.time.alwaysSystemInfo then
		self.alwaysSystemInfoTimer = C_Timer_NewTicker(1, function()
			DT.RegisteredDataTexts["System"].onUpdate(self.bar.middlePanel, 10)
		end)
	end

	self:HookScript(self.bar.middlePanel, "OnEnter", function(panel)
		if self.db and self.db.mouseOver then
			E:UIFrameFadeIn(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 1)
		end

		DT.RegisteredDataTexts["System"].onUpdate(panel, 10)

		E:UIFrameFadeIn(panel.hourHover, self.db.fadeTime, panel.hourHover:GetAlpha(), 1)
		E:UIFrameFadeIn(panel.minutesHover, self.db.fadeTime, panel.minutesHover:GetAlpha(), 1)

		if not self.db.time.alwaysSystemInfo then
			E:UIFrameFadeIn(panel.text, self.db.fadeTime, panel.text:GetAlpha(), 1)
		end

		if self.db.tooltipsAnchor == "ANCHOR_TOP" then
			DT.tooltip:SetOwner(panel, "ANCHOR_TOP", 0, 10)
		else
			DT.tooltip:SetOwner(panel.text, "ANCHOR_BOTTOM", 0, -10)
		end

		if IsModifierKeyDown() then
			DT.RegisteredDataTexts["System"].eventFunc()
			DT.RegisteredDataTexts["System"].onEnter()
			self.tooltipTimer = C_Timer_NewTicker(1, function()
				DT.RegisteredDataTexts["System"].onUpdate(panel, 10)
				DT.RegisteredDataTexts["System"].eventFunc()
				DT.RegisteredDataTexts["System"].onEnter()
			end)
		else
			self:ShowAdvancedTimeTooltip(panel)
			self.tooltipTimer = C_Timer_NewTicker(1, function()
				DT.RegisteredDataTexts["System"].onUpdate(panel, 10)
			end)
		end
	end)

	self:HookScript(self.bar.middlePanel, "OnLeave", function(panel)
		if self.db and self.db.mouseOver then
			E:UIFrameFadeOut(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 0)
		end
		E:UIFrameFadeOut(panel.hourHover, self.db.fadeTime, panel.hourHover:GetAlpha(), 0)
		E:UIFrameFadeOut(panel.minutesHover, self.db.fadeTime, panel.minutesHover:GetAlpha(), 0)
		if not self.db.time.alwaysSystemInfo then
			E:UIFrameFadeOut(panel.text, self.db.fadeTime, panel.text:GetAlpha(), 0)
		end

		DT.RegisteredDataTexts["System"].onLeave()
		DT.tooltip:Hide()
		self.tooltipTimer:Cancel()
	end)

	self.bar.middlePanel:SetScript("OnClick", function(_, mouseButton)
		if IsShiftKeyDown() then
			if IsControlKeyDown() then
				C_CVar_SetCVar("scriptProfile", C_CVar_GetCVarBool("scriptProfile") and 0 or 1)
				ReloadUI()
			else
				collectgarbage("collect")
				ResetCPUUsage()
				DT.RegisteredDataTexts["System"].eventFunc()
				DT.RegisteredDataTexts["System"].onEnter()
			end
		elseif mouseButton == "LeftButton" then
			if not InCombatLockdown() then
				ToggleCalendar()
			else
				_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			end
		elseif mouseButton == "RightButton" then
			ToggleTimeManager()
		end
	end)
end

function module:UpdateTimeTicker()
	self.timeAreaUpdateTimer:Cancel()
	self.timeAreaUpdateTimer = C_Timer_NewTicker(self.db.time.interval, function()
		module:UpdateTime()
	end)
end

function module:UpdateTimeFormat()
	local normalColor = { r = 1, g = 1, b = 1 }
	local hoverColor = { r = 1, g = 1, b = 1 }

	if self.db.normalColor == "CUSTOM" then
		normalColor = self.db.customNormalColor
	elseif self.db.normalColor == "CLASS" then
		normalColor = E:ClassColor(E.myclass, true)
	elseif self.db.normalColor == "VALUE" then
		normalColor = {
			r = E.media.rgbvaluecolor[1],
			g = E.media.rgbvaluecolor[2],
			b = E.media.rgbvaluecolor[3]
		}
	end

	if self.db.hoverColor == "CUSTOM" then
		hoverColor = self.db.customHoverColor
	elseif self.db.hoverColor == "CLASS" then
		hoverColor = E:ClassColor(E.myclass, true)
	elseif self.db.hoverColor == "VALUE" then
		hoverColor = {
			r = E.media.rgbvaluecolor[1],
			g = E.media.rgbvaluecolor[2],
			b = E.media.rgbvaluecolor[3]
		}
	end

	self.bar.middlePanel.hour.format = F.CreateColorString("%s", normalColor)
	self.bar.middlePanel.hourHover.format = F.CreateColorString("%s", hoverColor)
	self.bar.middlePanel.minutes.format = F.CreateColorString("%s", normalColor)
	self.bar.middlePanel.minutesHover.format = F.CreateColorString("%s", hoverColor)
	self.bar.middlePanel.colon:SetText(F.CreateColorString(":", hoverColor))
end

function module:UpdateTime()
	local panel = self.bar.middlePanel
	if not panel or not self.db then
		return
	end

	local hour, min

	if self.db.time then
		if self.db.time.localTime then
			hour = self.db.time.twentyFour and date("%H") or date("%I")
			min = date("%M")
		else
			hour, min = GetGameTime()
			hour = self.db.time.twentyFour and hour or mod(hour, 12)
			hour = format("%02d", hour)
			min = format("%02d", min)
		end
	else
		return
	end

	panel.hour:SetFormattedText(panel.hour.format, hour)
	panel.hourHover:SetFormattedText(panel.hourHover.format, hour)
	panel.minutes:SetFormattedText(panel.minutes.format, min)
	panel.minutesHover:SetFormattedText(panel.minutesHover.format, min)

	panel.colon:ClearAllPoints()
	local offset = (panel.hour:GetStringWidth() - panel.minutes:GetStringWidth()) / 2
	panel.colon:SetPoint("CENTER", offset, -1)
end

function module:UpdateTimeArea()
	local panel = self.bar.middlePanel

	F.SetFontDB(panel.hour, self.db.time.font)
	F.SetFontDB(panel.hourHover, self.db.time.font)
	F.SetFontDB(panel.minutes, self.db.time.font)
	F.SetFontDB(panel.minutesHover, self.db.time.font)
	F.SetFontDB(panel.colon, self.db.time.font)
	F.SetFontDB(panel.text, self.db.additionalText.font)

	if self.db.time.flash then
		E:Flash(panel.colon, 1, true)
	else
		E:StopFlash(panel.colon)
	end

	if self.db.time.alwaysSystemInfo then
		DT.RegisteredDataTexts["System"].onUpdate(panel, 10)
		panel.text:SetAlpha(1)
		if not self.alwaysSystemInfoTimer or self.alwaysSystemInfoTimer:IsCancelled() then
			self.alwaysSystemInfoTimer = C_Timer_NewTicker(1, function()
				DT.RegisteredDataTexts["System"].onUpdate(panel, 10)
			end)
		end
	else
		panel.text:SetAlpha(0)
		if self.alwaysSystemInfoTimer and not self.alwaysSystemInfoTimer:IsCancelled() then
			self.alwaysSystemInfoTimer:Cancel()
		end
	end

	self:UpdateTime()
end

function module:ButtonOnEnter(button)
	if self.db and self.db.mouseOver then
		E:UIFrameFadeIn(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 1)
	end
	E:UIFrameFadeIn(button.hoverTex, self.db.fadeTime, button.hoverTex:GetAlpha(), 1)
	if button.tooltips then
		if self.db.tooltipsAnchor == "ANCHOR_TOP" then
			DT.tooltip:SetOwner(button, "ANCHOR_TOP", 0, 20)
		else
			DT.tooltip:SetOwner(button, "ANCHOR_BOTTOM", 0, -10)
		end

		if type(button.tooltips) == "table" then
			DT.tooltip:ClearLines()
			for index, line in ipairs(button.tooltips) do
				if index == 1 then
					DT.tooltip:SetText(line)
				else
					DT.tooltip:AddLine(line, 1, 1, 1)
				end
			end
			DT.tooltip:Show()
		elseif type(button.tooltips) == "string" then
			local DTModule = DT.RegisteredDataTexts[button.tooltips]

			if VirtualDT[button.tooltips] and DTModule.eventFunc then
				DTModule.eventFunc(VirtualDT[button.tooltips], VirtualDTEvent[button.tooltips])
			end

			if DTModule and DTModule.onEnter then
				DTModule.onEnter()
			end

			-- If ElvUI Datatext tooltip not shown, display a simple information (e.g. button name) to player
			if not DT.tooltip:IsShown() then
				DT.tooltip:ClearLines()
				DT.tooltip:SetText(button.name)
				DT.tooltip:Show()
			end
		elseif type(button.tooltips) == "function" then
			button.tooltips(button)
		end
	end
end

function module:ButtonOnLeave(button)
	if self.db and self.db.mouseOver then
		E:UIFrameFadeOut(self.bar, self.db.fadeTime, self.bar:GetAlpha(), 0)
	end
	E:UIFrameFadeOut(button.hoverTex, self.db.fadeTime, button.hoverTex:GetAlpha(), 0)
	DT.tooltip:Hide()
	if button.tooltipsLeave then
		button.tooltipsLeave(button)
	end
end

function module:ConstructButton()
	if not self.bar then
		return
	end

	local button = CreateFrame("Button", nil, self.bar, "SecureActionButtonTemplate")
	button:SetSize(self.db.buttonSize, self.db.buttonSize)
	button:RegisterForClicks(MER.UseKeyDown and "AnyDown" or "AnyUp")

	local normalTex = button:CreateTexture(nil, "ARTWORK")
	normalTex:SetPoint("CENTER")
	normalTex:SetSize(self.db.buttonSize, self.db.buttonSize)
	button.normalTex = normalTex

	local hoverTex = button:CreateTexture(nil, "ARTWORK")
	hoverTex:SetPoint("CENTER")
	hoverTex:SetSize(self.db.buttonSize, self.db.buttonSize)
	hoverTex:SetAlpha(0)
	button.hoverTex = hoverTex

	local notificationTex = button:CreateTexture(nil, "OVERLAY")
	notificationTex:SetTexture(MER.Media.Icons.barNotification)
	notificationTex:SetPoint("TOPRIGHT")
	notificationTex:SetSize(0.38 * self.db.buttonSize, 0.38 * self.db.buttonSize)
	button.notificationTex = notificationTex

	local additionalText = button:CreateFontString(nil, "OVERLAY")
	additionalText:SetPoint(self.db.additionalText.anchor, self.db.additionalText.x, self.db.additionalText.y)
	F.SetFontDB(additionalText, self.db.additionalText.font)
	additionalText:SetJustifyH("CENTER")
	additionalText:SetJustifyV("CENTER")
	button.additionalText = additionalText

	self:HookScript(button, "OnEnter", "ButtonOnEnter")
	self:HookScript(button, "OnLeave", "ButtonOnLeave")

	tinsert(self.buttons, button)
end

function module:UpdateButton(button, buttonType)
	if InCombatLockdown() then
		return
	end

	local config = ButtonTypes[buttonType]
	button:SetSize(self.db.buttonSize, self.db.buttonSize)
	button.type = buttonType
	button.name = config.name
	button.tooltips = config.tooltips
	button.tooltipsLeave = config.tooltipsLeave

	-- Click
	if buttonType == "HOME" and
		(config.item.item1 == L["Random Hearthstone"] or config.item.item2 == L["Random Hearthstone"])
	then
		button:SetAttribute("type*", "macro")
		self:HandleRandomHomeButton(button, "left", config.item.item1)
		self:HandleRandomHomeButton(button, "right", config.item.item2)
	elseif config.macro then
		button:SetAttribute("type*", "macro")
		button:SetAttribute("macrotext1", config.macro.LeftButton or "")
		button:SetAttribute("macrotext2", config.macro.RightButton or config.macro.LeftButton or "")
	elseif config.click then
		function button:Click(mouseButton)
			local func = mouseButton and config.click[mouseButton] or config.click.LeftButton
			func(module.bar.middlePanel)
		end

		button:SetAttribute("type*", "click")
		button:SetAttribute("clickbutton", button)
	elseif config.item then
		button:SetAttribute("type*", "item")
		button:SetAttribute("item1", config.item.item1 or "")
		button:SetAttribute("item2", config.item.item2 or "")
	end

	-- Normal
	local r, g, b = 1, 1, 1
	if self.db.normalColor == "CUSTOM" then
		r = self.db.customNormalColor.r
		g = self.db.customNormalColor.g
		b = self.db.customNormalColor.b
	elseif self.db.normalColor == "CLASS" then
		local classColor = E:ClassColor(E.myclass, true)
		r = classColor.r
		g = classColor.g
		b = classColor.b
	elseif self.db.normalColor == "VALUE" then
		r, g, b = unpack(E.media.rgbvaluecolor)
	end

	button.normalTex:SetTexture(config.icon)
	button.normalTex:SetSize(self.db.buttonSize, self.db.buttonSize)
	button.normalTex:SetVertexColor(r, g, b)

	-- Mouseover
	r, g, b = 1, 1, 1
	if self.db.hoverColor == "CUSTOM" then
		r = self.db.customHoverColor.r
		g = self.db.customHoverColor.g
		b = self.db.customHoverColor.b
	elseif self.db.hoverColor == "CLASS" then
		local classColor = E:ClassColor(E.myclass, true)
		r = classColor.r
		g = classColor.g
		b = classColor.b
	elseif self.db.hoverColor == "VALUE" then
		r, g, b = unpack(E.media.rgbvaluecolor)
	end

	button.hoverTex:SetTexture(config.icon)
	button.hoverTex:SetSize(self.db.buttonSize, self.db.buttonSize)
	button.hoverTex:SetVertexColor(r, g, b)

	-- Additional text
	if button.registeredEvents then
		for _, event in pairs(button.registeredEvents) do
			button:UnregisterEvent(event)
		end
	end

	button:SetScript("OnEvent", nil)
	button.registeredEvents = nil
	button.additionalTextFunc = nil

	if button.additionalTextTimer and not button.additionalTextTimer:IsCancelled() then
		button.additionalTextTimer:Cancel()
	end

	button.additionalTextFormat = F.CreateColorString("%s", { r = r, g = g, b = b })

	if config.additionalText and self.db.additionalText.enable then
		button.additionalText:SetFormattedText( button.additionalTextFormat, config.additionalText and config.additionalText() or "")

		if config.events and config.eventHandler then
			button:SetScript("OnEvent", config.eventHandler)
			button.additionalTextFunc = config.additionalText
			button.registeredEvents = {}
			for _, event in pairs(config.events) do
				button:RegisterEvent(event)
				tinsert(button.registeredEvents, event)
			end
		else
			button.additionalTextTimer = C_Timer_NewTicker(self.db.additionalText.slowMode and 10 or 1, function()
				button.additionalText:SetFormattedText(button.additionalTextFormat, config.additionalText and config.additionalText() or "")
			end)
		end

		button.additionalText:ClearAllPoints()
		button.additionalText:SetPoint(self.db.additionalText.anchor, self.db.additionalText.x, self.db.additionalText.y)
		F.SetFontDB(button.additionalText, self.db.additionalText.font)
		button.additionalText:Show()
	else
		button.additionalText:Hide()
	end

	button.notificationTex:Hide()
	if config.notification then
		if config.notificationColor then
			local c = config.notificationColor
			button.notificationTex:SetVertexColor(c.r, c.g, c.b, c.a)
		else
			button.notificationTex:SetVertexColor(r, g, b, 1)
		end
	end
end

function module:ConstructButtons()
	if self.buttons then
		return
	end

	self.buttons = {}
	for i = 1, NUM_PANEL_BUTTONS * 2 do
		self:ConstructButton()
	end
end

function module:UpdateButtons()
	for i = 1, NUM_PANEL_BUTTONS do
		self:UpdateButton(self.buttons[i], self.db.left[i])
		self:UpdateButton(self.buttons[i + NUM_PANEL_BUTTONS], self.db.right[i])
	end
	self:UpdateGuildButton()
end

function module:UpdateLayout()
	if self.db.backdrop then
		self.bar.leftPanel.backdrop:Show()
		self.bar.middlePanel.backdrop:Show()
		self.bar.rightPanel.backdrop:Show()
	else
		self.bar.leftPanel.backdrop:Hide()
		self.bar.middlePanel.backdrop:Hide()
		self.bar.rightPanel.backdrop:Hide()
	end

	local numLeftButtons, numRightButtons = 0, 0

	local lastButton = nil
	for i = 1, NUM_PANEL_BUTTONS do
		local button = self.buttons[i]
		if button.name ~= L["None"] then
			button:Show()
			button:ClearAllPoints()
			if not lastButton then
				button:SetPoint("LEFT", self.bar.leftPanel, "LEFT", self.db.backdropSpacing, 0)
			else
				button:SetPoint("LEFT", lastButton, "RIGHT", self.db.spacing, 0)
			end
			lastButton = button
			numLeftButtons = numLeftButtons + 1
		else
			button:Hide()
		end
	end

	if numLeftButtons == 0 then
		self.bar.leftPanel:Hide()
	else
		self.bar.leftPanel:Show()
		local panelWidth =
		self.db.backdropSpacing * 2 + (numLeftButtons - 1) * self.db.spacing + numLeftButtons * self.db.buttonSize
		local panelHeight = self.db.backdropSpacing * 2 + self.db.buttonSize
		self.bar.leftPanel:SetSize(panelWidth, panelHeight)
	end

	-- Right Panel
	lastButton = nil
	for i = 1, NUM_PANEL_BUTTONS do
		local button = self.buttons[i + NUM_PANEL_BUTTONS]
		if button.name ~= L["None"] then
			button:Show()
			button:ClearAllPoints()
			if not lastButton then
				button:SetPoint("LEFT", self.bar.rightPanel, "LEFT", self.db.backdropSpacing, 0)
			else
				button:SetPoint("LEFT", lastButton, "RIGHT", self.db.spacing, 0)
			end
			lastButton = button
			numRightButtons = numRightButtons + 1
		else
			button:Hide()
		end
	end

	if numRightButtons == 0 then
		self.bar.rightPanel:Hide()
	else
		self.bar.rightPanel:Show()
		local panelWidth =
		self.db.backdropSpacing * 2 + (numRightButtons - 1) * self.db.spacing + numRightButtons * self.db.buttonSize
		local panelHeight = self.db.backdropSpacing * 2 + self.db.buttonSize
		self.bar.rightPanel:SetSize(panelWidth, panelHeight)
	end

	-- Time Panel
	self.bar.middlePanel:SetSize(self.db.timeAreaWidth, self.db.timeAreaHeight)

	-- Update the size of moveable zones
	local areaWidth = 20 + self.bar.middlePanel:GetWidth()
	local leftWidth = self.bar.leftPanel:IsShown() and self.bar.leftPanel:GetWidth() or 0
	local rightWidth = self.bar.rightPanel:IsShown() and self.bar.rightPanel:GetWidth() or 0
	areaWidth = areaWidth + 2 * max(leftWidth, rightWidth)

	local areaHeight = self.bar.middlePanel:GetHeight()
	local leftHeight = self.bar.leftPanel:IsShown() and self.bar.leftPanel:GetHeight() or 0
	local rightHeight = self.bar.rightPanel:IsShown() and self.bar.rightPanel:GetHeight() or 0
	areaHeight = max(max(leftHeight, rightHeight), areaHeight)

	self.bar:SetSize(areaWidth, areaHeight)
end

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:ProfileUpdate()
end

function module:PLAYER_ENTERING_WORLD()
	E:Delay(1, function()
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:ProfileUpdate()
		end
	end)
end

function module:UpdateReknown()
	local covenantID = C_Covenants_GetActiveCovenantID()
	if not covenantID or covenantID == 0 then
		return
	end

	if not self.covenantCache[E.myrealm] then
		self.covenantCache[E.myrealm] = {}
	end

	if not self.covenantCache[E.myrealm][E.myname] then
		self.covenantCache[E.myrealm][E.myname] = {}
	end

	local renownLevel = C_CovenantSanctumUI_GetRenownLevel()
	if renownLevel then
		self.covenantCache[E.myrealm][E.myname][tostring(covenantID)] = renownLevel
	end
end

function module:Initialize()
	if not E.Retail then
		return
	end

	self.db = E.db.mui.microBar
	self.covenantCache = E.global.mui.microBar.covenantCache

	if not self.db or not self.db.enable then
		return
	end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for name, vDT in pairs(VirtualDT) do
		if DT.RegisteredDataTexts[name] and DT.RegisteredDataTexts[name].applySettings then
			DT.RegisteredDataTexts[name].applySettings(vDT, E.media.hexvaluecolor)
		end
	end

	self:UpdateReknown()
	self:UpdateHearthStoneTable()
	self:ConstructBar()
	self:ConstructTimeArea()
	self:ConstructButtons()
	self:UpdateTimeArea()
	self:UpdateButtons()
	self:UpdateLayout()
	self:UpdateBar()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COVENANT_CHOSEN", function()
		E:Delay(3, function()
			self:UpdateReknown()
			self:UpdateHearthStoneTable()
			self:UpdateBar()
		end)
	end)

	self:SecureHook(_G.GuildMicroButton, "UpdateNotificationIcon", "UpdateGuildButton")
	self.initialized = true
end

function module:ProfileUpdate()
	self.db = E.db.mui.microBar
	if not self.db then
		return
	end

	if self.db.enable then
		if self.initialized then
			self.bar:Show()
			self:UpdateHomeButton()
			self:UpdateTimeFormat()
			self:UpdateTimeArea()
			self:UpdateTime()
			self:UpdateButtons()
			self:UpdateLayout()
			self:UpdateBar()
		else
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				return
			else
				self:Initialize()
			end
		end
	else
		if self.initialized then
			UnregisterStateDriver(self.bar, "visibility")
			self.bar:Hide()
		end
	end
end

function module:UpdateGuildButton()
	if not self.db or not self.db.notification then
		return
	end

	if not _G.GuildMicroButton or not _G.GuildMicroButton.NotificationOverlay then
		return
	end

	local isShown = _G.GuildMicroButton.NotificationOverlay:IsShown()

	for i = 1, 2 * NUM_PANEL_BUTTONS do
		if self.buttons[i].type == "GUILD" then
			self.buttons[i].notificationTex:SetShown(isShown)
		end
	end
end

function module:HandleRandomHomeButton(button, mouseButton, item)
	if not button or not mouseButton or not item or not availableHearthstones then
		return
	end

	local attribute = mouseButton == "right" and "macrotext2" or "macrotext1"
	local macro = "/use " .. item

	if item == L["Random Hearthstone"] then
		if #availableHearthstones > 0 then
			macro = "/castrandom " .. strjoin(",", unpack(availableHearthstones))
		else
			macro = '/run UIErrorsFrame:AddMessage("' .. L["No Hearthstone Found!"] .. '", 1, 0, 0)'
		end
	end

	button:SetAttribute(attribute, macro)
end

function module:UpdateHomeButton()
	ButtonTypes.HOME.item = {
		item1 = hearthstonesAndToysData[self.db.home.left],
		item2 = hearthstonesAndToysData[self.db.home.right]
	}
end

function module:UpdateHearthStoneTable()
	hearthstonesAndToysData = { ["RANDOM"] = L["Random Hearthstone"] }

	local hearthstonesTable = {}
	for i = 1, #hearthstones do
		local itemID = hearthstones[i]
		hearthstonesTable[itemID] = true
	end

	local specialHearthstones = {
		[1] = 184353,
		[2] = 183716,
		[3] = 180290,
		[4] = 182773
	}

	for i = 1, 4 do
		local level = self.covenantCache[E.myrealm] and self.covenantCache[E.myrealm][E.myname] and self.covenantCache[E.myrealm][E.myname][tostring(i)]
		local toyID = specialHearthstones[i]
		local hasToy = PlayerHasToy(toyID) and C_ToyBox_IsToyUsable(toyID)

		-- here we don't check the current active covenant.
		-- because `/castrandom` cannot the current active covenant hearthstone.
		hearthstonesTable[toyID] = (hasToy and level and level == 60) and true or false
	end

	availableHearthstones = {}

	local index = 0
	local itemEngine = CreateFromMixins(ItemMixin)

	local function GetNextHearthStoneInfo()
		index = index + 1
		if hearthstoneAndToyIDList[index] then
			itemEngine:SetItemID(hearthstoneAndToyIDList[index])
			itemEngine:ContinueOnItemLoad(function()
				local id = itemEngine:GetItemID()
				if hearthstonesTable[id] then
					if GetItemCount(id) >= 1 or PlayerHasToy(id) and C_ToyBox_IsToyUsable(id) then
						tinsert(availableHearthstones, id)
					end
				end

				hearthstonesAndToysData[tostring(hearthstoneAndToyIDList[index])] = itemEngine:GetItemName()
				GetNextHearthStoneInfo()
			end)
		else
			self:UpdateHomeButton()
			if self.initialized then
				self:UpdateButtons()
			end
		end
	end

	GetNextHearthStoneInfo()
end

function module:GetHearthStoneTable()
	return hearthstonesAndToysData
end

function module:GetAvailableButtons()
	local buttons = {}

	for key, data in pairs(ButtonTypes) do
		buttons[key] = data.name
	end

	return buttons
end

MER:RegisterModule(module:GetName())
