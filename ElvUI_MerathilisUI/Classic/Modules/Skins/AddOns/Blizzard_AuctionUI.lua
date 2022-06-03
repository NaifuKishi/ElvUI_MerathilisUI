local MER, F, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true or not E.private.mui.skins.blizzard.auctionhouse then return end

	local AuctionFrame = _G.AuctionFrame
	if AuctionFrame.backdrop then
		AuctionFrame.backdrop:Styling()
	end
	MER:CreateBackdropShadow(AuctionFrame)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", LoadSkin)
