local MER, E, L, V, P, G = unpack(select(2, ...))
local M = E:GetModule("mUIMedia")

local function mediaTable()
	E.Options.args.mui.args.media = {
		type = "group",
		name = L["Media"]..MER.NewSign,
		order = 7,
		childGroups = "tab",
		get = function(info) return E.db.mui.media[ info[#info] ] end,
		disabled = function() return IsAddOnLoaded("ElvUI_SLE") end,
		hidden = function() return IsAddOnLoaded("ElvUI_SLE") end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = MER:cOption(L["Media"]),
			},
			credits = {
				order = 2,
				type = "group",
				name = MER:cOption(L["Credits"]),
				guiInline = true,
				args = {
					tukui = {
						order = 1,
						type = "description",
						fontSize = "medium",
						name = format("|cff9482c9Shadow&Light|r"),
					},
				},
			},
			zonefonts = {
				type = "group",
				name = L["Zone Text"],
				order = 3,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = "",
					},
					test = {
						order = 2,
						type = 'execute',
						name = L["Test"],
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						func = function() M:TextShow() end,
					},
					zone = {
						type = "group",
						name = ZONE,
						order = 3,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.zone[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.zone[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 48, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
							width = {
								order = 4,
								name = L["Width"],
								type = "range",
								min = 512, max = E.eyefinity or E.screenwidth, step = 1,
								set = function(info, value) E.db.mui.media.fonts.zone.width = value; M:TextWidth() end,
							},
						},
					},
					subzone = {
						type = "group",
						name = L["Subzone Text"],
						order = 4,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.subzone[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.subzone[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 48, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
							width = {
								order = 4,
								name = L["Width"],
								type = "range",
								min = 512, max = E.eyefinity or E.screenwidth, step = 1,
								set = function(info, value) E.db.mui.media.fonts.subzone.width = value; M:TextWidth() end,
							},
							offset = {
								order = 5,
								name = L["Offset"],
								type = "range",
								min = 0, max = 30, step = 1,
							},
						},
					},
					pvpstatus = {
						type = "group",
						name = L["PvP Status Text"],
						order = 5,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.pvp[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.pvp[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 48, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
							width = {
								order = 4,
								name = L["Width"],
								type = "range",
								min = 512, max = E.eyefinity or E.screenwidth, step = 1,
								set = function(info, value) E.db.mui.media.fonts.pvp.width = value; M:TextWidth() end,
							},
						},
					},
				},
			},
			miscfonts = {
				type = "group",
				name = L["Misc Texts"],
				order = 4,
				args = {
					mail = {
						type = "group",
						name = L["Mail Text"],
						order = 1,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.mail[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.mail[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								desc = "The font used for letters' body",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 22, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
					editbox = {
						type = "group",
						name = L["Chat Editbox Text"],
						order = 2,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.editbox[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.editbox[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								desc = "The font used for chat editbox",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 20, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
					gossip = {
						type = "group",
						name = L["Gossip and Quest Frames Text"],
						order = 2,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.gossip[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.gossip[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								desc = "The font used for chat editbox",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 20, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
					questHeader = {
						type = "group",
						name = L["Objective Tracker Header Text"],
						order = 3,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.objectiveHeader[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.objectiveHeader[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								desc = "The font used for chat editbox",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 20, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
					questTracker = {
						type = "group",
						name = L["Objective Tracker Text"],
						order = 4,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.objective[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.objective[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = "LSM30_Font",
								order = 1,
								name = L["Font"],
								desc = "The font used for chat editbox",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 20, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
					questFontSuperHuge = {
						type = "group",
						name = L["Banner Big Text"],
						order = 5,
						guiInline = true,
						disabled = function() return not E.private.general.replaceBlizzFonts end,
						get = function(info) return E.db.mui.media.fonts.questFontSuperHuge[ info[#info] ] end,
						set = function(info, value) E.db.mui.media.fonts.questFontSuperHuge[ info[#info] ] = value; E:UpdateMedia() end,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["Font"],
								desc = "The font used for chat editbox",
								values = AceGUIWidgetLSMlists.font,
							},
							size = {
								order = 2,
								name = L["Font Size"],
								type = "range",
								min = 6, max = 48, step = 1,
							},
							outline = {
								order = 3,
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								type = "select",
								values = {
									["NONE"] = L["None"],
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE",
								},
							},
						},
					},
				},
			},
		},
	}
end
tinsert(MER.Config, mediaTable)