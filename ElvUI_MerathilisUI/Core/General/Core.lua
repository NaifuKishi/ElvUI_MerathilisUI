local MER, F, E, L, V, P, G = unpack(select(2, ...))

local _G = _G
local format = string.format
local print, pairs = print, pairs
local pcall = pcall
local tinsert = table.insert

MER.dummy = function() return end
MER.Title = format("|cffffffff%s|r|cffff7d0a%s|r ", "Merathilis", "UI")
MER.ElvUIV = tonumber(E.version)
MER.ElvUIX = tonumber(GetAddOnMetadata("ElvUI_MerathilisUI", "X-ElvVersion"))

-- Masque support
MER.MSQ = _G.LibStub('Masque', true)

MER.Logo = [[Interface\AddOns\ElvUI_MerathilisUI\Core\Media\Textures\mUI.tga]]
MER.LogoSmall = [[Interface\AddOns\ElvUI_MerathilisUI\Core\Media\Textures\mUI1.tga]]

--Info Color RGB: 0, 192, 250
MER.InfoColor = "|cFF00c0fa"
MER.GreyColor = "|cffB5B5B5"
MER.RedColor = "|cffff2735"
MER.GreenColor = "|cff3a9d36"

MER.LineString = MER.GreyColor.."---------------"

MER.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
MER.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
MER.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

MER.RegisteredModules = {}

_G.BINDING_HEADER_MER = "|cffff7d0aMerathilisUI|r"
for i = 1, 5 do
	_G["BINDING_HEADER_AUTOBUTTONBAR"..i] = L["Auto Button Bar"..' '..i]
	for j = 1, 12 do
		_G[format("BINDING_NAME_CLICK AutoButtonBar%dButton%d:LeftButton", i, j)] = L["Button"] .. " " .. j
	end
end

-- Register own Modules
function MER:RegisterModule(name)
	if not name then
		F.DebugMessage(MER, "The name of module is required!")
		return
	end
	if self.initialized then
		self:GetModule(name):Initialize()
	else
		tinsert(self.RegisteredModules, name)
	end
end

function MER:InitializeModules()
	for _, moduleName in pairs(MER.RegisteredModules) do
		local module = self:GetModule(moduleName)
		if module.Initialize then
			pcall(module.Initialize, module)
		end
	end
end

function MER:UpdateModules()
	self:UpdateScripts()
	for _, moduleName in pairs(self.RegisteredModules) do
		local module = MER:GetModule(moduleName)
		if module.ProfileUpdate then
			pcall(module.ProfileUpdate, module)
		end
	end
end

function MER:AddMoverCategories()
	tinsert(E.ConfigModeLayouts, #(E.ConfigModeLayouts) + 1, "MERATHILISUI")
	E.ConfigModeLocalizedStrings["MERATHILISUI"] = format("|cffff7d0a%s |r", "MerathilisUI")
end

function MER:CheckElvUIVersion()
	-- ElvUI versions check
	if MER.ElvUIV < MER.ElvUIX then
		E:StaticPopup_Show("VERSION_MISMATCH")
		return false-- If ElvUI Version is outdated stop right here. So things don't get broken.
	end
	return true
end

function MER:CheckInstalledVersion()
	if InCombatLockdown() then
		return
	end

	if self.showChangeLog then
		MER:ToggleChangeLog()
	end

	local icon = F.GetIconString(MER.Media.Textures.pepeSmall, 14)
	if E.db.mui.installed and E.private.mui.core.LoginMsg then
		print(icon..''..MER.Title..format("v|cff00c0fa%s|r", MER.Version)..L[" is loaded. For any issues or suggestions, please visit "]..F.PrintURL("https://github.com/Merathilis/ElvUI_MerathilisUI/issues"))
	end
end