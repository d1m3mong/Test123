local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelsFolder = ReplicatedStorage:FindFirstChild("Models")
local GoblinModel = ModelsFolder:FindFirstChild(script.Name)

return {
	{
		health = 14,
		damage = 10,
		range = 6,
	},
}
