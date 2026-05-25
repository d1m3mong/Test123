local ModifierTable = require(script.Parent.ModifierTable)
local EnemyTypes = require(script.Parent.EnemyTypes)
type Modifier = EnemyTypes.Modifier
type EnemyLootTableModifiers = EnemyTypes.EnemyLootTableModifiers

local RARITY_WEIGHTS: { [string]: number } = {
	Common = 60,
	Uncommon = 25,
	Rare = 10,
	Legendary = 5,
}

local EnemyLootTableModifiers = {}
EnemyLootTableModifiers.__index = EnemyLootTableModifiers

function EnemyLootTableModifiers.new(): EnemyLootTableModifiers
	local self = setmetatable({}, EnemyLootTableModifiers)
	self.modifiers = ModifierTable
	return self
end

function EnemyLootTableModifiers:applyModifier(
	modifierName: string,
	lootTable: { [string]: number }
): { [string]: number }
	local modifier = self.modifiers[modifierName]
	if modifier then
		local modified = table.clone(lootTable)
		for stat, multiplier in modifier.statModifier do
			if modified[stat] then
				modified[stat] = math.round(modified[stat] * multiplier)
			end
		end

		return modified
	else
		warn("Modifier not found: " .. modifierName)
		return lootTable
	end
end

function EnemyLootTableModifiers:rollModifier(): Modifier?
	type PoolEntry = { modifier: Modifier, weight: number }
	local pool: { PoolEntry } = {}
	local totalWeight = 0

	for name, modifier in self.modifiers do
		local weight = RARITY_WEIGHTS[modifier.rarity] or 1
		totalWeight += weight
		table.insert(pool, {
			modifier = {
				name = name,
				rarity = modifier.rarity,
				statModifier = modifier.statModifier,
				effect = modifier.effect,
				visualEffect = modifier.visualEffect,
			},
			weight = weight,
		})
	end

	if totalWeight == 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, entry in pool do
		cumulative += entry.weight
		if roll <= cumulative then
			return entry.modifier
		end
	end

	return nil
end

return EnemyLootTableModifiers
