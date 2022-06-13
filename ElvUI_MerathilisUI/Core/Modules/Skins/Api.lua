local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins
local S = E.Skins
local LSM = E.LSM or E.Libs.LSM

local _G = _G
local assert, pairs, unpack, type = assert, pairs, unpack, type
local strfind = strfind

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local alpha
local backdropcolorr, backdropcolorg, backdropcolorb
local backdropfadecolorr, backdropfadecolorg, backdropfadecolorb
local unitFrameColorR, unitFrameColorG, unitFrameColorB
local rgbValueColorR, rgbValueColorG, rgbValueColorB, rgbValueColorA
local bordercolorr, bordercolorg, bordercolorb

module.ClassColor = _G.RAID_CLASS_COLORS[E.myclass]

module.NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
module.TRIVIAL_QUEST_DISPLAY = TRIVIAL_QUEST_DISPLAY:gsub("000000", "ffffff")

-- Depends on the arrow texture to be down by default.
module.ArrowRotation = {
	['UP'] = 3.14,
	['DOWN'] = 0,
	['LEFT'] = -1.57,
	['RIGHT'] = 1.57,
}

function module:CreateShadow(frame, size, r, g, b, force)
	if not force and not E.private.mui.skins.shadow and E.private.mui.skins.shadow.enable then
		return
	end

	if not frame or frame.__shadow or frame.shadow and frame.shadow.__MER then
		return
	end

	if frame:GetObjectType() == "Texture" then
		frame = frame:GetParent()
	end

	r = r or E.private.mui.skins.shadow.color.r or 0
	g = g or E.private.mui.skins.shadow.color.g or 0
	b = b or E.private.mui.skins.shadow.color.b or 0

	size = size or 3
	size = size + E.private.mui.skins.shadow.increasedSize or 0

	local shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	shadow:SetFrameStrata(frame:GetFrameStrata())
	shadow:SetFrameLevel(frame:GetFrameLevel() or 1)
	shadow:SetOutside(frame, size, size)
	shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = size + 1})
	shadow:SetBackdropColor(r, g, b, 0)
	shadow:SetBackdropBorderColor(r, g, b, 0.618)
	shadow.__MER = true

	frame.shadow = shadow
	frame.__shadow = 1
end

function module:CreateLowerShadow(frame, force)
	if not force then
		if not E.private.mui.skins or not E.private.mui.skins.shadow.enable then
			return
		end
	end

	module:CreateShadow(frame)
	local parentFrameLevel = frame:GetFrameLevel()
	frame.shadow:SetFrameLevel(parentFrameLevel > 0 and parentFrameLevel - 1 or 0)
end

function module:UpdateShadowColor(shadow, r, g, b)
	if not shadow or not shadow.__MER then
		return
	end

	r = r or E.private.mui.skins.shadow.color.r or 0
	g = g or E.private.mui.skins.shadow.color.g or 0
	b = b or E.private.mui.skins.shadow.color.b or 0

	shadow:SetBackdropColor(r, g, b, 0)
	shadow:SetBackdropBorderColor(r, g, b, 0.618)
end

do
	local function colorCallback(shadow, r, g, b)
		if not r or not g or not b then
			return
		end

		if r == E.db.general.bordercolor.r and g == E.db.general.bordercolor.g and b == E.db.general.bordercolor.b then
			module:UpdateShadowColor(shadow)
		else
			module:UpdateShadowColor(shadow, r, g, b)
		end
	end

	function module:BindShadowColorWithBorder(shadow, borderParent)
		if not shadow or not shadow.__MER or not borderParent or not borderParent.SetBackdropBorderColor then
			return
		end

		hooksecurefunc(borderParent, "SetBackdropBorderColor", function(_, ...)
			colorCallback(shadow, ...)
		end)

		colorCallback(shadow, borderParent:GetBackdropBorderColor())
	end
end

