local MER, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")
local MERS = MER:NewModule("muiSkins", "AceHook-3.0", "AceEvent-3.0")
MERS.modName = L["Skins/AddOns"]

-- Cache global variables
-- Lua functions
local _G = _G
local assert, pairs, select, unpack, type = assert, pairs, select, unpack, type
local find, lower, strfind = string.find, string.lower, strfind
-- WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: AddOnSkins, stripes

local alpha
local backdropcolorr, backdropcolorg, backdropcolorb
local backdropfadecolorr, backdropfadecolorg, backdropfadecolorb
local unitFrameColorR, unitFrameColorG, unitFrameColorB
local rgbValueColorR, rgbValueColorG, rgbValueColorB
local bordercolorr, bordercolorg, bordercolorb

local r, g, b = unpack(E["media"].rgbvaluecolor)

MERS.NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
MERS.TRIVIAL_QUEST_DISPLAY = TRIVIAL_QUEST_DISPLAY:gsub("000000", "ffffff")
TEXTURE_ITEM_QUEST_BANG = [[Interface\AddOns\ElvUI_MerathilisUI\media\textures\UI-Icon-QuestBang]]

local buttons = {
	"UI-Panel-MinimizeButton-Disabled",
	"UI-Panel-MinimizeButton-Up",
	"UI-Panel-SmallerButton-Up",
	"UI-Panel-BiggerButton-Up",
}

-- Depends on the arrow texture to be down by default.
MERS.ArrowRotation = {
	['UP'] = 3.14,
	['DOWN'] = 0,
	['LEFT'] = -1.57,
	['RIGHT'] = 1.57,
}

function MERS:ReskinEditBox(frame)
	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	-- Reaply transparent backdrop
	frame:CreateBackdrop("Transparent")
	MERS:CreateGradient(frame.backdrop)
end

function MERS:ReskinDropDownBox(frame, width)
	local button = _G[frame:GetName().."Button"]
	if not button then return end

	if not width then width = 155 end

	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	if not frame.bg then
		local bg = MERS:CreateBDFrame(frame)
		bg:Point("TOPLEFT", 20, -2)
		bg:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		bg:Width(width)
		bg:SetFrameLevel(frame:GetFrameLevel())
		MERS:CreateGradient(bg)

		frame.bg = bg
	end
end

function S:HandleDropDownFrame(frame, width)
	if not width then width = 155 end

	local left = frame.Left
	local middle = frame.Middle
	local right = frame.Right
	if left then
		left:SetAlpha(0)
		left:SetSize(25, 64)
		left:SetPoint("TOPLEFT", 0, 17)
	end
	if middle then
		middle:SetAlpha(0)
		middle:SetHeight(64)
	end
	if right then
		right:SetAlpha(0)
		right:SetSize(25, 64)
	end

	local button = frame.Button
	if button then
		button:SetSize(24, 24)
		button:ClearAllPoints()
		button:Point("RIGHT", right, "RIGHT", -20, 1)

		button.NormalTexture:SetTexture("")
		button.PushedTexture:SetTexture("")
		button.HighlightTexture:SetTexture("")

		hooksecurefunc(button, "SetPoint", function(btn, _, _, _, _, _, noReset)
			if not noReset then
				btn:ClearAllPoints()
				btn:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-20), E:Scale(1), true)
			end
		end)

		self:HandleNextPrevButton(button, true)
	end

	local disabled = button and button.DisabledTexture
	if disabled then
		disabled:SetAllPoints(button)
		disabled:SetColorTexture(0, 0, 0, .3)
		disabled:SetDrawLayer("OVERLAY")
	end

	if middle and (not frame.noResize) then
		frame:SetWidth(40)
		middle:SetWidth(width)
	end

	if right and frame.Text then
		frame.Text:SetSize(0, 10)
		frame.Text:SetPoint("RIGHT", right, -43, 2)
	end

	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	if not frame.bg then
		local bg = MERS:CreateBDFrame(frame)
		bg:SetPoint("TOPLEFT", left, 20, -21)
		bg:SetPoint("BOTTOMRIGHT", right, -19, 23)
		bg:SetFrameLevel(frame:GetFrameLevel())
		bg:Width(width)
		MERS:CreateGradient(bg)

		frame.bg = bg
	end
end

