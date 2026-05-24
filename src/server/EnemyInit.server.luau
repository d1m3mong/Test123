local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyClassModule = require(ReplicatedStorage.Shared.Folder.EnemyClass)
local EnemyStateModule = require(ReplicatedStorage.Shared.Folder.EnemyStateModule)

local AliveEnemies = {}

local function SelectEnemy()
	local EnemyCount = #ReplicatedStorage.Models:GetChildren()
	local RandomIndex = math.random(1, EnemyCount)

	return ReplicatedStorage.Models:GetChildren()[RandomIndex]
end

local function RandomSpawnLocationCFrame()
	local SpawnLocationCount = #workspace.Map.SpawnLocations:GetChildren()
	local RandomIndex = math.random(1, SpawnLocationCount)

	return workspace.Map.SpawnLocations:GetChildren()[RandomIndex].CFrame
end

task.spawn(function()
	while true do
		local enemyModel = SelectEnemy()
		local enemyData = ReplicatedStorage.EnemyData:FindFirstChild(enemyModel.Name)

		if enemyData then
			local enemy = EnemyClassModule.new(enemyData, enemyModel)
			enemy:Spawn(RandomSpawnLocationCFrame())
			table.insert(AliveEnemies, enemy)
		end

		task.wait(5)
	end
end)
