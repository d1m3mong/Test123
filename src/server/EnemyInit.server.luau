local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyClassModule = require(ReplicatedStorage.Shared.Folder.EnemyClass)

local GoblinModel = ReplicatedStorage.Models.Goblin

local AliveEnemies = {}

while task.wait(5) do
	local EnemyClass = EnemyClassModule.new("Goblin", 20, 4, GoblinModel)
	table.insert(AliveEnemies, EnemyClass)

	EnemyClass:Spawn(CFrame.new(10, 4, 3))

	for _, enemy in AliveEnemies do
		enemy:takeDamage(1000)
	end
end
