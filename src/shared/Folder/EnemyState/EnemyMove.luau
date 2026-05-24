local PathfindingService = game:GetService("PathfindingService")

local EnemyTypes = require(script.Parent.Parent.EnemyTypes)
type Enemy = EnemyTypes.Enemy

export type EnemyMove = {
	enemy: Enemy,
	target: Vector3,
	MaximumRadius: number,
}

local EnemyMove = {}
EnemyMove.__index = EnemyMove

function EnemyMove.new(enemy: Enemy, target: Vector3, maximumRadius: number?): EnemyMove
	local self = setmetatable({}, EnemyMove)

	self.enemy = enemy
	self.target = target
	self.MaximumRadius = maximumRadius or 10

	self.path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = self.enemy.spawnedModel:GetExtentsSize().Y,
		AgentCanJump = false,
		WaypointSpacing = 2,
	})

	return self
end

function EnemyMove:computePath()
	self.path:ComputeAsync(self.enemy.enemyModel.PrimaryPart.Position, self.target)
end

function EnemyMove:execute()
	local model = self.enemy.enemyModel
	if not model or not model.PrimaryPart then
		warn("Enemy has no spawned model or PrimaryPart")
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("Enemy model has no Humanoid")
		return
	end

	while self.MaximumRadius < (model.PrimaryPart.Position - self.target).Magnitude do
		local success, errorMessage = pcall(function()
			self:computePath()
		end)

		if not success then
			warn("Pathfinding failed: " .. errorMessage)
			break
		end

		if self.path.Status ~= Enum.PathStatus.Success then
			warn("Path status: " .. tostring(self.path.Status))
			break
		end

		local waypoints = self.path:GetWaypoints()

		for _, waypoint in waypoints do
			if (model.PrimaryPart.Position - self.target).Magnitude <= self.MaximumRadius then
				break
			end

			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	end
end

return EnemyMove
