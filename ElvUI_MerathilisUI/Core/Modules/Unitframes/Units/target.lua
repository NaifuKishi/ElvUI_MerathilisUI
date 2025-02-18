local MER, F, E, L, V, P, G = unpack(ElvUI_MerathilisUI)
local module = MER:GetModule('MER_UnitFrames')
local UF = E:GetModule('UnitFrames')

local hooksecurefunc = hooksecurefunc

function module:Update_TargetFrame(frame)
	local db = E.db.mui.unitframes

	-- Only looks good on Transparent
	if E.db.unitframe.colors.transparentHealth then
		if db.style then
			if frame and frame.Health and not frame.__MERSkin then
				frame.Health:Styling(false, true)
				frame.__MERSkin = true
			end
		end
	end

	module:CreateHighlight(frame)
end

function module:InitTarget()
	if not E.db.unitframe.units.target.enable then return end

	hooksecurefunc(UF, "Update_TargetFrame", module.Update_TargetFrame)
end
