-- EnemyTypes.luau

export type EnemyStates = "Idle" | "Chasing" | "Attacking" | "Running"

export type LootEntry = {
	weight: number,
	itemType: string,
	pictureId: string,
	amount: number?,
}

export type LootPool = { [string]: LootEntry }

export type EnemyLoot = { [string]: LootPool }

export type Enemy = {
	name: string,
	health: number,
	damage: number,
	range: number,
	enemyModel: Model,
	spawnedModel: Model?,
	lootTable: LootPool,
}

export type Modifier = {
	name: string,
	rarity: string,
	statModifier: { [string]: number },
	effect: (() -> ())?,
	visualEffect: (() -> ())?,
}

export type ModifierData = { [string]: Modifier }

export type EnemyLootTableModifiers = {
	modifiers: { [string]: Modifier },
}

export type StateManager = {
	currentState: EnemyStates,
	enemy: Enemy,
}

export type EnemyMove = {
	enemy: Enemy,
	target: Vector3,
	MaximumRadius: number,
}

export type EnemyAttack = {
	enemy: Enemy,
}

return {}