do
	local function createBackdropShadow(frame, defaultTemplate)
		if not E.private.mui.skins or not E.private.mui.skins.shadow.enable then
			return
		end

		if not defaultTemplate then
			frame.backdrop:SetTemplate("Transparent")
		end

		module:CreateShadow(frame.backdrop)

		if frame.backdrop.shadow.__mer then
			frame.__shadow = frame.backdrop.__shadow + 1
		end
	end

	--[[
		Create a shadow for the backdrop of the frame
		@param {frame} frame
		@param {string} template
	]]
	function module:CreateBackdropShadow(frame, template)
		if not frame or frame.__shadow then
			return
		end

		if frame.backdrop then
			createBackdropShadow(frame, template)
		elseif frame.CreateBackdrop and not self:IsHooked(frame, "CreateBackdrop") then
			self:SecureHook(frame, "CreateBackdrop", function(...)
				if self:IsHooked(frame, "CreateBackdrop") then
					self:Unhook(frame, "CreateBackdrop")
				end
				createBackdropShadow(...)
			end)
		end
	end

	--[[
	Create shadow of backdrop that created by ElvUI skin functionsp
	The function is automatically repeat several times for waiting ElvUI done
		the modifying/creating of backdrop
	!!! It only check for 2 seconds (20 times in total)
	@param {object} frame
	@param {string} [tried=20] time
]]
	function module:TryCreateBackdropShadow(frame, tried)
		if not frame or frame.__shadow then
			return
		end

		tried = tried or 20

		if frame.backdrop then
			createBackdropShadow(frame)
		else
			if tried >= 0 then
				E:Delay(0.1, self.TryCreateBackdropShadow, self, frame, tried - 1)
			end
		end
	end
end

function module:CreateShadowModule(frame)
	if not frame then return end

	if E.private.mui.skins.enable and E.private.mui.skins.shadow.enable then
		module:CreateShadow(frame)
	end
end

-- Create shadow for textures
function module:CreateSD(f, m, s, n)
	if f.Shadow then return end

	local frame = f
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	end

	local lvl = frame:GetFrameLevel()
	f.Shadow = CreateFrame("Frame", nil, frame)
	f.Shadow:SetPoint("TOPLEFT", f, -m, m)
	f.Shadow:SetPoint("BOTTOMRIGHT", f, m, -m)
	f.Shadow:CreateBackdrop()
	f.Shadow.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
	f.Shadow.backdrop:SetFrameLevel(n or lvl)

	return f.Shadow
end

function module:CreateBG(frame)
	assert(frame, "doesn't exist!")

	local f = frame
	if frame:IsObjectType('Texture') then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:Point("TOPLEFT", frame, -E.mult, E.mult)
	bg:Point("BOTTOMRIGHT", frame, E.mult, -E.mult)
	bg:SetTexture(E.media.normTex)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- Gradient Texture
function module:CreateGradient(f)
	assert(f, "doesn't exist!")

	local tex = f:CreateTexture(nil, "BORDER")
	tex:SetInside()
	tex:SetTexture([[Interface\AddOns\ElvUI_MerathilisUI\Core\Media\Textures\gradient.tga]])
	tex:SetVertexColor(.3, .3, .3, .15)

	return tex
end

function module:CreateBackdrop(frame)
	if frame.backdrop then return end

	local parent = frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent() or frame

	local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	backdrop:SetOutside(frame)
	backdrop:SetTemplate("Transparent")

	if (parent:GetFrameLevel() - 1) >= 0 then
		backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		backdrop:SetFrameLevel(0)
	end

	frame.backdrop = backdrop
end

function module:CreateBDFrame(f, a)
	assert(f, "doesn't exist!")

	local parent = f.IsObjectType and f:IsObjectType("Texture") and f:GetParent() or f

	local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	bg:SetOutside(f)
	if (parent:GetFrameLevel() - 1) >= 0 then
		bg:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		bg:SetFrameLevel(0)
	end
	module:CreateBD(bg, a or .5)

	return bg
end

function module:CreateBD(f, a)
	assert(f, "doesn't exist!")

	f:CreateBackdrop()
	f.backdrop:SetBackdropColor(backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, a or alpha)
	f.backdrop:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
end

-- ClassColored ScrollBars
do
	local function GrabScrollBarElement(frame, element)
		local FrameName = frame:GetDebugName()
		return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
	end

	function module:HandleScrollBar(_, frame, thumbTrimY, thumbTrimX)
		local parent = frame:GetParent()

		local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

		if Thumb and Thumb.backdrop then
			local r, g, b = unpack(E.media.rgbvaluecolor)
			Thumb.backdrop:SetBackdropColor(r, g, b)
		end
	end
end

