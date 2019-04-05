local MER, E, L, V, P, G = unpack(select(2, ...))
local MERS = MER:GetModule("muiSkins")
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local _G = _G
local select = select
-- WoW API
-- GLOBALS:

local function styleGMChatUI()
	if E.private.skins.blizzard.enable ~= true then return end

	local frame = _G.GMChatFrame
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:StripTextures()
	frame:CreateBackdrop("Transparent")

	frame.buttonFrame:Kill()

	local eb = frame.editBox
	eb:SetAltArrowKeyMode(false)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end
	eb:ClearAllPoints()
	eb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -7)
	eb:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -32)

	local lang = _G.GMChatFrameEditBoxLanguage
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 3, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)

	local tab = _G["GMChatTab"]
	tab:StripTextures()
	tab:CreateBackdrop("Transparent")
	tab:SetBackdropColor(0, .6, 1, .3)
	tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
	tab:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 28)
	_G.GMChatTabIcon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Blizz")

	S:HandleCloseButton(_G.GMChatFrameCloseButton)
	_G.GMChatFrameCloseButton:ClearAllPoints()
	_G.GMChatFrameCloseButton:SetPoint("RIGHT", _G.GMChatTab, -5, 0)
end

S:AddCallbackForAddon("Blizzard_GMChatUI", "mUIGMChatUI", styleGMChatUI)