-- Create shadow for textures
function MERS:CreateSD(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 5
	sd.offset = offset or 0
	sd:SetBackdrop({
		bgFile =  E.LSM:Fetch("background", "ElvUI Blank"),
		edgeFile = E.LSM:Fetch("border", "ElvUI GlowBorder"),
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetBackdropColor(r or 0, g or 0, b or 0, alpha or 0)

	return sd
end

function MERS:CreateBG(frame)
	assert(frame, "doesn't exist!")

	local f = frame
	if frame:IsObjectType('Texture') then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:Point("TOPLEFT", frame, -E.mult, E.mult)
	bg:Point("BOTTOMRIGHT", frame, E.mult, -E.mult)
	bg:SetTexture(E["media"].blankTex)
	bg:SetSnapToPixelGrid(false)
	bg:SetTexelSnappingBias(0)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- Gradient Frame
function MERS:CreateGF(f, w, h, o, r, g, b, a1, a2)
	assert(f, "doesn't exist!")

	f:SetSize(w, h)
	f:SetFrameStrata("BACKGROUND")
	local gf = f:CreateTexture(nil, "BACKGROUND")
	gf:SetPoint("TOPLEFT", f, -E.mult, E.mult)
	gf:SetPoint("BOTTOMRIGHT", f, E.mult, -E.mult)
	gf:SetTexture(E["media"].muiNormTex)
	gf:SetVertexColor(r, g, b)
	gf:SetSnapToPixelGrid(false)
	gf:SetTexelSnappingBias(0)
	gf:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

-- Gradient Texture
function MERS:CreateGradient(f)
	assert(f, "doesn't exist!")

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture([[Interface\AddOns\ElvUI_MerathilisUI\media\textures\gradient.tga]])
	tex:SetVertexColor(.3, .3, .3, .15)
	tex:SetSnapToPixelGrid(false)
	tex:SetTexelSnappingBias(0)

	return tex
end

function MERS:CreateBackdrop(frame)
	if frame.backdrop then return end

	local parent = frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent() or frame

	local backdrop = CreateFrame("Frame", nil, parent)
	backdrop:SetOutside(frame)
	backdrop:SetTemplate("Transparent")

	if (parent:GetFrameLevel() - 1) >= 0 then
		backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		backdrop:SetFrameLevel(0)
	end

	frame.backdrop = backdrop
end

function MERS:CreateBDFrame(f, a, left, right, top, bottom)
	assert(f, "doesn't exist!")

	local frame
	if f:IsObjectType('Texture') then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, left or -1, top or 1)
	bg:SetPoint("BOTTOMRIGHT", f, right or 1, bottom or -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	MERS:CreateBD(bg, a or .5)

	return bg
end

function MERS:CreateBD(f, a)
	assert(f, "doesn't exist!")

	f:SetBackdrop({
		bgFile = E["media"].normTex,
		edgeFile = E["media"].normTex,
		edgeSize = E.mult*1.1, -- latest Pixel Stuff changes 10.02.2019
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})

	f:SetBackdropColor(backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, a or alpha)
	f:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
end

-- ClassColored ScrollBars
local function GrabScrollBarElement(frame, element)
	local FrameName = frame:GetDebugName()
	return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

function MERS:ReskinScrollBar(frame, thumbTrimY, thumbTrimX)
	local parent = frame:GetParent()

	local ScrollUpButton = GrabScrollBarElement(frame, 'ScrollUpButton') or GrabScrollBarElement(frame, 'UpButton') or GrabScrollBarElement(frame, 'ScrollUp') or GrabScrollBarElement(parent, 'scrollUp')
	local ScrollDownButton = GrabScrollBarElement(frame, 'ScrollDownButton') or GrabScrollBarElement(frame, 'DownButton') or GrabScrollBarElement(frame, 'ScrollDown') or GrabScrollBarElement(parent, 'scrollDown')
	local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	-- Reapply backdrop
	frame:CreateBackdrop("Transparent")
	frame.backdrop:SetPoint('TOPLEFT', ScrollUpButton or frame, ScrollUpButton and 'BOTTOMLEFT' or 'TOPLEFT', 0, 0)
	frame.backdrop:SetPoint('BOTTOMRIGHT', ScrollDownButton or frame, ScrollUpButton and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 0)
	frame.backdrop:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1)

	if Thumb then
		-- Hide Thumb backdrop
		if Thumb.backdrop then
			Thumb.backdrop:Hide()
		end

		Thumb:CreateBackdrop("Transparent")
		if not thumbTrimY then thumbTrimY = 3 end
		if not thumbTrimX then thumbTrimX = 2 end
		Thumb.backdrop:SetPoint('TOPLEFT', Thumb, 'TOPLEFT', 2, -thumbTrimY)
		Thumb.backdrop:SetPoint('BOTTOMRIGHT', Thumb, 'BOTTOMRIGHT', -thumbTrimX, thumbTrimY)
		Thumb.backdrop:SetFrameLevel(Thumb.backdrop:GetFrameLevel() + 2)
		Thumb.backdrop:SetBackdropColor(unpack(E.media.rgbvaluecolor))
	end
end

-- Overwrite ElvUI Tabs function to be transparent
function MERS:ReskinTab(tab)
	if not tab then return end

	if tab.backdrop then
		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Styling()
	end
end

function MERS:CreateBackdropTexture(f)
	assert(f, "doesn't exist!")
	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetDrawLayer("BACKGROUND", 1)
	tex:SetInside(f, 1, 1)
	tex:SetTexture(E["media"].normTex)
	tex:SetVertexColor(backdropcolorr, backdropcolorg, backdropcolorb)
	tex:SetAlpha(0.8)
	f.backdropTexture = tex
end

function MERS:ColorButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(r, g, b, .3)
	self:SetBackdropBorderColor(r, g, b)
end

function MERS:ClearButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(0, 0, 0, 0)

	if self.isUnitFrameElement then
		self:SetBackdropBorderColor(unitFrameColorR, unitFrameColorG, unitFrameColorB)
	else
		self:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
	end
end

local function StartGlow(f)
	if not f:IsEnabled() then return end
	f:SetBackdropBorderColor(r, g, b)
	f.glow:SetAlpha(1)
	MER:CreatePulse(f.glow)
end

local function StopGlow(f)
	f.glow:SetScript("OnUpdate", nil)
	f:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
	f.glow:SetAlpha(0)
end

-- Buttons
function MERS:Reskin(button, strip, noGlow)
	assert(button, "doesn't exist!")

	if strip then button:StripTextures() end

	if button.template then
		button:SetTemplate("Transparent", true)
	end

	MERS:CreateGradient(button)

	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]]) then
			button.Icon:SetTexture([[Interface\AddOns\ElvUI_MerathilisUI\media\textures\Arrow]])
			button.Icon:SetVertexColor(1, 1, 1)
			button.Icon:SetRotation(MERS.ArrowRotation['RIGHT'])
		end
	end

	if not noGlow then
		button.glow = CreateFrame("Frame", nil, button)
		button.glow:SetBackdrop({
			edgeFile = E.LSM:Fetch("statusbar", "MerathilisFlat"), edgeSize = E:Scale(3),
			insets = {left = E:Scale(3), right = E:Scale(3), top = E:Scale(3), bottom = E:Scale(3)},
		})
		button.glow:SetPoint("TOPLEFT", -1, 1)
		button.glow:SetPoint("BOTTOMRIGHT", 1, -1)
		button.glow:SetBackdropBorderColor(r, g, b)
		button.glow:SetAlpha(0)

		button:HookScript("OnEnter", StartGlow)
		button:HookScript("OnLeave", StopGlow)
	end
