local EnemyMoveModule = require(script.Parent.EnemyState.EnemyMove)
local EnemyAttackModule = require(script.Parent.EnemyState.EnemyAttack)

local EnemyTypes = require(script.Parent.EnemyTypes)
type Enemy = EnemyTypes.Enemy
type EnemyStates = EnemyTypes.EnemyStates
type StateManager = EnemyTypes.StateManager

local StateHandlers = {
	Idle = function(self)
		self.Args = nil
	end,
	Chasing = function(self)
		if not self.Args or not self.Args.Position then
			warn("[EnemyStateModule] Missing Args for Chasing state")
			return
		end

		if self.MoveThread then
			return
		end

		self.MoveThread = task.spawn(function()
			local Move = EnemyMoveModule.new(self.enemy, self.Args.Position, 5)

			Move:execute(self)
			self.MoveThread = nil
		end)
	end,
	Attacking = function(self)
		if not self.Args or not self.Args.Target then
			warn("[EnemyStateModule] Missing Args for Attacking state")
			return
		end

		if self.AttackThread then
			return
		end

		self.AttackThread = task.spawn(function()
			local Attack = EnemyAttackModule.new(self.enemy, self.Args.Target)

			while self.currentState == "Attacking" do
				Attack.Target = self.Args.Target
				Attack:execute()
				task.wait(1)
			end
		end)
	end,
}

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(enemy: Enemy): StateManager
	local self = setmetatable({}, StateManager)
	self.currentState = "Idle"
	self.enemy = enemy
	self.Args = nil

	self.MoveThread = nil
	self.AttackThread = nil

	return self
end

function StateManager:changeState(newState: EnemyStates, Args: any?)
	if Args then
		self.Args = Args
	end

	if self.currentState == newState then
		return
	end

	if self.MoveThread then
		task.cancel(self.MoveThread)
		self.MoveThread = nil
	end

	if self.AttackThread then
		task.cancel(self.AttackThread)
		self.AttackThread = nil
	end

	self.currentState = newState
end

function StateManager:handleEvent(event: string, args: any?)
	if event == "PlayerSpotted" then
		self:changeState("Chasing", args)
	elseif event == "InAttackRange" then
		self:changeState("Attacking", args)
	elseif event == "PlayerLost" then
		self:changeState("Idle")
	else
		warn("Unknown event: " .. event)
	end
end

function StateManager:update()
	local handler = StateHandlers[self.currentState]
	if handler then
		handler(self)
	end
end

return StateManager
