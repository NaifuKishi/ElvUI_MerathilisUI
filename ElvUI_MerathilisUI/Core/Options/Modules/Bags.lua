local MER, F, E, L, V, P, G = unpack(select(2, ...))
local options = MER.options.modules.args
local module = MER:GetModule('MER_Bags')
local MERBI = MER:GetModule('MER_BagInfo')

local function updateBagSortOrder()
	SetSortBagsRightToLeft(E.db.mui.bags.BagSortMode == 1)
end

options.bags = {
	type = "group",
	name = L["Bags"],
	-- hidden = not E.Retail,
	args = {
		header = {
			order = 1,
			type = "header",
			name = F.cOption(L["Bags"], 'orange'),
		},
		Enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
			width = "full",
		},
		spacer = {
			order = 3,
			type = "description",
			name = "",
		},
		ItemFilter = {
			order = 4,
			type = "multiselect",
			name = L["Item Filter"],
			get = function(_, key) return E.db.mui.bags[key] end,
			set = function(_, key, value) E.db.mui.bags[key] = value; module:UpdateAllBags() end,
			values = {
				FilterJunk = L["Junk"],
				FilterConsumable = L["Consumable"],
				FilterAzerite = L["Azerite"],
				FilterEquipment = L["Equipments"],
				FilterEquipSet = L["EquipSets"],
				FilterLegendary = L["Legendarys"],
				FilterCollection = L["Collection"],
				FilterFavourite = L["Favorite"],
				FilterGoods = L["Goods"],
				FilterQuest = L["Quest"],
				FilterAnima = L["Anima"],
				FilterRelic = L["Relic"],
			},
		},
		GatherEmpty = {
			order = 5,
			type = "toggle",
			name = L["Collect Empty Slots"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		SpecialBagsColor = {
			order = 6,
			type = "toggle",
			name = L["Special Bags Color"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		ShowNewItem = {
			order = 7,
			type = "toggle",
			name = L["New Item Glow"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		BagsiLvl = {
			order = 8,
			type = "toggle",
			name = L["Show ItemLevel"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		PetTrash = {
			order = 9,
			type = "toggle",
			name = L["Pet Trash Currencies"],
			desc = L["|nIn patch 9.1, you can buy 3 battle pets by using specific trash items. Keep this enabled, will sort these items into Collection Filter, and won't be sold by auto junk selling."],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		iLvlToShow = {
			order = 10,
			type = "range",
			name = L["ItemLevel Threshold"],
			min = 1, max = 500, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllBags() end,
		},
		BagSortMode = {
			order = 11,
			type = "select",
			name = L["BagSort Mode"],
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; updateBagSortOrder() end,
			values = {
				[1] = L["Forward"],
				[2] = L["Backwards"],
				[3] = DISABLE,
			}
		},
		spacer1 = {
			order = 12,
			type = "description",
			name = "",
		},
		BagsPerRow = {
			order = 13,
			type = "range",
			name = L["Bags per Row"],
			min = 1, max = 20, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllAnchors() end,
		},
		BankPerRow = {
			order = 14,
			type = "range",
			name = L["Bank bags per Row"],
			min = 1, max = 20, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateAllAnchors() end,
		},
		IconSize = {
			order = 15,
			type = "range",
			name = L["Icon Size"],
			min = 20, max = 50, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateBagSize() end,
		},
		FontSize = {
			order = 16,
			type = "range",
			name = L["Font Size"],
			min = 10, max = 50, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateBagSize() end,
		},
		BagsWidth = {
			order = 17,
			type = "range",
			name = L["Bags Width"],
			min = 10, max = 40, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateBagSize() end,
		},
		BankWidth = {
			order = 18,
			type = "range",
			name = L["Bank Width"],
			min = 10, max = 40, step = 1,
			get = function(info) return E.db.mui.bags[info[#info]] end,
			set = function(info, value) E.db.mui.bags[info[#info]] = value; module:UpdateBagSize() end,
		},
		equipManager = {
			order = 20,
			type = "group",
			guiInline = true,
			name = F.cOption(L["Equip Manager"], 'orange'),
			args = {
				equipOverlay = {
					type = "toggle",
					order = 1,
					name = L["Equipment Set Overlay"],
					desc = L["Show the associated equipment sets for the items in your bags (or bank)."],
					disabled = function() return not E.private.bags.enable end,
					get = function(info) return E.db.mui.bags.equipOverlay end,
					set = function(info, value) E.db.mui.bags.equipOverlay = value; MERBI:ToggleSettings(); end,
				},
			},
		},
	},
}

