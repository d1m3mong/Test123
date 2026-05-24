export type Trajectory = {
	position: Vector3,
	velocity: Vector3,
	acceleration: Vector3,
}

export type TrajectoryData = {
	position: Vector3,
	velocity: Vector3,
	acceleration: Vector3,
	time: number,
}

local Trajectory = {}
Trajectory.__index = Trajectory

function Trajectory.new(position: Vector3, velocity: Vector3, acceleration: Vector3): Trajectory
	local self = setmetatable({}, Trajectory)

	self.position = position
	self.velocity = velocity
	self.acceleration = acceleration

	return self
end

function Trajectory:calculate(time: number): TrajectoryData
	local position = self.position + self.velocity * time + 0.5 * self.acceleration * time ^ 2
	local velocity = self.velocity + self.acceleration * time

	return {
		position = position,
		velocity = velocity,
		acceleration = self.acceleration,
		time = time,
	}
end

return Trajectory
