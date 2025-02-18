local MER, F, E, L, V, P, G = unpack(ElvUI_MerathilisUI)
local module = MER.Modules.Skins
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not module:CheckDB("orderhall", "orderhall") then
		return
	end

	local OrderHallTalentFrame = _G.OrderHallTalentFrame
	if not OrderHallTalentFrame.backdrop then
		OrderHallTalentFrame:CreateBackdrop('Transparent')
	end
	OrderHallTalentFrame.backdrop:Styling()
	module:CreateBackdropShadow(OrderHallTalentFrame)

	if OrderHallTalentFrame.SetTemplate then
		OrderHallTalentFrame.SetTemplate = nil
	end

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
		if self.talentRankPool then
			for rank in self.talentRankPool:EnumerateActive() do
				if not rank.styled then
					rank.Background:SetAlpha(0)
					rank.styled = true
				end
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_OrderHallUI", LoadSkin)