end

function MERS:ReskinCheckBox(frame, noBackdrop, noReplaceTextures)
	assert(frame, "does not exist.")

	frame:StripTextures()

	if noBackdrop then
		frame:SetTemplate("Default")
		frame:Size(16)
	else
		MERS:CreateBackdrop(frame)
		frame.backdrop:SetInside(nil, 4, 4)
	end

	if not noReplaceTextures then
		if frame.SetCheckedTexture then
			frame:SetCheckedTexture([[Interface\AddOns\ElvUI\media\textures\melli]])
			frame:GetCheckedTexture():SetVertexColor(1, .82, 0, 0.8)
			frame:GetCheckedTexture():SetInside(frame.backdrop)
		end

		if frame.SetDisabledTexture then
			frame:SetDisabledTexture([[Interface\AddOns\ElvUI\media\textures\melli]])
			frame:GetDisabledTexture():SetVertexColor(1, .82, 0, 0.3)
			frame:GetDisabledTexture():SetInside(frame.backdrop)
		end

		frame:HookScript('OnDisable', function(checkbox)
			if not checkbox.SetDisabledTexture then return; end
			if checkbox:GetChecked() then
				checkbox:SetDisabledTexture([[Interface\AddOns\ElvUI\media\textures\melli]])
				checkbox:GetDisabledTexture():SetVertexColor(1, .82, 0, 0.3)
				checkbox:GetDisabledTexture():SetInside(frame.backdrop)
			else
				checkbox:SetDisabledTexture("")
			end
		end)
	end
end

