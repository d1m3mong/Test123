local EnemyTypes = require(script.Parent.EnemyTypes)
type EnemyLoot = EnemyTypes.EnemyLoot

local EnemyLoot: EnemyLoot = {
	["Goblin"] = {
		["Gold Coin"] = { weight = 1, itemType = "Currency", pictureId = "rbxassetid://12345678" },
		["Wooden Sword"] = { weight = 0.5, itemType = "Weapon", pictureId = "rbxassetid://87654321" },
	},
	["Orc"] = {
		["Gold Coin"] = { weight = 1, itemType = "Currency", pictureId = "rbxassetid://12345678" },
		["Iron Sword"] = { weight = 0.5, itemType = "Weapon", pictureId = "rbxassetid://87654321" },
		["Health Potion"] = { weight = 0.2, itemType = "Consumable", pictureId = "rbxassetid://11111111" },
	},
	["Troll"] = {
		["Gold Coin"] = { weight = 1, itemType = "Currency", pictureId = "rbxassetid://12345678", amount = 10 },
		["Health Potion"] = { weight = 0.2, itemType = "Consumable", pictureId = "rbxassetid://11111111" },
		["Club"] = { weight = 1, itemType = "Weapon", pictureId = "rbxassetid://22222222" },
	},
	["Dragon"] = {
		["Gold Coin"] = { weight = 1, itemType = "Currency", pictureId = "rbxassetid://12345678", amount = 100 },
		["Diamond"] = { weight = 0.5, itemType = "Material", pictureId = "rbxassetid://87654321" },
		["Dragon Scale"] = { weight = 0.3, itemType = "Material", pictureId = "rbxassetid://11111111" },
		["Summing Eye"] = { weight = 0.1, itemType = "Material", pictureId = "rbxassetid://22222222" },
	},
}

return EnemyLoot
