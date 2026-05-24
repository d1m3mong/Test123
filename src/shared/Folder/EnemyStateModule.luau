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
		local Move = EnemyMoveModule.new(self.enemy, self.Args.Position)
		Move:execute()
	end,
	Attacking = function(self)
		local Attack = EnemyAttackModule.new(self.enemy, self.Args.Target)
		Attack:execute()
	end,
}

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(enemy: Enemy): StateManager
	local self = setmetatable({}, StateManager)
	self.currentState = "Idle"
	self.enemy = enemy
	self.Args = nil

	return self
end

function StateManager:changeState(newState: EnemyStates, Args: any?)
	if self.currentState == newState then
		return
	end
	self.currentState = newState

	if Args then
		self.Args = Args
	end
end

function StateManager:handleEvent(event: string)
	if event == "PlayerSpotted" then
		self:changeState("Chasing")
	elseif event == "InAttackRange" then
		self:changeState("Attacking")
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
