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
	self.path:ComputeAsync(self.enemy.spawnedModel.PrimaryPart.Position, self.target)
end

function EnemyMove:execute(stateManager)
	local model = self.enemy.spawnedModel

	if not model or not model.PrimaryPart then
		warn("Enemy has no spawned model or PrimaryPart")
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("Enemy model has no Humanoid")
		return
	end

	local function getTarget()
		if stateManager and stateManager.Args then
			return stateManager.Args.Position -- read Position from the args table
		end
		return self.target
	end

	while true do
		local target = getTarget()
		if not target then
			break
		end

		if (model.PrimaryPart.Position - target).Magnitude <= self.MaximumRadius then
			break
		end

		local success = pcall(function()
			self.path:ComputeAsync(model.PrimaryPart.Position, target)
		end)

		if not success or self.path.Status ~= Enum.PathStatus.Success then
			warn("Pathfinding failed or no path found")
			task.wait(0.5)
			continue
		end

		local waypoints = self.path:GetWaypoints()

		for _, waypoint in waypoints do
			local currentTarget = getTarget()
			if not currentTarget then
				break
			end

			if (model.PrimaryPart.Position - currentTarget).Magnitude <= self.MaximumRadius then
				break
			end

			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	end
end

return EnemyMove