-- ClassColored Sliders
function module:HandleSliderFrame(_, frame)
	local thumb = frame:GetThumbTexture()
	if thumb then
		local r, g, b = unpack(E.media.rgbvaluecolor)
		thumb:SetVertexColor(r, g, b)
	end
end

function module:ColorButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(rgbValueColorR, rgbValueColorG, rgbValueColorB, .3)
	self:SetBackdropBorderColor(rgbValueColorR, rgbValueColorG, rgbValueColorB)
end

function module:ClearButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(0, 0, 0, 0)

	if self.isUnitFrameElement then
		self:SetBackdropBorderColor(unitFrameColorR, unitFrameColorG, unitFrameColorB)
	else
		self:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
	end
end

function module:ReskinIcon(icon, backdrop)
	assert(icon, "doesn't exist!")

	icon:SetTexCoord(unpack(E.TexCoords))

	if icon:GetDrawLayer() ~= 'ARTWORK' then
		icon:SetDrawLayer("ARTWORK")
	end

	if backdrop then
		icon:CreateBackdrop()
	end
end

function module:SkinPanel(panel)
	panel.tex = panel:CreateTexture(nil, "ARTWORK")
	panel.tex:SetAllPoints()
	panel.tex:SetTexture(E.media.blankTex)
	panel.tex:SetGradient("VERTICAL", rgbValueColorR, rgbValueColorG, rgbValueColorB)
	module:CreateShadow(panel)
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
		button.img:SetTexture('Interface\\AddOns\\ElvUI_MerathilisUI\\Core\\Media\\Textures\\arrow')
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

function module:ApplyConfigArrows()
	for _, btn in pairs(buttons) do
		replaceConfigArrows(_G[btn])
	end

	-- Apply the rotation
	_G["ElvUIMoverNudgeWindowUpButton"].img:SetRotation(module.ArrowRotation['UP'])
	_G["ElvUIMoverNudgeWindowDownButton"].img:SetRotation(module.ArrowRotation['DOWN'])
	_G["ElvUIMoverNudgeWindowLeftButton"].img:SetRotation(module.ArrowRotation['LEFT'])
	_G["ElvUIMoverNudgeWindowRightButton"].img:SetRotation(module.ArrowRotation['RIGHT'])

end
hooksecurefunc(E, "CreateMoverPopup", module.ApplyConfigArrows)

do
	local DeleteRegions = {
		"Center",
		"BottomEdge",
		"LeftEdge",
		"RightEdge",
		"TopEdge",
		"BottomLeftCorner",
		"BottomRightCorner",
		"TopLeftCorner",
		"TopRightCorner"
	}
	function module:StripEdgeTextures(frame)
		for _, regionKey in pairs(DeleteRegions) do
			if frame[regionKey] then
				frame[regionKey]:Kill()
			end
		end
	end
end

function module:Reposition(frame, target, border, top, bottom, left, right)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", target, "TOPLEFT", -left - border, top + border)
	frame:SetPoint("TOPRIGHT", target, "TOPRIGHT", right + border, top + border)
	frame:SetPoint("BOTTOMLEFT", target, "BOTTOMLEFT", -left - border, -bottom - border)
	frame:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", right + border, -bottom - border)
end

function module:ReskinTab(tab)
	if not tab then
		return
	end

	if tab.GetName then
		F.SetFontOutline(_G[tab:GetName() .. "Text"])
	end

	self:CreateBackdropShadow(tab)
end

