export type LootEntry = { Weight: number, Amount: number? } | { number }

export type LootPool = { [string]: LootEntry }

export type Enemy = { [string]: LootPool }

local EnemyLoot: Enemy = {
	["Goblin"] = {
		["Gold Coin"] = { 1 },
	},
	["Orc"] = {
		["Gold Coin"] = { 1 },
		["Iron Sword"] = { 0.5 },
	},
	["Troll"] = {
		["Gold Coin"] = { Weight = 1, Amount = 10 },
		["Health Potion"] = { 0.2 },
	},
	["Dragon"] = {
		["Gold Coin"] = { Weight = 1, Amount = 100 },
		["Diamond"] = { 0.5 },
		["Dragon Scale"] = { 0.3 },
		["Summing Eye"] = { 0.1 },
	},
}

return EnemyLoot
