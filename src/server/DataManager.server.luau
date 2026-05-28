local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataTemplate = require(ReplicatedStorage.Shared.Data.DataTemplate)
local DataService = require(ReplicatedStorage.Packages.Dataservice).server

local store = "Production"

if game.RunService:IsStudio() then
	store = "Test1"
end

local function GetAllToolFromInventory(inventory: { [string]: any }): Tool?
	local items: any = {}

	for _, item in inventory do
		table.insert(items, item)
	end

	return items
end

local function GetToolFromInventory(inventory: { [string]: any }, id: string): Tool?
	for i, _ in inventory do
		if inventory[i].id == id then
			return inventory[i]
		end
	end

	return nil
end

DataService:init({
	template = DataTemplate,
	profileStoreIndex = store,
	--useMock = game.RunService:IsStudio(),
})

Players.PlayerAdded:Connect(function(player)
	local data = DataService:waitForData(player)

	local money = DataService:get(player, "Money")
	print(player.Name, "has", money, "money")

	local Inventory = DataService:get(player, "Inventory")
	print(player.Name, "has the following inventory:", Inventory)

	DataService:getChangedSignal(player, "Money"):Connect(function(newValue, oldValue)
		print("Money changed:", oldValue, "->", newValue)
	end)
end)