function module:ReskinAS(AS)
	-- Reskin AddOnSkins
	function AS:SkinFrame(frame, template, override, kill)
		local name = frame and frame.GetName and frame:GetName()
		local insetFrame = name and _G[name..'Inset'] or frame.Inset
		local closeButton = name and _G[name..'CloseButton'] or frame.CloseButton

		if not override then
			AS:StripTextures(frame, kill)
		end

		AS:SetTemplate(frame, template)
		module:CreateShadow(frame)

		if insetFrame then
			AS:SkinFrame(insetFrame)
		end

		if closeButton then
			AS:SkinCloseButton(closeButton)
		end
	end

	function AS:SkinBackdropFrame(frame, template, override, kill)
		local name = frame and frame.GetName and frame:GetName()
		local insetFrame = name and _G[name..'Inset'] or frame.Inset
		local closeButton = name and _G[name..'CloseButton'] or frame.CloseButton

		if not override then
			AS:StripTextures(frame, kill)
		end

		AS:CreateBackdrop(frame, template)
		AS:SetOutside(frame.Backdrop)

		if insetFrame then
			AS:SkinFrame(insetFrame)
		end

		if closeButton then
			AS:SkinCloseButton(closeButton)
		end

		if frame.Backdrop then
			module:CreateShadow(frame.Backdrop)
		end
	end

	function AS:SkinTab(Tab, Strip)
		if Tab.__MERSkin then return end
		local TabName = Tab:GetName()

		if TabName then
			for _, Region in pairs(AS.Blizzard.Regions) do
				if _G[TabName..Region] then
					_G[TabName..Region]:SetTexture(nil)
				end
			end
		end

		for _, Region in pairs(AS.Blizzard.Regions) do
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

		AS:CreateBackdrop(Tab, 'Transparent')

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

		Tab.__MERSkin = true
	end

	function AS:SkinButton(Button, Strip)
		if Button.__MERSkin then return end

		local ButtonName = Button.GetName and Button:GetName()
		local foundArrow

		if Button.Icon then
			local Texture = Button.Icon:GetTexture()
			if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
				foundArrow = true
			end
		end

		if Strip then
			AS:StripTextures(Button)
		end

		for _, Region in pairs(AS.Blizzard.Regions) do
			Region = ButtonName and _G[ButtonName..Region] or Button[Region]
			if Region then
				Region:SetAlpha(0)
			end
		end

		if foundArrow then
			Button.Icon:SetTexture([[Interface\AddOns\AddOnSkins\Media\Textures\Arrow]])
			Button.Icon:SetSnapToPixelGrid(false)
			Button.Icon:SetTexelSnappingBias(0)
			Button.Icon:SetVertexColor(1, 1, 1)
			Button.Icon:SetRotation(AS.ArrowRotation['right'])
		end

		if Button.SetNormalTexture then Button:SetNormalTexture('') end
		if Button.SetHighlightTexture then Button:SetHighlightTexture('') end
		if Button.SetPushedTexture then Button:SetPushedTexture('') end
		if Button.SetDisabledTexture then Button:SetDisabledTexture('') end

		AS:SetTemplate(Button, 'Transparent')

		if Button.GetFontString and Button:GetFontString() ~= nil then
			if Button:IsEnabled() then
				Button:GetFontString():SetTextColor(1, 1, 1)
			else
				Button:GetFontString():SetTextColor(.5, .5, .5)
			end
		end

		Button:HookScript("OnEnable", function(self)
			if self.GetFontString and self:GetFontString() ~= nil then
				self:GetFontString():SetTextColor(1, 1, 1)
			end
		end)
		Button:HookScript("OnDisable", function(self)
			if self.GetFontString and self:GetFontString() ~= nil then
				self:GetFontString():SetTextColor(.5, .5, .5)
			end
		end)
	end
end

-- Replace the Recap button script re-set function
function S:UpdateRecapButton()
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript("OnEnter", module.ColorButton)
		self.button4:SetScript("OnLeave", module.ClearButton)
	end
end

--[[ HOOK TO THE UIWIDGET TYPES ]]
function module:SkinTextWithStateWidget(_, widgetFrame)
	local text = widgetFrame.Text
	if text then
		text:SetTextColor(1, 1, 1)
	end
end

function module:DisableAddOnSkin(key)
	if _G.AddOnSkins then
		local AS = _G.AddOnSkins[1]
		if AS and AS.db[key] then
			AS:SetOption(key, false)
		end
	end
end

-- keep the colors updated
function module:UpdateMedia()
	rgbValueColorR, rgbValueColorG, rgbValueColorB, rgbValueColorA = unpack(E.media.rgbvaluecolor)
	unitFrameColorR, unitFrameColorG, unitFrameColorB = unpack(E.media.unitframeBorderColor)
	backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, alpha = unpack(E.media.backdropfadecolor)
	backdropcolorr, backdropcolorg, backdropcolorb = unpack(E.media.backdropcolor)
	bordercolorr, bordercolorg, bordercolorb = unpack(E.media.bordercolor)
end
hooksecurefunc(E, "UpdateMedia", module.UpdateMedia)

-- hook the skin functions from ElvUI
module:SecureHook(S, "HandleScrollBar")
module:SecureHook(S, "SkinTextWithStateWidget")
