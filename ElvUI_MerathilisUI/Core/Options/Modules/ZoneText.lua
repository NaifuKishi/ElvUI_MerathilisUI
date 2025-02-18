local MER, F, E, L, V, P, G = unpack(ElvUI_MerathilisUI)
local options = MER.options.media.args
local module = MER:GetModule('MER_ZoneText')
local LSM = E.LSM

options.general = {
	order = 1,
	type = "group",
	name = L["General"],
	childGroups = "tab",
	args = {
		header = {
			order = 1,
			type = "header",
			name = F.cOption(L["Media"], 'orange'),
		},
		credits = {
			order = 2,
			type = "group",
			name = F.cOption(L["Credits"], 'orange'),
			guiInline = true,
			args = {
				tukui = {
					order = 1,
					type = "description",
					fontSize = "medium",
					name = format("|cff9482c9Shadow & Light - Darth Predator|r"),
				},
			},
		},
		zoneText = {
			type = "group",
			name = L["Zone Text"],
			order = 3,
			get = function(info) return E.db.mui.media.zoneText[ info[#info] ] end,
			set = function(info, value) E.db.mui.media.zoneText[ info[#info] ] = value; E:UpdateMedia() end,
			args = {
				intro = {
					order = 0,
					type = "description",
					name = "",
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				test = {
					order = 2,
					type = 'execute',
					name = L["Test"],
					disabled = function() return not E.private.general.replaceBlizzFonts or not E.db.mui.media.zoneText.enable end,
					func = function() module:TextShow() end,
				},
				zone = {
					type = "group",
					name = ZONE,
					order = 3,
					guiInline = true,
					get = function(info) return E.db.mui.media.zoneText.zone[ info[#info] ] end,
					set = function(info, value) E.db.mui.media.zoneText.zone[ info[#info] ] = value; E:UpdateMedia() end,
					disabled = function() return not E.private.general.replaceBlizzFonts or not E.db.mui.media.zoneText.enable end,
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = LSM:HashTable("font"),
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
				subzone = {
					type = "group",
					name = L["Subzone Text"],
					order = 4,
					guiInline = true,
					get = function(info) return E.db.mui.media.zoneText.subzone[ info[#info] ] end,
					set = function(info, value) E.db.mui.media.zoneText.subzone[ info[#info] ] = value; E:UpdateMedia() end,
					disabled = function() return not E.private.general.replaceBlizzFonts or not E.db.mui.media.zoneText.enable end,
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = LSM:HashTable("font"),
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
				pvp = {
					type = "group",
					name = L["PvP Status Text"],
					order = 5,
					guiInline = true,
					get = function(info) return E.db.mui.media.zoneText.pvp[ info[#info] ] end,
					set = function(info, value) E.db.mui.media.zoneText.pvp[ info[#info] ] = value; E:UpdateMedia() end,
					disabled = function() return not E.private.general.replaceBlizzFonts or not E.db.mui.media.zoneText.enable end,
					args = {
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = LSM:HashTable("font"),
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
		miscText = {
			type = "group",
			name = L["Misc Texts"],
			order = 4,
			get = function(info) return E.db.mui.media.miscText[ info[#info] ] end,
			set = function(info, value) E.db.mui.media.miscText[ info[#info] ] = value; E:UpdateMedia() end,
			args = {
				mail = {
					type = "group",
					name = L["Mail Text"],
					order = 1,
					guiInline = true,
					disabled = function() return not E.private.general.replaceBlizzFonts end,
					get = function(info) return E.db.mui.media.miscText.mail[ info[#info] ] end,
					set = function(info, value) E.db.mui.media.miscText.mail[ info[#info] ] = value; E:UpdateMedia() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
						},
						font = {
							type = "select", dialogControl = "LSM30_Font",
							order = 1,
							name = L["Font"],
							values = LSM:HashTable("font"),
							disabled = function() return not E.db.mui.media.miscText.mail.enable end,
						},
						size = {
							order = 2,
							name = L["Font Size"],
							type = "range",
							min = 6, max = 22, step = 1,
							disabled = function() return not E.db.mui.media.miscText.mail.enable end,
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
							disabled = function() return not E.db.mui.media.miscText.mail.enable end,
						},
					},
				},
			},
		},
	},
}
