local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hello = require(ReplicatedStorage.Shared.Hello)

local num: Hello.typ = Hello

print(num.age)
