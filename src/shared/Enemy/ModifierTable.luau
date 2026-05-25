-- ModifierTable.lua

export type Modifier = {
	rarity: string,
	statModifier: { [string]: number },
	effect: (() -> ())?,
	visualEffect: (() -> ())?,
}

export type ModifierData = { [string]: Modifier }

local ModifierTable: ModifierData = {
	["Strong"] = {
		rarity = "Common",
		statModifier = {
			damage = 1.2,
		},
	},

	["Fast"] = {
		rarity = "Uncommon",
		statModifier = {
			attackSpeed = 1.2,
		},
	},

	["Conjuring"] = {
		rarity = "Rare",
		statModifier = {
			range = 1.2,
		},
	},

	["Explosive"] = {
		rarity = "Rare",
		statModifier = {
			damage = 1.5,
			attackSpeed = 0.8,
		},
		effect = function()
			print("Explosion effect triggered!")
		end,
	},

	["Invisible"] = {
		rarity = "Rare",
		statModifier = {
			speed = 1.5,
			damage = 1.1,
		},
		visualEffect = function()
			print("Invisibility effect triggered!")
		end,
		effect = function()
			print("Invisible effect triggered!")
		end,
	},
}

return ModifierTable