function MERS:StyleButton(button)
	if button.isStyled then return end

	if button.SetHighlightTexture then
		button:SetHighlightTexture(E["media"].blankTex)
		button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)
		button:GetHighlightTexture():SetInside()
		button.SetHighlightTexture = E.noop
	end

	if button.SetPushedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetPushedTexture():SetVertexColor(.9, .8, .1, .5)
		button:GetPushedTexture():SetInside()
		button.SetPushedTexture = E.noop
	end

	if button.GetCheckedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetCheckedTexture():SetVertexColor(0, 1, 0, .5)
		button:GetCheckedTexture():SetInside()
		button.GetCheckedTexture = E.noop
	end

	local Cooldown = button:GetName() and _G[button:GetName()..'Cooldown'] or button.Cooldown or button.cooldown or nil

	if Cooldown then
		Cooldown:SetInside()
		if Cooldown.SetSwipeColor then
			Cooldown:SetSwipeColor(0, 0, 0, 1)
		end
	end

	button.isStyled = true
end

function MERS:ReskinIcon(icon, backdrop)
	assert(icon, "doesn't exist!")

	icon:SetTexCoord(unpack(E.TexCoords))
	if backdrop then
		MERS:CreateBackdrop(icon)
	end
end

function MERS:SkinPanel(panel)
	panel.tex = panel:CreateTexture(nil, "ARTWORK")
	panel.tex:SetAllPoints()
	panel.tex:SetTexture(E.LSM:Fetch("statusbar", "MerathilisFlat"))
	panel.tex:SetGradient("VERTICAL", unpack(E["media"].rgbvaluecolor))
	MERS:CreateSD(panel, 2, 0, 0, 0, 0, -1)
end

function MERS:ReskinGarrisonPortrait(self)
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = MERS:CreateBDFrame(self, 1)
	self.squareBG:SetFrameLevel(self:GetFrameLevel())
	self.squareBG:SetPoint("TOPLEFT", 3, -3)
	self.squareBG:SetPoint("BOTTOMRIGHT", -3, 11)

	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

function MERS:SkinRadioButton(button)
	if button.IsSkinned then return; end

	button:SetCheckedTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\RadioCircleChecked")
	button:GetCheckedTexture():SetVertexColor(unpack(E["media"].rgbvaluecolor))
	button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)

	button:SetHighlightTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\RadioCircleChecked")
	button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
	button:GetHighlightTexture():SetVertexColor(0, 192, 250, 1)

	button:SetNormalTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\Textures\\RadioCircle")
	button:GetNormalTexture():SetOutside()
	button:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
	button:GetNormalTexture():SetVertexColor(unpack(E["media"].bordercolor))

	button:HookScript("OnDisable", function(self)
		if not self.SetDisabledTexture then return end

		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\Textures\\RadioCircle")
			self:GetDisabledTexture():SetVertexColor(0, 192, 250, 1)
		else
			self:SetDisabledTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\Textures\\RadioCircle")
			self:GetDisabledTexture():SetVertexColor(unpack(E["media"].bordercolor))
		end
	end)

	button.SetNormalTexture = MER.dummy
	button.SetPushedTexture = MER.dummy
	button.SetHighlightTexture = MER.dummy
	button.isSkinned = true
end

local buttons = {
	"ElvUIMoverNudgeWindowUpButton",
	"ElvUIMoverNudgeWindowDownButton",
	"ElvUIMoverNudgeWindowLeftButton",
	"ElvUIMoverNudgeWindowRightButton",
}

local function replaceConfigArrows(button)
	-- remove the default icons
	local tex = _G[button:GetName().."Icon"]
	if tex then
		tex:SetTexture(nil)
	end

	-- add the new icon
	if not button.img then
		button.img = button:CreateTexture(nil, 'ARTWORK')
		button.img:SetTexture('Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\arrow')
		button.img:SetSize(12, 12)
		button.img:Point('CENTER')
		button.img:SetVertexColor(1, 1, 1)

		button:HookScript('OnMouseDown', function(btn)
			if btn:IsEnabled() then
				btn.img:Point("CENTER", -1, -1);
			end
		end)

		button:HookScript('OnMouseUp', function(btn)
			btn.img:Point("CENTER", 0, 0);
		end)
	end
end

function MERS:ApplyConfigArrows()
	for _, btn in pairs(buttons) do
		replaceConfigArrows(_G[btn])
	end

	-- Apply the rotation
	_G["ElvUIMoverNudgeWindowUpButton"].img:SetRotation(MERS.ArrowRotation['UP'])
	_G["ElvUIMoverNudgeWindowDownButton"].img:SetRotation(MERS.ArrowRotation['DOWN'])
	_G["ElvUIMoverNudgeWindowLeftButton"].img:SetRotation(MERS.ArrowRotation['LEFT'])
	_G["ElvUIMoverNudgeWindowRightButton"].img:SetRotation(MERS.ArrowRotation['RIGHT'])

