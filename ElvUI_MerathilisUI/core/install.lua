local E, L, V, P, G = unpack(ElvUI);
local MER = E:GetModule("MerathilisUI");

-- Cache global variables
-- Lua functions
local _G = _G
local ceil, format, checkTable = ceil, format, next
local tinsert, twipe, tsort, tconcat = table.insert, table.wipe, table.sort, table.concat
-- WoW API / Variables
local ADDONS = ADDONS
local FCF_DockFrame = FCF_DockFrame
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_UnDockFrame = FCF_UnDockFrame
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded
local LOOT = LOOT
local ReloadUI = ReloadUI
local SetCVar = SetCVar
local TRADE = TRADE

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS: PluginInstallFrame, InstallStepComplete, ElvUIParent, NUM_CHAT_WINDOWS, LeftChatToggleButton
-- GLOBALS: ChatFrame1, ChatFrame3, ChatFrame_RemoveChannel, ChatFrame_AddChannel, ChatFrame_AddMessageGroup
-- GLOBALS: ToggleChatColorNamesByClassGroup, Skada, SkadaDB, BigWigs3DB

local classColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

function E:GetColor(r, b, g, a)
	return { r = r, b = b, g = g, a = a }
end

local function SetupCVars()
	-- Setup CVar
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoDismountFlying", 1)
	SetCVar("guildMemberNotify", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyPets", 1)
	SetCVar("nameplateShowFriendlyGuardians", 0)
	SetCVar("nameplateShowFriendlyPets", 0)
	SetCVar("nameplateShowFriendlyTotems", 0)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateMaxAlpha", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("taintLog", 0)
	SetCVar("Targetnearestuseold", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("scriptErrors", 1)
	SetCVar("showTimestamps", 0)
	SetCVar("showTutorials", 0)

	PluginInstallStepComplete.message = MER.Title..L["CVars Set"]
	PluginInstallStepComplete:Show()
end

local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)

		FCF_SetChatWindowFontSize(nil, frame, 11)

		-- move ElvUI default loot frame to the left chat, so that Recount/Skada can go to the right chat.
		if i == 3 and chatName == LOOT.." / "..TRADE then
			FCF_UnDockFrame(frame)
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
			FCF_SetWindowName(frame, LOOT)
			FCF_DockFrame(frame)
			if not frame.isLocked then
				FCF_SetLocked(frame, 1)
			end
			frame:Show()
		end
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
	end
	ChatFrame_RemoveChannel(ChatFrame3, L["Trade"])
	ChatFrame_AddChannel(ChatFrame1, L["Trade"])
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")

	-- Enable classcolor automatically on login and on each character without doing /configure each time
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")

	E.db["chat"]["keywordSound"] = "Whisper Alert"
	E.db["chat"]["tabFont"] = "Merathilis Roboto-Black"
	E.db["chat"]["tabFontOutline"] = "OUTLINE"
	E.db["chat"]["tabFontSize"] = 10
	E.db["chat"]["panelTabTransparency"] = true
	E.db["chat"]["fontOutline"] = "NONE"
	E.db["chat"]["chatHistory"] = false
	E.db["chat"]["font"] = "Merathilis Roboto-Medium"
	E.db["chat"]["separateSizes"] = true
	E.db["chat"]["panelWidth"] = 400
	E.db["chat"]["panelHeight"] = 155
	E.db["chat"]["panelHeightRight"] = 155
	E.db["chat"]["panelWidthRight"] = 280
	E.db["chat"]["editBoxPosition"] = "ABOVE_CHAT"
	E.db["chat"]["panelBackdrop"] = "SHOWBOTH"
	if E.myname == "Merathilis" or "Damará" or "Melisendra" or "Asragoth" or "Róhal" or "Jústice" or "Jazira" or "Brítt" or "Jahzzy" then
		E.db["chat"]["keywords"] = "%MYNAME%, ElvUI, MerathilisUI, Andy"
	else
		E.db["chat"]["keywords"] = "%MYNAME%, ElvUI, MerathilisUI"
	end
	E.db["chat"]["timeStampFormat"] = "%H:%M "
	if E.myname == "Merathilis" then
		E.db["chat"]["panelBackdropNameRight"] = "Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\moonkin.tga"
	else
		E.db["chat"]["panelBackdropNameRight"] = ""
	end
	MER:SetMoverPosition("RightChatMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -158, 2)
	MER:SetMoverPosition("LeftChatMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 2, 2)

	E:UpdateAll(true)

	PluginInstallStepComplete.message = MER.Title..L["Chat Set"]
	PluginInstallStepComplete:Show()
end

function MER:SetupLayout(noDataReset)
	if not IsAddOnLoaded("ElvUI_BenikUI") then
		E:StaticPopup_Show("BENIKUI")
	end

	if not noDataReset then
		--[[----------------------------------
		--	PrivateDB - General
		--]]----------------------------------
		E.private["general"]["pixelPerfect"] = true
		E.private["general"]["chatBubbles"] = "backdrop_noborder"
		E.private["general"]["chatBubbleFont"] = "Merathilis Roboto-Black"
		E.private["general"]["chatBubbleFontSize"] = 11
		E.private["general"]["classColorMentionsSpeech"] = true
		E.private["general"]["namefont"] = "Merathilis Roboto-Black"
		E.private["general"]["dmgfont"] = "Merathilis Roboto-Black"
		E.private["general"]["normTex"] = "MerathilisFlat"
		E.private["general"]["glossTex"] = "MerathilisFlat"
		if IsAddOnLoaded("XLoot") then
			E.private["general"]["loot"] = false
			E.private["general"]["lootRoll"] = false
		else
			E.private["general"]["loot"] = true
			E.private["general"]["lootRoll"] = true
		end

		--[[----------------------------------
		--	GlobalDB - General
		--]]----------------------------------
		E.global["general"]["autoScale"] = true
		E.global["general"]["animateConfig"] = false
		E.global["general"]["smallerWorldMap"] = false
		E.global["general"]["commandBarSetting"] = "ENABLED"

		--[[----------------------------------
		--	ProfileDB - General
		--]]----------------------------------
		E.db["general"]["valuecolor"] = {r = classColor.r, g = classColor.g, b = classColor.b}
		E.db["general"]["totems"]["size"] = 36
		E.db["general"]["font"] = "Merathilis Roboto-Black"
		E.db["general"]["fontSize"] = 10
		E.db["general"]["interruptAnnounce"] = "RAID"
		E.db["general"]["minimap"]["size"] = 153
		E.db["general"]["minimap"]["locationText"] = "MOUSEOVER"
		E.db["general"]["minimap"]["icons"]["classHall"]["position"] = "TOPRIGHT"
		E.db["general"]["minimap"]["icons"]["classHall"]["scale"] = 0.5
		E.db["general"]["minimap"]["icons"]["lfgEye"]["scale"] = 1.1
		E.db["general"]["minimap"]["icons"]["lfgEye"]["xOffset"] = -3
		E.db["general"]["minimap"]["icons"]["mail"]["position"] = "BOTTOMLEFT"
		E.db["general"]["loginmessage"] = false
		E.db["general"]["stickyFrames"] = false
		E.db["general"]["backdropcolor"]["r"] = 0.101
		E.db["general"]["backdropcolor"]["g"] = 0.101
		E.db["general"]["backdropcolor"]["b"] = 0.101
		E.db["general"]["bottomPanel"] = false
		E.db["general"]["topPanel"] = false
		E.db["general"]["bonusObjectivePosition"] = "AUTO"
		E.db["general"]["backdropfadecolor"]["r"] = 0.0549
		E.db["general"]["backdropfadecolor"]["g"] = 0.0549
		E.db["general"]["backdropfadecolor"]["b"] = 0.0549
		E.db["general"]["threat"]["enable"] = false
		E.db["databars"]["experience"]["enable"] = true
		E.db["databars"]["experience"]["mouseover"] = false
		E.db["databars"]["experience"]["height"] = 135
		E.db["databars"]["experience"]["textSize"] = 10
		E.db["databars"]["experience"]["width"] = 10
		E.db["databars"]["experience"]["textFormat"] = "NONE"
		E.db["databars"]["experience"]["orientation"] = "VERTICAL"
		E.db["databars"]["experience"]["hideAtMaxLevel"] = true
		E.db["databars"]["experience"]["hideInVehicle"] = true
		E.db["databars"]["reputation"]["enable"] = true
		E.db["databars"]["reputation"]["mouseover"] = false
		E.db["databars"]["reputation"]["height"] = 135
		E.db["databars"]["reputation"]["textSize"] = 10
		E.db["databars"]["reputation"]["width"] = 10
		E.db["databars"]["reputation"]["textFormat"] = "NONE"
		E.db["databars"]["reputation"]["orientation"] = "VERTICAL"
		E.db["databars"]["reputation"]["hideInVehicle"] = true
		E.db["databars"]["artifact"]["enable"] = true
		E.db["databars"]["artifact"]["height"] = 135
		E.db["databars"]["artifact"]["textSize"] = 11
		E.db["databars"]["artifact"]["width"] = 10
		E.db["databars"]["artifact"]["hideInVehicle"] = true
		E.db["databars"]["honor"]["enable"] = true
		E.db["databars"]["honor"]["height"] = 135
		E.db["databars"]["honor"]["textSize"] = 11
		E.db["databars"]["honor"]["hideOutsidePvP"] = true

		--[[----------------------------------
		--	ProfileDB - Auras
		--]]----------------------------------
		if IsAddOnLoaded("Masque") then
			E.private["auras"]["masque"]["buffs"] = true
			E.private["auras"]["masque"]["debuffs"] = true
		end
		E.db["auras"]["fadeThreshold"] = 10
		E.db["auras"]["font"] = "Merathilis Roboto-Black"
		E.db["auras"]["fontOutline"] = "OUTLINE"
		E.db["auras"]["fontSize"] = 12
		E.db["auras"]["timeYOffset"] = 0
		E.db["auras"]["timeXOffset"] = 0
		E.db["auras"]["buffs"]["horizontalSpacing"] = 10
		E.db["auras"]["buffs"]["verticalSpacing"] = 15
		E.db["auras"]["buffs"]["size"] = 32
		E.db["auras"]["buffs"]["wrapAfter"] = 10
		E.db["auras"]["debuffs"]["horizontalSpacing"] = 5
		E.db["auras"]["debuffs"]["size"] = 42
		MER:SetMoverPosition("BuffsMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -2, -29)
		MER:SetMoverPosition("DebuffsMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -2, -148)

		--[[----------------------------------
		--	ProfileDB - Bags
		--]]----------------------------------
		E.db["bags"]["itemLevelFont"] = "Merathilis Roboto-Black"
		E.db["bags"]["itemLevelFontSize"] = 9
		E.db["bags"]["itemLevelFontOutline"] = "OUTLINE"
		E.db["bags"]["countFont"] = "Merathilis Roboto-Black"
		E.db["bags"]["countFontSize"] = 10
		E.db["bags"]["countFontOutline"] = "OUTLINE"
		E.db["bags"]["bagSize"] = 23
		E.db["bags"]["alignToChat"] = false
		E.db["bags"]["bagWidth"] = 436
		E.db["bags"]["bankSize"] = 23
		E.db["bags"]["bankWidth"] = 400
		E.db["bags"]["moneyFormat"] = "CONDENSED"
		E.db["bags"]["itemLevelThreshold"] = 815
		E.db["bags"]["junkIcon"] = true
		MER:SetMoverPosition("ElvUIBagMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -2, 2)
		MER:SetMoverPosition("ElvUIBankMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 2, 2)

		--[[----------------------------------
		--	ProfileDB - NamePlate
		--]]----------------------------------
		E.db["nameplates"]["statusbar"] = "MerathilisFlat"
		E.db["nameplates"]["font"] = "Merathilis Roboto-Black"
		E.db["nameplates"]["fontSize"] = 10
		E.db["nameplates"]["fontOutline"] = "OUTLINE"
		E.db["nameplates"]["targetScale"] = 1.05
		E.db["nameplates"]["displayStyle"] = "BLIZZARD"
		E.db["nameplates"]["units"]["PLAYER"]["enable"] = false
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["healthbar"]["text"]["enable"] = true
		E.db["nameplates"]["units"]["ENEMY_PLAYER"]["healthbar"]["text"]["format"] = "PERCENT"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["healthbar"]["text"]["enable"] = true
		E.db["nameplates"]["units"]["ENEMY_NPC"]["healthbar"]["text"]["format"] = "PERCENT"
		E.db["nameplates"]["units"]["ENEMY_NPC"]["eliteIcon"]["enable"] = true
		E.db["nameplates"]["units"]["FRIENDLY_NPC"]["eliteIcon"]["enable"] = true
		E.db["nameplates"]["units"]["HEALER"]["healthbar"]["enable"] = false

		--[[----------------------------------
		--	ProfileDB - Tooltip
		--]]----------------------------------
		E.db["tooltip"]["itemCount"] = "NONE"
		E.db["tooltip"]["healthBar"]["height"] = 5
		E.db["tooltip"]["healthBar"]["font"] = "Merathilis Roboto-Black"
		E.db["tooltip"]["healthBar"]["fontOutline"] = "OUTLINE"
		E.db["tooltip"]["visibility"]["combat"] = false
		E.db["tooltip"]["font"] = "Merathilis Roboto-Medium"
		E.db["tooltip"]["style"] = "inset"
		E.db["tooltip"]["fontOutline"] = "NONE"
		E.db["tooltip"]["headerFontSize"] = 11
		E.db["tooltip"]["textFontSize"] = 10
		E.db["tooltip"]["smallTextFontSize"] = 10
		MER:SetMoverPosition("TooltipMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT" ,-3, 220)

		--[[----------------------------------
		--	Skins - Layout
		--]]----------------------------------
		if IsAddOnLoaded("ls_Toasts") then
			E.private["skins"]["blizzard"]["alertframes"] = false
		else
			E.private["skins"]["blizzard"]["alertframes"] = true
		end

		--[[----------------------------------
		--	Movers - Layout
		--]]----------------------------------
		MER:SetMoverPosition("AltPowerBarMover", "TOP", ElvUIParent, "TOP" ,1, -272)
		MER:SetMoverPosition("MinimapMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -2, 3)
		MER:SetMoverPosition("GMMover", "TOPLEFT", ElvUIParent, "TOPLEFT", 329, -24)
		MER:SetMoverPosition("BNETMover", "TOP", ElvUIParent, "TOP", 0, -38)
		MER:SetMoverPosition("LootFrameMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -495, -457)
		MER:SetMoverPosition("AlertFrameMover", "TOP", ElvUIParent, "TOP", 0, -140)
		MER:SetMoverPosition("TotemBarMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 511, 12)
		MER:SetMoverPosition("LossControlMover", "BOTTOM", ElvUIParent, "BOTTOM", 0, 465)
		MER:SetMoverPosition("ExperienceBarMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 474, 22)
		MER:SetMoverPosition("ReputationBarMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -491, 22)
		MER:SetMoverPosition("ObjectiveFrameMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -125, -240)
		MER:SetMoverPosition("VehicleSeatMover", "TOPLEFT", ElvUIParent, "TOPLEFT", 2, -84)
		MER:SetMoverPosition("ProfessionsMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -3, -184)
		MER:SetMoverPosition("ArtifactBarMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 455, 22)
		MER:SetMoverPosition("HonorBarMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -502, 22)
		MER:SetMoverPosition("TalkingHeadFrameMover", "TOP", ElvUIParent, "TOP", 0, -65)
		MER:SetMoverPosition("MER_LocPanel_Mover", "TOP", ElvUIParent, "TOP", 0, -29)
		MER:SetMoverPosition("OrderhallMover", "TOPLEFT", ElvUIParent, "TOPLEFT", 2 -29)
	end

	E:UpdateAll(true)

	PluginInstallStepComplete.message = MER.Title..L["Layout Set"]
	PluginInstallStepComplete:Show()
end

function MER:SetupActionbars(noDataReset)
	if not noDataReset then
		--[[----------------------------------
		--	ActionBars - General
		--]]----------------------------------
		E.db["actionbar"]["font"] = "Merathilis Roboto-Black"
		E.db["actionbar"]["fontOutline"] = "OUTLINE"
		E.db["actionbar"]["fontSize"] = 10
		E.db["actionbar"]["macrotext"] = true
		E.db["actionbar"]["showGrid"] = false
		E.db["actionbar"]["lockActionBars"] = true

		if IsAddOnLoaded("Masque") then
			E.private["actionbar"]["masque"]["stanceBar"] = true
			E.private["actionbar"]["masque"]["petBar"] = true
			E.private["actionbar"]["masque"]["actionbars"] = true
		end

		if IsAddOnLoaded("ElvUI_BenikUI") then
			E.db["benikui"]["actionbars"]["transparent"] = true
			E.db["benikui"]["actionbars"]["toggleButtons"]["enable"] = true
			E.db["benikui"]["actionbars"]["toggleButtons"]["chooseAb"] = "BAR1"
			E.db["benikui"]["actionbars"]["requestStop"] = true
		end

		E.db["actionbar"]["microbar"]["enabled"] = false
		E.db["actionbar"]["extraActionButton"]["scale"] = 0.75

		--[[----------------------------------
		--	ActionBars
		--]]----------------------------------
		E.db["actionbar"]["bar1"]["buttonspacing"] = 2
		E.db["actionbar"]["bar1"]["backdrop"] = true
		E.db["actionbar"]["bar1"]["heightMult"] = 1
		E.db["actionbar"]["bar1"]["buttonsize"] = 45
		E.db["actionbar"]["bar1"]["buttons"] = 6
		E.db["actionbar"]["bar1"]["backdropSpacing"] = 3
		E.db["actionbar"]["bar1"]["buttonspacing"] = 2
    
		E.db["actionbar"]["bar2"]["enabled"] = true
		E.db["actionbar"]["bar2"]["buttonspacing"] = 1
		E.db["actionbar"]["bar2"]["buttons"] = 8
		E.db["actionbar"]["bar2"]["buttonsize"] = 24
		E.db["actionbar"]["bar2"]["backdrop"] = true
		E.db["actionbar"]["bar2"]["visibility"] = "[vehicleui][overridebar][petbattle][possessbar] hide; show"
		E.db["actionbar"]["bar2"]["mouseover"] = false
		E.db["actionbar"]["bar2"]["backdropSpacing"] = 1
		E.db["actionbar"]["bar2"]["showGrid"] = false
		E.db["actionbar"]["bar2"]["heightMult"] = 1
		E.db["actionbar"]["bar2"]["buttonsPerRow"] = 4
    
		E.db["actionbar"]["bar3"]["enabled"] = true
		E.db["actionbar"]["bar3"]["backdrop"] = true
		E.db["actionbar"]["bar3"]["buttonsPerRow"] = 2
		E.db["actionbar"]["bar3"]["buttonsize"] = 23
		E.db["actionbar"]["bar3"]["buttonspacing"] = 3
		E.db["actionbar"]["bar3"]["buttons"] = 12
		E.db["actionbar"]["bar3"]["point"] = "TOPLEFT"
		E.db["actionbar"]["bar3"]["backdropSpacing"] = 0
    
		E.db["actionbar"]["bar4"]["enabled"] = true
		E.db["actionbar"]["bar4"]["buttonspacing"] = 4
		E.db["actionbar"]["bar4"]["mouseover"] = true
		E.db["actionbar"]["bar4"]["buttonsize"] = 24
		E.db["actionbar"]["bar4"]["backdropSpacing"] = 2
    
		E.db["actionbar"]["bar5"]["enabled"] = true
		E.db["actionbar"]["bar5"]["backdrop"] = true
		E.db["actionbar"]["bar5"]["buttonsPerRow"] = 2
		E.db["actionbar"]["bar5"]["buttonsize"] = 23
		E.db["actionbar"]["bar5"]["buttonspacing"] = 3
		E.db["actionbar"]["bar5"]["buttons"] = 12
		E.db["actionbar"]["bar5"]["point"] = "BOTTOMLEFT"
		E.db["actionbar"]["bar5"]["backdropSpacing"] = 0
    
		E.db["actionbar"]["bar6"]["enabled"] = true
		E.db["actionbar"]["bar6"]["backdropSpacing"] = 1
		E.db["actionbar"]["bar6"]["buttons"] = 8
		E.db["actionbar"]["bar6"]["buttonspacing"] = 1
		E.db["actionbar"]["bar6"]["visibility"] = "[vehicleui][overridebar][petbattle][possessbar] hide; show"
		E.db["actionbar"]["bar6"]["showGrid"] = false
		E.db["actionbar"]["bar6"]["mouseover"] = false
		E.db["actionbar"]["bar6"]["buttonsize"] = 24
		E.db["actionbar"]["bar6"]["backdrop"] = true
		E.db["actionbar"]["bar6"]["buttonsPerRow"] = 4
		E.db["actionbar"]["bar6"]["heightMult"] = 1
    
		E.db["actionbar"]["barPet"]["point"] = "BOTTOMLEFT"
		E.db["actionbar"]["barPet"]["buttons"] = 8
		E.db["actionbar"]["barPet"]["buttonspacing"] = 1
		E.db["actionbar"]["barPet"]["buttonsPerRow"] = 1
		E.db["actionbar"]["barPet"]["buttonsize"] = 19
		E.db["actionbar"]["barPet"]["mouseover"] = true
    
		E.db["actionbar"]["stanceBar"]["point"] = "BOTTOMLEFT"
		E.db["actionbar"]["stanceBar"]["backdrop"] = true
		E.db["actionbar"]["stanceBar"]["buttonsPerRow"] = 6
		E.db["actionbar"]["stanceBar"]["buttonsize"] = 18
		if E.myclass == "DRUID" then
			E.db["actionbar"]["stanceBar"]["mouseover"] = true
		else
			E.db["actionbar"]["stanceBar"]["mouseover"] = false
		end
    
		MER:SetMoverPosition("ElvAB_1", "BOTTOM", ElvUIParent, "BOTTOM", 0, 2)
		MER:SetMoverPosition("ElvAB_2", "BOTTOM", ElvUIParent, "BOTTOM", -196, 2)
		MER:SetMoverPosition("ElvAB_3", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -439, 2)
		MER:SetMoverPosition("ElvAB_4", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", 0, 367)
		MER:SetMoverPosition("ElvAB_5", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 403, 2)
		MER:SetMoverPosition("ElvAB_6", "BOTTOM", ElvUIParent, "BOTTOM", 197, 2)
		MER:SetMoverPosition("ShiftAB", "BOTTOM", ElvUIParent, "BOTTOM", 0, 75)
		MER:SetMoverPosition("PetAB", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 483, 18)
		MER:SetMoverPosition("BossButton", "BOTTOM", ElvUIParent, "BOTTOM", 0, 185)
		MER:SetMoverPosition("MicrobarMover", "TOPLEFT", ElvUIParent, "TOPLEFT", 4, -4)
	end

	E:UpdateAll(true)

	PluginInstallStepComplete.message = MER.Title..L["ActionBars Set"]
	PluginInstallStepComplete:Show()
end

function MER:SetupUnitframes(noDataReset)
	if not noDataReset then
		--[[----------------------------------
		--	UnitFrames - General
		--]]----------------------------------
		E.db["unitframe"]["font"] = "Merathilis Tukui"
		E.db["unitframe"]["fontOutline"] = "OUTLINE"
		E.db["unitframe"]["smoothbars"] = true
		E.db["unitframe"]["statusbar"] = "MerathilisFlat"
		E.db["unitframe"]["colors"]["castColor"]["r"] = 0.1
		E.db["unitframe"]["colors"]["castColor"]["g"] = 0.1
		E.db["unitframe"]["colors"]["castColor"]["b"] = 0.1
		E.db["unitframe"]["colors"]["transparentAurabars"] = true
		E.db["unitframe"]["colors"]["transparentPower"] = false
		E.db["unitframe"]["colors"]["transparentCastbar"] = true
		E.db["unitframe"]["colors"]["castClassColor"] = false
		E.db["unitframe"]["colors"]["castReactionColor"] = false

		--[[----------------------------------
		--	UnitFrames - DPS Layout
		--]]----------------------------------
		-- General
		E.db["unitframe"]["fontSize"] = 12
		E.db["unitframe"]["colors"]["powerclass"] = true
		E.db["unitframe"]["colors"]["transparentHealth"] = true
		E.db["unitframe"]["colors"]["health"]["r"] = 0.23
		E.db["unitframe"]["colors"]["health"]["g"] = 0.23
		E.db["unitframe"]["colors"]["health"]["b"] = 0.23
		E.db["unitframe"]["colors"]["power"]["MANA"] = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db["unitframe"]["colors"]["power"]["RAGE"] = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db["unitframe"]["colors"]["power"]["FOCUS"] = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db["unitframe"]["colors"]["power"]["ENERGY"] = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db["unitframe"]["colors"]["power"]["RUNIC_POWER"] = E:GetColor(classColor.r, classColor.b, classColor.g)
    
		-- Player
		E.db["unitframe"]["units"]["player"]["width"] = 180
		E.db["unitframe"]["units"]["player"]["height"] = 26
		E.db["unitframe"]["units"]["player"]["orientation"] = "RIGHT"
		E.db["unitframe"]["units"]["player"]["debuffs"]["fontSize"] = 12
		E.db["unitframe"]["units"]["player"]["debuffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["player"]["debuffs"]["sizeOverride"] = 36
		E.db["unitframe"]["units"]["player"]["debuffs"]["xOffset"] = -94
		E.db["unitframe"]["units"]["player"]["debuffs"]["yOffset"] = 4
		E.db["unitframe"]["units"]["player"]["debuffs"]["perrow"] = 4
		E.db["unitframe"]["units"]["player"]["debuffs"]["numrows"] = 1
		E.db["unitframe"]["units"]["player"]["debuffs"]["anchorPoint"] = "LEFT"
		E.db["unitframe"]["units"]["player"]["smartAuraPosition"] = "DISABLED"
		E.db["unitframe"]["units"]["player"]["portrait"]["enable"] = true
		E.db["unitframe"]["units"]["player"]["portrait"]["overlay"] = false
		E.db["unitframe"]["units"]["player"]["portrait"]["camDistanceScale"] = 1
		E.db["unitframe"]["units"]["player"]["classbar"]["enable"] = true
		E.db["unitframe"]["units"]["player"]["classbar"]["detachFromFrame"] = false
		E.db["unitframe"]["units"]["player"]["classbar"]["height"] = 5
		E.db["unitframe"]["units"]["player"]["classbar"]["autoHide"] = true
		E.db["unitframe"]["units"]["player"]["classbar"]["fill"] = "filled"
		E.db["unitframe"]["units"]["player"]["aurabar"]["enable"] = false
		E.db["unitframe"]["units"]["player"]["threatStyle"] = "INFOPANELBORDER"
		E.db["unitframe"]["units"]["player"]["castbar"]["icon"] = true
		E.db["unitframe"]["units"]["player"]["castbar"]["latency"] = true
		E.db["unitframe"]["units"]["player"]["castbar"]["insideInfoPanel"] = true
		if not E.db["unitframe"]["units"]["player"]["customTexts"] then E.db["unitframe"]["units"]["player"]["customTexts"] = {} end
		-- Delete old customTexts/ Create empty table
		E.db["unitframe"]["units"]["player"]["customTexts"] = {}
		-- Create own customText
		E.db["unitframe"]["units"]["player"]["customTexts"]["BigName"] = {
			["font"] = "Merathilis Tukui",
			["justifyH"] = "LEFT",
			["fontOutline"] = "OUTLINE",
			["text_format"] = "[name:medium]",
			["size"] = 20,
			["attachTextTo"] = "Health",
			["xOffset"] = 1,
		}
		E.db["unitframe"]["units"]["player"]["customTexts"]["Percent"] = {
			["font"] = "Merathilis Tukui",
			["fontOutline"] = "OUTLINE",
			["size"] = 20,
			["justifyH"] = "RIGHT",
			["text_format"] = "[classcolor:player][health:percent:hidefull:hidezero]",
			["attachTextTo"] = "Health",
		}
		E.db["unitframe"]["units"]["player"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["player"]["health"]["yOffset"] = 0
		E.db["unitframe"]["units"]["player"]["health"]["text_format"] = "[healthcolor][health:current] [classcolor:player][power:current]"
		E.db["unitframe"]["units"]["player"]["health"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["player"]["health"]["position"] = "LEFT"
		E.db["unitframe"]["units"]["player"]["name"]["text_format"] = ""
		E.db["unitframe"]["units"]["player"]["power"]["height"] = 5
		E.db["unitframe"]["units"]["player"]["power"]["hideonnpc"] = true
		E.db["unitframe"]["units"]["player"]["power"]["detachFromFrame"] = true
		E.db["unitframe"]["units"]["player"]["power"]["detachedWidth"] = 180
		E.db["unitframe"]["units"]["player"]["power"]["druidMana"] = false
		E.db["unitframe"]["units"]["player"]["power"]["text_format"] = ""
		E.db["unitframe"]["units"]["player"]["buffs"]["enable"] = false
		E.db["unitframe"]["units"]["player"]["raidicon"]["enable"] = true
		E.db["unitframe"]["units"]["player"]["raidicon"]["position"] = "TOP"
		E.db["unitframe"]["units"]["player"]["raidicon"]["size"] = 18
		E.db["unitframe"]["units"]["player"]["raidicon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["player"]["raidicon"]["yOffset"] = 15
		E.db["unitframe"]["units"]["player"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["player"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["player"]["infoPanel"]["transparent"] = true
		E.db["unitframe"]["units"]["player"]["pvpIcon"]["enable"] = true
		E.db["unitframe"]["units"]["player"]["pvpIcon"]["anchorPoint"] = "RIGHT"
		E.db["unitframe"]["units"]["player"]["pvpIcon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["player"]["pvpIcon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["player"]["pvpIcon"]["scale"] = 0.7
		if IsAddOnLoaded("ElvUI_BenikUI") then
			-- Detach portrait
			E.db["unitframe"]["units"]["player"]["portrait"]["width"] = 0
			E.db["benikui"]["unitframes"]["player"]["detachPortrait"] = true
			E.db["benikui"]["unitframes"]["player"]["portraitWidth"] = 92
			E.db["benikui"]["unitframes"]["player"]["portraitHeight"] = 39
			E.db["benikui"]["unitframes"]["player"]["portraitShadow"] = false
			E.db["benikui"]["unitframes"]["player"]["portraitTransparent"] = true
			E.db["benikui"]["unitframes"]["player"]["portraitStyle"] = true
			E.db["benikui"]["unitframes"]["player"]["portraitStyleHeight"] = 5
			-- Castbar
			E.db["benikui"]["unitframes"]["castbar"]["text"]["yOffset"] = 0
			E.db["benikui"]["unitframes"]["castbar"]["text"]["ShowInfoText"] = false
			E.db["benikui"]["unitframes"]["castbar"]["text"]["castText"] = true
			E.db["benikui"]["unitframes"]["castbar"]["text"]["texture"] = "MerathilisFlat"
			E.db["benikui"]["unitframes"]["castbar"]["text"]["textColor"] = {r = classColor.r, g = classColor.g, b = classColor.b}
		end
		MER:SetMoverPosition("ElvUF_PlayerMover", "BOTTOM", ElvUIParent, "BOTTOM", -186, 120)
		MER:SetMoverPosition("PlayerPowerBarMover", "BOTTOM", ElvUIParent, "BOTTOM", -186, 158)
		MER:SetMoverPosition("PlayerPortraitMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 591, 120)
    
		-- Target
		E.db["unitframe"]["units"]["target"]["width"] = 180
		E.db["unitframe"]["units"]["target"]["height"] = 26
		E.db["unitframe"]["units"]["target"]["orientation"] = "LEFT"
		E.db["unitframe"]["units"]["target"]["castbar"]["icon"] = true
		E.db["unitframe"]["units"]["target"]["castbar"]["latency"] = true
		E.db["unitframe"]["units"]["target"]["castbar"]["insideInfoPanel"] = true
		E.db["unitframe"]["units"]["target"]["debuffs"]["fontSize"] = 12
		E.db["unitframe"]["units"]["target"]["debuffs"]["sizeOverride"] = 28
		E.db["unitframe"]["units"]["target"]["debuffs"]["yOffset"] = 7
		E.db["unitframe"]["units"]["target"]["debuffs"]["xOffset"] = 94
		E.db["unitframe"]["units"]["target"]["debuffs"]["anchorPoint"] = "RIGHT"
		E.db["unitframe"]["units"]["target"]["debuffs"]["perrow"] = 4
		E.db["unitframe"]["units"]["target"]["debuffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["target"]["smartAuraPosition"] = "DISABLED"
		E.db["unitframe"]["units"]["target"]["aurabar"]["enable"] = false
		E.db["unitframe"]["units"]["target"]["aurabar"]["attachTo"] = "BUFFS"
		E.db["unitframe"]["units"]["target"]["name"]["xOffset"] = 8
		E.db["unitframe"]["units"]["target"]["name"]["yOffset"] = -32
		E.db["unitframe"]["units"]["target"]["name"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["target"]["name"]["text_format"] = ""
		E.db["unitframe"]["units"]["target"]["threatStyle"] = "INFOPANELBORDER"
		E.db["unitframe"]["units"]["target"]["power"]["detachFromFrame"] = true
		E.db["unitframe"]["units"]["target"]["power"]["detachedWidth"] = 180
		E.db["unitframe"]["units"]["target"]["power"]["hideonnpc"] = false
		E.db["unitframe"]["units"]["target"]["power"]["height"] = 5
		E.db["unitframe"]["units"]["target"]["power"]["text_format"] = ""
		if not E.db["unitframe"]["units"]["target"]["customTexts"] then E.db["unitframe"]["units"]["target"]["customTexts"] = {} end
		-- Delete old customTexts/ Create empty table
		E.db["unitframe"]["units"]["target"]["customTexts"] = {}
		-- Create own customText
		E.db["unitframe"]["units"]["target"]["customTexts"]["BigName"] = {
			["font"] = "Merathilis Tukui",
			["justifyH"] = "RIGHT",
			["fontOutline"] = "OUTLINE",
			["xOffset"] = 4,
			["yOffset"] = 0,
			["size"] = 20,
			["text_format"] = "[name:abbrev]",
			["attachTextTo"] = "Health",
		}
		E.db["unitframe"]["units"]["target"]["customTexts"]["Class"] = {
			["font"] = "Merathilis Tukui",
			["justifyH"] = "LEFT",
			["fontOutline"] = "OUTLINE",
			["xOffset"] = 1,
			["size"] = 12,
			["text_format"] = "[namecolor][smartclass] [difficultycolor][level]",
			["yOffset"] = 0,
			["attachTextTo"] = "InfoPanel",
		}
		E.db["unitframe"]["units"]["target"]["customTexts"]["Percent"] = {
			["font"] = "Merathilis Tukui",
			["size"] = 20,
			["fontOutline"] = "OUTLINE",
			["justifyH"] = "LEFT",
			["text_format"] = "[namecolor][health:percent:hidefull:hidezero]",
			["attachTextTo"] = "Health",
		}
		E.db["unitframe"]["units"]["target"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["target"]["health"]["yOffset"] = 0
		E.db["unitframe"]["units"]["target"]["health"]["text_format"] = "[namecolor][power:current] [healthcolor][health:current]"
		E.db["unitframe"]["units"]["target"]["health"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["target"]["health"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["target"]["portrait"]["enable"] = true
		E.db["unitframe"]["units"]["target"]["portrait"]["overlay"] = false
		E.db["unitframe"]["units"]["target"]["portrait"]["camDistanceScale"] = 1
		E.db["unitframe"]["units"]["target"]["buffs"]["enable"] = true
		E.db["unitframe"]["units"]["target"]["buffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["target"]["buffs"]["yOffset"] = 1
		E.db["unitframe"]["units"]["target"]["buffs"]["attachTo"] = "POWER"
		E.db["unitframe"]["units"]["target"]["buffs"]["sizeOverride"] = 20
		E.db["unitframe"]["units"]["target"]["buffs"]["perrow"] = 9
		E.db["unitframe"]["units"]["target"]["buffs"]["fontSize"] = 12
		E.db["unitframe"]["units"]["target"]["buffs"]["anchorPoint"] = "TOPLEFT"
		E.db["unitframe"]["units"]["target"]["raidicon"]["enable"] = true
		E.db["unitframe"]["units"]["target"]["raidicon"]["position"] = "TOP"
		E.db["unitframe"]["units"]["target"]["raidicon"]["size"] = 18
		E.db["unitframe"]["units"]["target"]["raidicon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["target"]["raidicon"]["yOffset"] = 15
		E.db["unitframe"]["units"]["target"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["target"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["target"]["infoPanel"]["transparent"] = true
		E.db["unitframe"]["units"]["target"]["pvpIcon"]["enable"] = true
		E.db["unitframe"]["units"]["target"]["pvpIcon"]["anchorPoint"] = "LEFT"
		E.db["unitframe"]["units"]["target"]["pvpIcon"]["scale"] = 0.7
		E.db["unitframe"]["units"]["target"]["pvpIcon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["target"]["pvpIcon"]["yOffset"] = 0
		if IsAddOnLoaded ("ElvUI_BenikUI") then
			E.db["unitframe"]["units"]["target"]["portrait"]["width"] = 0
			E.db["benikui"]["unitframes"]["target"]["detachPortrait"] = true
			E.db["benikui"]["unitframes"]["target"]["portraitWidth"] = 92
			E.db["benikui"]["unitframes"]["target"]["portraitHeight"] = 39
			E.db["benikui"]["unitframes"]["target"]["portraitShadow"] = false
			E.db["benikui"]["unitframes"]["target"]["portraitTransparent"] = true
			E.db["benikui"]["unitframes"]["target"]["portraitStyle"] = true
			E.db["benikui"]["unitframes"]["target"]["portraitStyleHeight"] = 5
		end
		MER:SetMoverPosition("ElvUF_TargetMover", "BOTTOM", ElvUIParent, "BOTTOM", 186, 120)
		MER:SetMoverPosition("TargetPowerBarMover", "BOTTOM", ElvUIParent, "BOTTOM", 186, 158)
		MER:SetMoverPosition("TargetPortraitMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -591, 120)
    
		-- TargetTarget
		E.db["unitframe"]["units"]["targettarget"]["debuffs"]["enable"] = true
		E.db["unitframe"]["units"]["targettarget"]["power"]["enable"] = true
		E.db["unitframe"]["units"]["targettarget"]["power"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["targettarget"]["power"]["height"] = 6
		E.db["unitframe"]["units"]["targettarget"]["width"] = 100
		E.db["unitframe"]["units"]["targettarget"]["name"]["yOffset"] = 0
		E.db["unitframe"]["units"]["targettarget"]["name"]["text_format"] = "[namecolor][name:medium]"
		E.db["unitframe"]["units"]["targettarget"]["height"] = 32
		E.db["unitframe"]["units"]["targettarget"]["health"]["text_format"] = ""
		E.db["unitframe"]["units"]["targettarget"]["raidicon"]["enable"] = true
		E.db["unitframe"]["units"]["targettarget"]["raidicon"]["position"] = "TOP"
		E.db["unitframe"]["units"]["targettarget"]["raidicon"]["size"] = 18
		E.db["unitframe"]["units"]["targettarget"]["raidicon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["targettarget"]["raidicon"]["yOffset"] = 15
		E.db["unitframe"]["units"]["targettarget"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["targettarget"]["infoPanel"]["enable"] = false
		E.db["unitframe"]["units"]["targettarget"]["customTexts"] = E.db["unitframe"]["units"]["targettarget"]["customTexts"] or {}
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"] = {}
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["attachTextTo"] = "Health"
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["font"] = "Merathilis GoodDogCool"
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["justifyH"] = "RIGHT"
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["fontOutline"] = "OUTLINE"
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["xOffset"] = 1
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["size"] = 20
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["text_format"] = "[namecolor]ToT"
		E.db["unitframe"]["units"]["targettarget"]["customTexts"]["ToT"]["yOffset"] = 16
		MER:SetMoverPosition("ElvUF_TargetTargetMover", "BOTTOM", ElvUIParent, "BOTTOM", 0, 127)
    
		-- Focus
		E.db["unitframe"]["units"]["focus"]["width"] = 122
		E.db["unitframe"]["units"]["focus"]["height"] = 20
		E.db["unitframe"]["units"]["focus"]["health"]["position"] = "LEFT"
		E.db["unitframe"]["units"]["focus"]["health"]["text_format"] = "[healthcolor][health:current]"
		E.db["unitframe"]["units"]["focus"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["focus"]["health"]["yOffset"] = 0
		E.db["unitframe"]["units"]["focus"]["health"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["focus"]["power"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["focus"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["focus"]["power"]["text_format"] = "[powercolor][power:current]"
		E.db["unitframe"]["units"]["focus"]["power"]["xOffset"] = 0
		E.db["unitframe"]["units"]["focus"]["power"]["yOffset"] = 0
		E.db["unitframe"]["units"]["focus"]["power"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["focus"]["castbar"]["enable"] = true
		E.db["unitframe"]["units"]["focus"]["castbar"]["latency"] = true
		E.db["unitframe"]["units"]["focus"]["castbar"]["insideInfoPanel"] = true
		E.db["unitframe"]["units"]["focus"]["castbar"]["iconSize"] = 20
		E.db["unitframe"]["units"]["focus"]["debuffs"]["anchorPoint"] = "BOTTOMRIGHT"
		E.db["unitframe"]["units"]["focus"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["focus"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["focus"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["focus"]["infoPanel"]["transparent"] = true
		MER:SetMoverPosition("ElvUF_FocusMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -452, 199)
		MER:SetMoverPosition("ElvUF_FocusCastbarMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -452, 220)
    
		-- FocusTarget
		E.db["unitframe"]["units"]["focustarget"]["enable"] = true
		E.db["unitframe"]["units"]["focustarget"]["debuffs"]["enable"] = true
		E.db["unitframe"]["units"]["focustarget"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["unitframe"]["units"]["focustarget"]["threatStyle"] = "GLOW"
		E.db["unitframe"]["units"]["focustarget"]["power"]["enable"] = true
		E.db["unitframe"]["units"]["focustarget"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["focustarget"]["width"] = 122
		E.db["unitframe"]["units"]["focustarget"]["height"] = 20
		E.db["unitframe"]["units"]["focustarget"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["focustarget"]["infoPanel"]["enable"] = false
		MER:SetMoverPosition("ElvUF_FocusTargetMover", "BOTTOMRIGHT", ElvUIParent, "BOTTOMRIGHT", -452, 234)
    
		-- Raid
		E.db["unitframe"]["units"]["raid"]["height"] = 24
		E.db["unitframe"]["units"]["raid"]["width"] = 79
		E.db["unitframe"]["units"]["raid"]["threatStyle"] = "GLOW"
		E.db["unitframe"]["units"]["raid"]["orientation"] = "MIDDLE"
		E.db["unitframe"]["units"]["raid"]["horizontalSpacing"] = 1
		E.db["unitframe"]["units"]["raid"]["verticalSpacing"] = 10
		E.db["unitframe"]["units"]["raid"]["debuffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["raid"]["debuffs"]["enable"] = true
		E.db["unitframe"]["units"]["raid"]["debuffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["debuffs"]["yOffset"] = -8
		E.db["unitframe"]["units"]["raid"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["unitframe"]["units"]["raid"]["debuffs"]["sizeOverride"] = 20
		E.db["unitframe"]["units"]["raid"]["rdebuffs"]["enable"] = false
		E.db["unitframe"]["units"]["raid"]["rdebuffs"]["font"] = "Merathilis Prototype"
		E.db["unitframe"]["units"]["raid"]["rdebuffs"]["fontSize"] = 10
		E.db["unitframe"]["units"]["raid"]["rdebuffs"]["size"] = 20
		E.db["unitframe"]["units"]["raid"]["numGroups"] = 4
		E.db["unitframe"]["units"]["raid"]["growthDirection"] = "RIGHT_UP"
		E.db["unitframe"]["units"]["raid"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["raid"]["name"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["name"]["yOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["name"]["text_format"] = "[namecolor][name:medium:status]"
		E.db["unitframe"]["units"]["raid"]["name"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["raid"]["name"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["raid"]["buffIndicator"]["fontSize"] = 11
		E.db["unitframe"]["units"]["raid"]["buffIndicator"]["size"] = 10
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["size"] = 10
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["position"] = "BOTTOMRIGHT"
		E.db["unitframe"]["units"]["raid"]["power"]["enable"] = true
		E.db["unitframe"]["units"]["raid"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["raid"]["healPrediction"] = true
		E.db["unitframe"]["units"]["raid"]["groupBy"] = "ROLE"
		E.db["unitframe"]["units"]["raid"]["health"]["frequentUpdates"] = true
		E.db["unitframe"]["units"]["raid"]["health"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["raid"]["health"]["text_format"] = "[healthcolor][health:deficit]"
		E.db["unitframe"]["units"]["raid"]["health"]["attachTextTo"] = "Health"
		E.db["unitframe"]["units"]["raid"]["buffs"]["enable"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["yOffset"] = 5
		E.db["unitframe"]["units"]["raid"]["buffs"]["anchorPoint"] = "CENTER"
		E.db["unitframe"]["units"]["raid"]["buffs"]["clickTrough"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["useBlacklist"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["noDuration"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["playerOnly"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["perrow"] = 1
		E.db["unitframe"]["units"]["raid"]["buffs"]["useFilter"] = "TurtleBuffs"
		E.db["unitframe"]["units"]["raid"]["buffs"]["noConsolidated"] = false
		E.db["unitframe"]["units"]["raid"]["buffs"]["sizeOverride"] = 20
		E.db["unitframe"]["units"]["raid"]["buffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["buffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["raid"]["raidicon"]["attachTo"] = "CENTER"
		E.db["unitframe"]["units"]["raid"]["raidicon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["raidicon"]["yOffset"] = 5
		E.db["unitframe"]["units"]["raid"]["raidicon"]["size"] = 15
		E.db["unitframe"]["units"]["raid"]["raidicon"]["yOffset"] = 0
		if not E.db["unitframe"]["units"]["raid"]["customTexts"] then E.db["unitframe"]["units"]["raid"]["customTexts"] = {} end
		-- Delete old customTexts/ Create empty table
		E.db["unitframe"]["units"]["raid"]["customTexts"] = {}
		-- Create own customTexts
		E.db["unitframe"]["units"]["raid"]["customTexts"]["Status"] = {
			["font"] = "Merathilis Tukui",
			["justifyH"] = "CENTER",
			["fontOutline"] = "OUTLINE",
			["xOffset"] = 0,
			["yOffset"] = 0,
			["size"] = 12,
			["attachTextTo"] = "Health",
			["text_format"] = "[namecolor][statustimer]",
		}
		E.db["unitframe"]["units"]["raid"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["raid"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["raid"]["infoPanel"]["transparent"] = true
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["enable"] = true
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["damager"] = true
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["tank"] = true
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["heal"] = true
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["attachTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["size"] = 10
		E.db["unitframe"]["units"]["raid"]["roleIcon"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["raid"]["colorOverride"] = "FORCE_ON"
		if IsAddOnLoaded("ElvUI_BenikUI") then
			E.db["unitframe"]["units"]["raid"]["classHover"] = true
		end
		MER:SetMoverPosition("ElvUF_RaidMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 2, 163)
    
		-- Raid40
		E.db["unitframe"]["units"]["raid40"]["horizontalSpacing"] = 1
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["sizeOverride"] = 21
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["useBlacklist"] = false
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["enable"] = true
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["yOffset"] = -9
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["clickTrough"] = true
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["useFilter"] = "Whitlist (Strict)"
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["xOffset"] = -4
		E.db["unitframe"]["units"]["raid40"]["debuffs"]["perrow"] = 2
		E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["font"] = "Merathilis Prototype"
		E.db["unitframe"]["units"]["raid40"]["rdebuffs"]["size"] = 26
		E.db["unitframe"]["units"]["raid40"]["growthDirection"] = "RIGHT_UP"
		E.db["unitframe"]["units"]["raid40"]["groupBy"] = "ROLE"
		E.db["unitframe"]["units"]["raid40"]["classHover"] = true
		E.db["unitframe"]["units"]["raid40"]["orientation"] = "MIDDLE"
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["enable"] = true
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["attachTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["damager"] = true
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["tank"] = true
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["heal"] = true
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["size"] = 9
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["raid40"]["roleIcon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["raid40"]["raidWideSorting"] = false
		E.db["unitframe"]["units"]["raid40"]["healPrediction"] = true
		E.db["unitframe"]["units"]["raid40"]["health"]["frequentUpdates"] = true
		E.db["unitframe"]["units"]["raid40"]["width"] = 69
		E.db["unitframe"]["units"]["raid40"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["raid40"]["infoPanel"]["transparent"] = true
		E.db["unitframe"]["units"]["raid40"]["verticalSpacing"] = 1
		E.db["unitframe"]["units"]["raid40"]["name"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["raid40"]["positionOverride"] = "BOTTOMRIGHT"
		E.db["unitframe"]["units"]["raid40"]["height"] = 35
		E.db["unitframe"]["units"]["raid40"]["buffs"]["noConsolidated"] = false
		E.db["unitframe"]["units"]["raid40"]["buffs"]["sizeOverride"] = 17
		E.db["unitframe"]["units"]["raid40"]["buffs"]["useBlacklist"] = false
		E.db["unitframe"]["units"]["raid40"]["buffs"]["noDuration"] = false
		E.db["unitframe"]["units"]["raid40"]["buffs"]["playerOnly"] = false
		E.db["unitframe"]["units"]["raid40"]["buffs"]["perrow"] = 1
		E.db["unitframe"]["units"]["raid40"]["buffs"]["anchorPoint"] = "CENTER"
		E.db["unitframe"]["units"]["raid40"]["buffs"]["clickTrough"] = true
		E.db["unitframe"]["units"]["raid40"]["buffs"]["useFilter"] = "TurtleBuffs"
		E.db["unitframe"]["units"]["raid40"]["buffs"]["enable"] = false
		E.db["unitframe"]["units"]["raid40"]["power"]["attachTextTo"] = "Health"
		E.db["unitframe"]["units"]["raid40"]["power"]["height"] = 3
		E.db["unitframe"]["units"]["raid40"]["power"]["enable"] = true
		E.db["unitframe"]["units"]["raid40"]["power"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["raid40"]["raidicon"]["attachTo"] = "LEFT"
		E.db["unitframe"]["units"]["raid40"]["raidicon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["raid40"]["raidicon"]["xOffset"] = 9
		E.db["unitframe"]["units"]["raid40"]["raidicon"]["size"] = 13
		E.db["unitframe"]["units"]["raid40"]["colorOverride"] = "FORCE_ON"
		MER:SetMoverPosition("ElvUF_Raid40Mover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 2, 185)
    
		-- Party
		E.db["unitframe"]["units"]["party"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["party"]["horizontalSpacing"] = 1
		E.db["unitframe"]["units"]["party"]["debuffs"]["anchorPoint"] = "TOPRIGHT"
		E.db["unitframe"]["units"]["party"]["debuffs"]["sizeOverride"] = 20
		E.db["unitframe"]["units"]["party"]["debuffs"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["party"]["debuffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["party"]["debuffs"]["perrow"] = 3
		E.db["unitframe"]["units"]["party"]["debuffs"]["yOffset"] = 0
		E.db["unitframe"]["units"]["party"]["debuffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["portrait"]["overlay"] = true
		E.db["unitframe"]["units"]["party"]["portrait"]["transparent"] = true
		E.db["unitframe"]["units"]["party"]["rdebuffs"]["font"] = "Merathilis Prototype"
		E.db["unitframe"]["units"]["party"]["rdebuffs"]["fontOutline"] = "OUTLINE"
		E.db["unitframe"]["units"]["party"]["rdebuffs"]["size"] = 20
		E.db["unitframe"]["units"]["party"]["rdebuffs"]["yOffset"] = 12
		E.db["unitframe"]["units"]["party"]["growthDirection"] = "RIGHT_UP"
		E.db["unitframe"]["units"]["party"]["groupBy"] = "ROLE"
		E.db["unitframe"]["units"]["party"]["health"]["frequentUpdates"] = true
		E.db["unitframe"]["units"]["party"]["health"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["party"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["health"]["text_format"] = "[healthcolor][health:deficit]"
		E.db["unitframe"]["units"]["party"]["health"]["yOffset"] = 2
		E.db["unitframe"]["units"]["party"]["roleIcon"]["attachTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["party"]["roleIcon"]["size"] = 10
		E.db["unitframe"]["units"]["party"]["roleIcon"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["party"]["roleIcon"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["roleIcon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["party"]["targetsGroup"]["anchorPoint"] = "RIGHT"
		E.db["unitframe"]["units"]["party"]["targetsGroup"]["xOffset"] = 1
		E.db["unitframe"]["units"]["party"]["targetsGroup"]["yOffset"] = -14
		E.db["unitframe"]["units"]["party"]["targetsGroup"]["height"] = 16
		E.db["unitframe"]["units"]["party"]["targetsGroup"]["width"] = 70
		E.db["unitframe"]["units"]["party"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["party"]["power"]["position"] = "BOTTOMRIGHT"
		E.db["unitframe"]["units"]["party"]["power"]["text_format"] = ""
		E.db["unitframe"]["units"]["party"]["power"]["yOffset"] = 2
		E.db["unitframe"]["units"]["party"]["numGroups"] = 1
		E.db["unitframe"]["units"]["party"]["healPrediction"] = true
		E.db["unitframe"]["units"]["party"]["orientation"] = "MIDDLE"
		E.db["unitframe"]["units"]["party"]["width"] = 79
		E.db["unitframe"]["units"]["party"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["party"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["party"]["infoPanel"]["transparent"] = true
		E.db["unitframe"]["units"]["party"]["buffIndicator"]["size"] = 10
		E.db["unitframe"]["units"]["party"]["buffIndicator"]["fontSize"] = 11
		E.db["unitframe"]["units"]["party"]["name"]["position"] = "CENTER"
		E.db["unitframe"]["units"]["party"]["name"]["yOffset"] = 0
		E.db["unitframe"]["units"]["party"]["name"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["name"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["party"]["name"]["text_format"] = "[namecolor][name:medium:status]"
		E.db["unitframe"]["units"]["party"]["buffs"]["noConsolidated"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["sizeOverride"] = 20
		E.db["unitframe"]["units"]["party"]["buffs"]["useBlacklist"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["noDuration"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["playerOnly"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["yOffset"] = 5
		E.db["unitframe"]["units"]["party"]["buffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["buffs"]["anchorPoint"] = "CENTER"
		E.db["unitframe"]["units"]["party"]["buffs"]["clickTrough"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["useFilter"] = "TurtleBuffs"
		E.db["unitframe"]["units"]["party"]["buffs"]["perrow"] = 1
		E.db["unitframe"]["units"]["party"]["buffs"]["enable"] = false
		E.db["unitframe"]["units"]["party"]["buffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["party"]["buffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["party"]["height"] = 24
		E.db["unitframe"]["units"]["party"]["verticalSpacing"] = 10
		E.db["unitframe"]["units"]["party"]["petsGroup"]["name"]["position"] = "LEFT"
		E.db["unitframe"]["units"]["party"]["petsGroup"]["height"] = 16
		E.db["unitframe"]["units"]["party"]["petsGroup"]["yOffset"] = -1
		E.db["unitframe"]["units"]["party"]["petsGroup"]["xOffset"] = 0
		E.db["unitframe"]["units"]["party"]["petsGroup"]["width"] = 60
		E.db["unitframe"]["units"]["party"]["raidicon"]["attachTo"] = "CENTER"
		E.db["unitframe"]["units"]["party"]["raidicon"]["size"] = 15
		E.db["unitframe"]["units"]["party"]["raidicon"]["yOffset"] = 0
		E.db["unitframe"]["units"]["party"]["colorOverride"] = "FORCE_ON"
		if E.db["unitframe"]["units"]["party"]["customTexts"] then E.db["unitframe"]["units"]["party"]["customTexts"] = nil end
		MER:SetMoverPosition("ElvUF_PartyMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 2, 163)
    
		-- Assist
		E.db["unitframe"]["units"]["assist"]["enable"] = false
		MER:SetMoverPosition("ElvUF_AssistMover", "TOPLEFT", ElvUIParent, "BOTTOMLEFT", 2, 571)
    
		-- Tank
		E.db["unitframe"]["units"]["tank"]["enable"] = false
		MER:SetMoverPosition("ElvUF_TankMover", "TOPLEFT", ElvUIParent, "BOTTOMLEFT", 2, 626)
    
		-- Pet
		E.db["unitframe"]["units"]["pet"]["castbar"]["enable"] = true
		E.db["unitframe"]["units"]["pet"]["castbar"]["latency"] = true
		E.db["unitframe"]["units"]["pet"]["castbar"]["insideInfoPanel"] = true
		E.db["unitframe"]["units"]["pet"]["debuffs"]["fontSize"] = 10
		E.db["unitframe"]["units"]["pet"]["debuffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["pet"]["debuffs"]["sizeOverride"] = 0
		E.db["unitframe"]["units"]["pet"]["debuffs"]["xOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["debuffs"]["yOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["debuffs"]["perrow"] = 5
		E.db["unitframe"]["units"]["pet"]["debuffs"]["anchorPoint"] = "TOPLEFT"
		E.db["unitframe"]["units"]["pet"]["health"]["position"] = "LEFT"
		E.db["unitframe"]["units"]["pet"]["health"]["text_format"] = "[healthcolor][health:current]"
		E.db["unitframe"]["units"]["pet"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["health"]["yOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["health"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["pet"]["power"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["pet"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["pet"]["power"]["text_format"] = "[namecolor][power:current]"
		E.db["unitframe"]["units"]["pet"]["power"]["xOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["power"]["yOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["power"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["pet"]["name"]["attachTextTo"] = "Health"
		E.db["unitframe"]["units"]["pet"]["name"]["text_format"] = "[namecolor][name:medium]"
		E.db["unitframe"]["units"]["pet"]["name"]["xOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["name"]["yOffset"] = 0
		E.db["unitframe"]["units"]["pet"]["width"] = 122
		E.db["unitframe"]["units"]["pet"]["height"] = 20
		E.db["unitframe"]["units"]["pet"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["pet"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["pet"]["portrait"]["overlay"] = true
		E.db["unitframe"]["units"]["pet"]["orientation"] = "MIDDLE"
		E.db["unitframe"]["units"]["pet"]["infoPanel"]["enable"] = true
		E.db["unitframe"]["units"]["pet"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["pet"]["infoPanel"]["transparent"] = true
		MER:SetMoverPosition("ElvUF_PetMover", "BOTTOMLEFT", ElvUIParent, "BOTTOMLEFT", 452, 199)
    
		-- Arena
		E.db["unitframe"]["units"]["arena"]["power"]["width"] = "inset"
		MER:SetMoverPosition("ArenaHeaderMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -52, 370)
    
		-- Boss
		E.db["unitframe"]["units"]["boss"]["portrait"]["enable"] = false
		E.db["unitframe"]["units"]["boss"]["debuffs"]["sizeOverride"] = 24
		E.db["unitframe"]["units"]["boss"]["debuffs"]["yOffset"] = -4
		E.db["unitframe"]["units"]["boss"]["debuffs"]["anchorPoint"] = "RIGHT"
		E.db["unitframe"]["units"]["boss"]["debuffs"]["xOffset"] = 2
		E.db["unitframe"]["units"]["boss"]["debuffs"]["perrow"] = 5
		E.db["unitframe"]["units"]["boss"]["debuffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["boss"]["debuffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["boss"]["threatStyle"] = "HEALTHBORDER"
		E.db["unitframe"]["units"]["boss"]["castbar"]["enable"] = true
		E.db["unitframe"]["units"]["boss"]["castbar"]["icon"] = true
		E.db["unitframe"]["units"]["boss"]["castbar"]["iconAttached"] = true
		E.db["unitframe"]["units"]["boss"]["castbar"]["width"] = 156
		E.db["unitframe"]["units"]["boss"]["castbar"]["height"] = 18
		if not E.db["unitframe"]["units"]["boss"]["customTexts"] then E.db["unitframe"]["units"]["boss"]["customTexts"] = {} end
		-- Delete old customTexts/ Create empty table
		E.db["unitframe"]["units"]["boss"]["customTexts"] = {}
		-- Create own customTexts
		E.db["unitframe"]["units"]["boss"]["customTexts"]["BigName"] = {
			["attachTextTo"] = "Health",
			["font"] = "Merathilis Tukui",
			["justifyH"] = "LEFT",
			["fontOutline"] = "OUTLINE",
			["xOffset"] = 0,
			["size"] = 16,
			["text_format"] = "[level][shortclassification] | [namecolor][name:short]",
			["yOffset"] = 15,
		}
		E.db["unitframe"]["units"]["boss"]["power"]["height"] = 4
		E.db["unitframe"]["units"]["boss"]["power"]["text_format"] = ""
		E.db["unitframe"]["units"]["boss"]["power"]["position"] = "LEFT"
		E.db["unitframe"]["units"]["boss"]["growthDirection"] = "UP"
		E.db["unitframe"]["units"]["boss"]["infoPanel"]["enable"] = false
		E.db["unitframe"]["units"]["boss"]["infoPanel"]["height"] = 13
		E.db["unitframe"]["units"]["boss"]["infoPanel"]["transparent"] = false
		E.db["unitframe"]["units"]["boss"]["width"] = 156
		E.db["unitframe"]["units"]["boss"]["health"]["xOffset"] = 0
		E.db["unitframe"]["units"]["boss"]["health"]["yOffset"] = 13
		E.db["unitframe"]["units"]["boss"]["health"]["text_format"] = "[health:current] - [health:percent]"
		E.db["unitframe"]["units"]["boss"]["health"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["boss"]["spacing"] = 40
		E.db["unitframe"]["units"]["boss"]["height"] = 16
		E.db["unitframe"]["units"]["boss"]["buffs"]["attachTo"] = "FRAME"
		E.db["unitframe"]["units"]["boss"]["buffs"]["xOffset"] = -2
		E.db["unitframe"]["units"]["boss"]["buffs"]["yOffset"] = -5
		E.db["unitframe"]["units"]["boss"]["buffs"]["sizeOverride"] = 26
		E.db["unitframe"]["units"]["boss"]["buffs"]["anchorPoint"] = "LEFT"
		E.db["unitframe"]["units"]["boss"]["buffs"]["countFontSize"] = 12
		E.db["unitframe"]["units"]["boss"]["name"]["attachTextTo"] = "InfoPanel"
		E.db["unitframe"]["units"]["boss"]["name"]["position"] = "RIGHT"
		E.db["unitframe"]["units"]["boss"]["name"]["xOffset"] = 6
		E.db["unitframe"]["units"]["boss"]["name"]["text_format"] = ""
		E.db["unitframe"]["units"]["boss"]["name"]["yOffset"] = 16
		MER:SetMoverPosition("BossHeaderMover", "TOPRIGHT", ElvUIParent, "TOPRIGHT", -123, -378)
    
		-- PetTarget
		E.db["unitframe"]["units"]["pettarget"]["enable"] = false
    
		-- RaidPet
		E.db["unitframe"]["units"]["raidpet"]["enable"] = false
		MER:SetMoverPosition("ElvUF_RaidpetMover", "TOPLEFT", ElvUIParent, "BOTTOMLEFT", 0, 808)
	end

	E:UpdateAll(true)

	PluginInstallStepComplete.message = MER.Title..L["UnitFrames Set"]
	PluginInstallStepComplete:Show()
end

function MER:SetupDts()
	--[[----------------------------------
	--	ProfileDB - Datatexts
	--]]----------------------------------
	E.db["datatexts"]["font"] = "Merathilis Roboto-Black"
	E.db["datatexts"]["fontSize"] = 10
	E.db["datatexts"]["fontOutline"] = "OUTLINE"
	E.db["datatexts"]["time24"] = true
	E.db["datatexts"]["goldFormat"] = "CONDENSED"
	E.db["datatexts"]["goldCoins"] = true
	E.db["datatexts"]["noCombatHover"] = true
	E.db["datatexts"]["panelTransparency"] = true
	E.db["datatexts"]["wordWrap"] = true

	E.db["datatexts"]["leftChatPanel"] = false
	E.db["datatexts"]["rightChatPanel"] = false
	E.db["datatexts"]["minimapPanels"] = false
	E.db["datatexts"]["minimapBottom"] = false
	E.db["datatexts"]["actionbar3"] = false
	E.db["datatexts"]["actionbar5"] = false


	E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].left = "Durability"

	if IsAddOnLoaded("Skada") then
		E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].middle = "Skada"
	elseif IsAddOnLoaded("Details") then
		E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].middle = "Details"
	else
		E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].middle = "Coords"
	end

	if IsAddOnLoaded("WIM") then
		E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].right = "WIM"
	else
		E.db["mui"]["datatexts"]["panels"]["ChatTab_Datatext_Panel"].right = "Bags"
	end

	if IsAddOnLoaded("ElvUI_BenikUI") then
		-- define BenikUI Datetexts
		E.db["datatexts"]["panels"]["BuiLeftChatDTPanel"]["left"] = ""
		E.db["datatexts"]["panels"]["BuiLeftChatDTPanel"]["middle"] = ""
		E.db["datatexts"]["panels"]["BuiLeftChatDTPanel"]["right"] = ""

		if IsAddOnLoaded("ElvUI_SLE") then
			E.db["datatexts"]["panels"]["BuiRightChatDTPanel"]["middle"] = ""
		else
			E.db["datatexts"]["panels"]["BuiRightChatDTPanel"]["middle"] = ""
		end

		if IsAddOnLoaded("Skada") then
			E.db["datatexts"]["panels"]["BuiRightChatDTPanel"]["left"] = ""
		else
			E.db["datatexts"]["panels"]["BuiRightChatDTPanel"]["left"] = ""
		end
		E.db["datatexts"]["panels"]["BuiRightChatDTPanel"]["right"] = ""

		E.db["datatexts"]["panels"]["BuiMiddleDTPanel"]["left"] = ""
		E.db["datatexts"]["panels"]["BuiMiddleDTPanel"]["middle"] = ""
		E.db["datatexts"]["panels"]["BuiMiddleDTPanel"]["right"] = ""

		E.db["datatexts"]["panels"]["RightChatDataPanel"]["middle"] = ""
		E.db["datatexts"]["panels"]["RightChatDataPanel"]["right"] = ""
		E.db["datatexts"]["panels"]["RightChatDataPanel"]["left"] = ""

		E.db["datatexts"]["panels"]["LeftChatDataPanel"]["left"] = ""
		E.db["datatexts"]["panels"]["LeftChatDataPanel"]["middle"] = ""
		E.db["datatexts"]["panels"]["LeftChatDataPanel"]["right"] = ""
	else
		-- define the default ElvUI datatexts
		E.db["datatexts"]["panels"]["LeftChatDataPanel"]["left"] = ""
		E.db["datatexts"]["panels"]["LeftChatDataPanel"]["middle"] = ""
		
		if IsAddOnLoaded("Skada") then
			E.db["datatexts"]["panels"]["RightChatDataPanel"]["left"] = ""
		else
			E.db["datatexts"]["panels"]["RightChatDataPanel"]["left"] = ""
		end
		E.db["datatexts"]["panels"]["RightChatDataPanel"]["middle"] = ""
		E.db["datatexts"]["panels"]["RightChatDataPanel"]["right"] = ""
	end

	E:UpdateAll(true)

	PluginInstallStepComplete.message = MER.Title..L["DataTexts Set"]
	PluginInstallStepComplete:Show()
end

local addonNames = {}
local profilesFailed = format('|cff00c0fa%s |r', L["MerathilisUI didn't find any supported addons for profile creation"])

local function SetupAddons()
	--[[----------------------------------
	--	Skada - Settings
	--]]----------------------------------
	if IsAddOnLoaded("Skada") then
		MER:LoadSkadaProfile()
		tinsert(addonNames, 'Skada')
	end

	--[[----------------------------------
	--	Details - Settings
	--]]----------------------------------
	if IsAddOnLoaded("Details") then
		MER:LoadDetailsProfile()
		tinsert(addonNames, 'Details')
	end

	--[[----------------------------------
	--	BigWigs - Settings
	--]]----------------------------------
	if IsAddOnLoaded("BigWigs") then
		MER:LoadBigWigsProfile()
		tinsert(addonNames, 'BigWigs')
	end

	--[[----------------------------------
	--	XIV_Databar - Settings
	--]]----------------------------------
	if IsAddOnLoaded("XIV_Databar") then
		MER:LoadXIVDatabarProfile()
		tinsert(addonNames, 'XIV_Databar')
	end

	--[[----------------------------------
	--	AddOnSkins - Settings
	--]]----------------------------------
	if IsAddOnLoaded("AddOnSkins") then
		MER:LoadAddOnSkinsProfile()
		tinsert(addonNames, 'AddOnSkins')
	end

	--[[----------------------------------
	--	BenikUI - Settings
	--]]----------------------------------
	if IsAddOnLoaded("ElvUI_BenikUI") then
		if E.db["benikui"] == nil then E.db["benikui"] = {} end
		MER:LoadBenikUIProfile()
		tinsert(addonNames, 'ElvUI_BenikUI')
	end

	--[[----------------------------------
	--	S&L - Settings
	--]]----------------------------------
	if IsAddOnLoaded("ElvUI_SLE") then
		if E.db.sle == nil then E.db.sle = {} end
		MER:LoadShadowandLightProfile()
		tinsert(addonNames, 'ElvUI_SLE')
	end

	--[[----------------------------------
	--	SorhaQuestLog - Settings
	--]]----------------------------------
	if IsAddOnLoaded("SorhaQuestLog") then
		MER:LoadSorhaQuestLogProfile()
		tinsert(addonNames, 'SorhaQuestLog')
	end

	--[[----------------------------------
	--	KuiNamePlates - Settings
	--]]----------------------------------
	if IsAddOnLoaded("Kui_Nameplates_Core") then
		MER:LoadKuiNamePlatesCoreProfile()
		tinsert(addonNames, 'KuiNamePlates')
	end

	--[[----------------------------------
	--	Masque - Settings
	--]]----------------------------------
	if IsAddOnLoaded("Masque") then
		MER:LoadMasqueProfile()
		tinsert(addonNames, 'Masque')
	end

	if checkTable(addonNames) ~= nil then
		local profileString = format('|cffff7d0a%s |r', L['MerathilisUI successfully created and applied profile(s) for:']..'\n')

		tsort(addonNames, function(a, b) return a < b end)

		local names = tconcat(addonNames, ", ")
		profileString = profileString..names

		PluginInstallFrame.Desc4:SetText(profileString..'.')
	else
		PluginInstallFrame.Desc4:SetText(profilesFailed)
	end

	PluginInstallStepComplete.message = MER.Title..L["Addons Set"]
	PluginInstallStepComplete:Show()
	twipe(addonNames)
	E:UpdateAll(true)
end

local function InstallComplete()
	E.private.install_complete = E.version
	E.db.mui.installed = true

	ReloadUI()
end

-- ElvUI PlugIn installer
MER.installTable = {
	["Name"] = "|cffff7d0aMerathilisUI|r",
	["Title"] = L["|cffff7d0aMerathilisUI|r Installation"],
 	["tutorialImage"] = [[Interface\AddOns\ElvUI_MerathilisUI\media\textures\merathilis_logo.tga]],
 	["Pages"] = {
		[1] = function()
			PluginInstallFrame.SubTitle:SetFormattedText(L["Welcome to MerathilisUI |cff00c0faVersion|r %s, for ElvUI %s."], MER.Version, E.version)
			PluginInstallFrame.Desc1:SetText(L["By pressing the Continue button, MerathilisUI will be applied in your current ElvUI installation.\r|cffff8000 TIP: It would be nice if you apply the changes in a new profile, just in case you don't like the result.|r"])
			PluginInstallFrame.Desc2:SetText(L["Please press the continue button to go onto the next step."])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() InstallComplete() end)
			PluginInstallFrame.Option1:SetText(L["Skip Process"])
		end,
		[2] = function()
			PluginInstallFrame.SubTitle:SetText(L["Layout"])
			PluginInstallFrame.Desc1:SetText(L["This part of the installation changes the default ElvUI look."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below to apply the new layout."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cff07D400High|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() MER:SetupLayout() end)
			PluginInstallFrame.Option1:SetText(L["Layout"])
		end,
		[3] = function()
			PluginInstallFrame.SubTitle:SetText(L["CVars"])
			PluginInstallFrame.Desc1:SetFormattedText(L["This step changes a few World of Warcraft default options. These options are tailored to the needs of the author of %s and are not necessary for this edit to function."], MER.Title)
			PluginInstallFrame.Desc2:SetText(L["Please click the button below to setup your CVars."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupCVars() end)
			PluginInstallFrame.Option1:SetText(L["CVars"])
		end,
		[4] = function()
			PluginInstallFrame.SubTitle:SetText(L["Chat"])
			PluginInstallFrame.Desc1:SetText(L["This part of the installation process sets up your chat fonts and colors."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below to setup your chat windows."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupChat() end)
			PluginInstallFrame.Option1:SetText(L["Setup Chat"])
		end,
		[5] = function()
			PluginInstallFrame.SubTitle:SetText(L["DataTexts"])
			PluginInstallFrame.Desc1:SetText(L["This part of the installation process will fill MerathilisUI datatexts.\r|cffff8000This doesn't touch ElvUI datatexts|r"])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below to setup your datatexts."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() MER:SetupDts() end)
			PluginInstallFrame.Option1:SetText(L["Setup Datatexts"])
		end,
		[6] = function()
			PluginInstallFrame.SubTitle:SetText(L["ActionBars"])
			PluginInstallFrame.Desc1:SetText(L["This part of the installation process will reposition your Actionbars and will enable backdrops"])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below |cff07D400twice|r to setup your actionbars."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cff07D400High|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() MER:SetupActionbars() end)
			PluginInstallFrame.Option1:SetText(L["ActionBars"])
		end,
		[7] = function()
			PluginInstallFrame.SubTitle:SetText(L["UnitFrames"])
			PluginInstallFrame.Desc1:SetText(L["This part of the installation process will reposition your Unitframes."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below |cff07D400twice|r to setup your Unitframes."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cff07D400High|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() MER:SetupUnitframes() end)
			PluginInstallFrame.Option1:SetText(L["UnitFrames"])
		end,
		[8] = function()
			PluginInstallFrame.SubTitle:SetFormattedText("%s", ADDONS)
			PluginInstallFrame.Desc1:SetText(L["This part of the installation process will apply changes to the addons like Skada and ElvUI plugins"])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below to setup your addons."])
			PluginInstallFrame.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupAddons(); end)
			PluginInstallFrame.Option1:SetText(L["Setup Addons"])
		end,
		[9] = function()
			PluginInstallFrame.SubTitle:SetText(L["Installation Complete"])
			PluginInstallFrame.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() InstallComplete() end)
			PluginInstallFrame.Option1:SetText(L["Finished"])
			if InstallStepComplete then
				InstallStepComplete.message = MER.Title..L["Installed"]
				InstallStepComplete:Show()
			end
		end,
	},

	["StepTitles"] = {
		[1] = START,
		[2] = L["Layout"],
		[3] = L["CVars"],
		[4] = L["Chat"],
		[5] = L["DataTexts"],
		[6] = L["ActionBars"],
		[7] = L["UnitFrames"],
		[8] = ADDONS,
		[9] = L["Installation Complete"],
	},
	StepTitlesColorSelected = RAID_CLASS_COLORS[E.myclass],
	StepTitleWidth = 200,
	StepTitleButtonWidth = 200,
	StepTitleTextJustification = "CENTER",
}