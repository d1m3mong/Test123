local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyClassModule = require(ReplicatedStorage.Shared.Enemy.EnemyClass)
local EnemyStateModule = require(ReplicatedStorage.Shared.Enemy.EnemyStateModule)

local AliveEnemies = {}
local EnemyStateActive = {}

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
		local enemyData = ReplicatedStorage.Shared.EnemyConfig:FindFirstChild(enemyModel.Name)

		if enemyData then
			local data = require(enemyData).Data
			local spawnCFrame = RandomSpawnLocationCFrame()
			local enemy = EnemyClassModule.new(data, enemyModel)
			enemy:Spawn(spawnCFrame)
			local enemyState = EnemyStateModule.new(enemy)

			table.insert(AliveEnemies, { enemy = enemy, state = enemyState })
		end

		task.wait(5)
	end
end)

local function TriggerRandomEnemyEvent(event: string, args: any?)
	if #EnemyStateActive > 0 then
		local randomIndex = math.random(1, #EnemyStateActive)
		EnemyStateActive[randomIndex]:handleEvent(event, args)
	end
end

task.spawn(function()
	while true do
		for i = #AliveEnemies, 1, -1 do
			local entry = AliveEnemies[i]
			local enemy = entry.enemy
			local state = entry.state

			if enemy:IsAlive() then
				state:update()

				for _, player in game.Players:GetPlayers() do
					local character = player.Character
					if not character then
						continue
					end

					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if not rootPart then
						warn("Player " .. player.Name .. " is missing HumanoidRootPart")
						continue
					end

					local enemyRoot = enemy.spawnedModel:WaitForChild("HumanoidRootPart")
					if not enemyRoot then
						warn("Enemy " .. enemy.enemyModel.Name .. " is missing HumanoidRootPart")
						continue
					end

					if not rootPart or not enemyRoot then
						continue
					end

					local distance = (rootPart.Position - enemyRoot.Position).Magnitude
					warn("Distance from " .. player.Name .. " to " .. enemy.enemyModel.Name .. ": " .. distance)

					if distance <= 10 then
						state:handleEvent("InAttackRange", { Target = rootPart.Position })
						warn(player.Name .. " is in attack range of " .. enemy.enemyModel.Name)
					elseif distance <= 40 then
						state:handleEvent("PlayerSpotted", { Position = rootPart.Position })
						warn(player.Name .. " is spotted by " .. enemy.enemyModel.Name)
					else
						state:handleEvent("PlayerLost")
						warn(player.Name .. " is lost by " .. enemy.enemyModel.Name)
					end
				end
			else
				table.remove(AliveEnemies, i)
			end
		end

		task.wait(0.1)
	end
end)