end
hooksecurefunc(E, "CreateMoverPopup", MERS.ApplyConfigArrows)

function MERS:ReskinAS(AS)
	-- Reskin AddOnSkins
	function AS:SkinTab(Tab, Strip)
		if Tab.isSkinned then return end
		local TabName = Tab:GetName()

		if TabName then
			for _, Region in pairs(S.Blizzard.Regions) do
				if _G[TabName..Region] then
					_G[TabName..Region]:SetTexture(nil)
				end
			end
		end

		for _, Region in pairs(S.Blizzard.Regions) do
			if Tab[Region] then
				Tab[Region]:SetAlpha(0)
			end
		end

		if Tab.GetHighlightTexture and Tab:GetHighlightTexture() then
			Tab:GetHighlightTexture():SetTexture(nil)
		else
			Strip = true
		end

		if Strip then
			AS:StripTextures(Tab)
		end

		AS:CreateBackdrop(Tab)

		if AS:CheckAddOn("ElvUI") and AS:CheckOption("ElvUISkinModule") then
			-- Check if ElvUI already provides the backdrop. Otherwise we have two backdrops (e.g. Auctionhouse)
			if Tab.backdrop then
				Tab.Backdrop:Hide()
			else
				AS:SetTemplate(Tab.Backdrop, "Transparent") -- Set it to transparent
				Tab.Backdrop:Styling()
			end
		end

		Tab.Backdrop:Point("TOPLEFT", 10, AS.PixelPerfect and -1 or -3)
		Tab.Backdrop:Point("BOTTOMRIGHT", -10, 3)

		Tab.isSkinned = true
	end
end

-- Replace the Recap button script re-set function
function S:UpdateRecapButton()
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript("OnEnter", MERS.ColorButton)
		self.button4:SetScript("OnLeave", MERS.ClearButton)
	end
end

--[[ HOOK TO THE UIWIDGET TYPES ]]
function MERS:ReskinSkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text;
	if text then
		text:SetTextColor(1, 1, 1)
	end
end

-- hook the skin functions
hooksecurefunc(S, "HandleEditBox", MERS.ReskinEditBox)
hooksecurefunc(S, "HandleDropDownBox", MERS.ReskinDropDownBox)
hooksecurefunc(S, "HandleTab", MERS.ReskinTab)
hooksecurefunc(S, "HandleButton", MERS.Reskin)
hooksecurefunc(S, "HandleCheckBox", MERS.ReskinCheckBox)
hooksecurefunc(S, "HandleScrollBar", MERS.ReskinScrollBar)
-- New Widget Types
hooksecurefunc(S, "SkinTextWithStateWidget", MERS.ReskinSkinTextWithStateWidget)

local function ReskinVehicleExit()
	local f = _G["LeaveVehicleButton"]
	if f then
		f:SetNormalTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\arrow")
		f:SetPushedTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\arrow")
		f:SetHighlightTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\arrow")
	end
end

-- keep the colors updated
local function updateMedia()
	rgbValueColorR, rgbValueColorG, rgbValueColorB = unpack(E["media"].rgbvaluecolor)
	unitFrameColorR, unitFrameColorG, unitFrameColorB = unpack(E["media"].unitframeBorderColor)
	backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, alpha = unpack(E["media"].backdropfadecolor)
	backdropcolorr, backdropcolorg, backdropcolorb = unpack(E["media"].backdropcolor)
	bordercolorr, bordercolorg, bordercolorb = unpack(E["media"].bordercolor)
end
hooksecurefunc(E, "UpdateMedia", updateMedia)

local function pluginInstaller()
	local PluginInstallFrame = _G["PluginInstallFrame"]
	if PluginInstallFrame then
		PluginInstallFrame:Styling()
		PluginInstallTitleFrame:Styling()
	end
end

function MERS:Initialize()
	self.db = E.private.muiSkins

	ReskinVehicleExit()
	updateMedia()
	pluginInstaller()

	if IsAddOnLoaded("AddOnSkins") then
		if AddOnSkins then
			MERS:ReskinAS(unpack(AddOnSkins))
		end
	end
end

local function InitializeCallback()
	MERS:Initialize()
end

MER:RegisterModule(MERS:GetName(), InitializeCallback)
