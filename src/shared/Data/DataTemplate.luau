local Template = {
	Money = 0,
	Level = 1,
	XP = 0,

	Inventory = {
		{ id = "IronSword", quantity = 1, rarity = "Common", damage = 10 },
		{ id = "HealthPotion", quantity = 5, rarity = "Uncommon", heal = 20 },
	},

	Stats = {
		TimePlayed = 0,
		Deaths = 0,
	},

	Timestamps = {
		FirstJoined = nil,
		LastJoined = nil,
	},
}

return Template
