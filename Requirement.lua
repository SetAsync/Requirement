--// RequirementType.lua
-- 2-18-2025

-- @ Services
local MarketplaceService = game:GetService("MarketplaceService")
local Teams = game:GetService("Teams")

-- @ Module
local RequirementType = {}
RequirementType.BuiltInTypes = {}

-- @ SetupRequirementType
local SetupRequirementType = {}
SetupRequirementType.__index = SetupRequirementType

function SetupRequirementType.new(_RequirementTypeClass, _Data)
	local self = setmetatable({}, SetupRequirementType)
	self.Data = _Data
	self.RequirementTypeClass = _RequirementTypeClass
	return self
end

function SetupRequirementType:Assess(Client : Player)
	return self.RequirementTypeClass.Assess(Client, table.unpack(self.Data))
end

function SetupRequirementType:__add(OtherSetup)
	if typeof(OtherSetup) == "boolean" then
		OtherSetup = RequirementType.BuiltInTypes.Test(OtherSetup)
	end
	
	return	RequirementType.BuiltInTypes.Any(
		self, 
		OtherSetup
	)
end

function SetupRequirementType:__mul(OtherSetup)
	if typeof(OtherSetup) == "boolean" then
		OtherSetup = RequirementType.BuiltInTypes.Test(OtherSetup)
	end
	
	return	RequirementType.BuiltInTypes.All(
		self, 
		OtherSetup
	)
end

-- @ RequirementType
RequirementType.__index = RequirementType

function RequirementType.new(_Name)
	local self = setmetatable({}, RequirementType)
	self.Name = _Name
	self.Assess = false -- Function placeholder.
	return self
end

function RequirementType:__call(...)
	local PackedSetupData = table.pack(...)
	local Setup = SetupRequirementType.new(self, PackedSetupData)
	return Setup
end

function RequirementType:Commit()
	if RequirementType.BuiltInTypes[self.Name] then
		error(self.Name.." is already reserved!")
	end
	
	RequirementType.BuiltInTypes[self.Name] = self
end

------------------------------------

-- @ Owner
local Owner = RequirementType.new("Owner")
function Owner.Assess(Player)
	return Player.UserId == game.CreatorId
end
Owner:Commit()

-- @ Friends
local Friends = RequirementType.new("Friends")
function Friends.Assess(Player : Player, FriendsWith)
	return Player:IsFriendsWith(FriendsWith)
end
Friends:Commit()

-- @ Proximity
local Proximity = RequirementType.new("Proximity")
function Proximity.Assess(Player, ProximityTo, MinimumValue, MaximumValue)
	-- Valdiate Character
	local RootPart = Player.Character and Player.Character.PrimaryPart
	if not RootPart then
		return false
	end
	
	-- Fix Vector3
	if typeof(ProximityTo) ~= "Vector3" then
		ProximityTo = ProximityTo.Position
	end
	
	-- Fix Range
	MinimumValue = MinimumValue or 15
	MaximumValue = MaximumValue or 30
	
	local Magnitude = (ProximityTo - RootPart.Position).Magnitude
	return (Magnitude >= MinimumValue) and (Magnitude <= MaximumValue)
end
Proximity:Commit()

-- @ AccountAge
local AccountAge = RequirementType.new("AccountAge")
function AccountAge.Assess(Player, AccountAge)
	AccountAge = AccountAge or 30
	return Player.AccountAge >= AccountAge
end
AccountAge:Commit()

-- @ Team
local Team = RequirementType.new("Team")
function Team.Assess(Player, Team)
	if typeof(Team) == "string" then
		Team = Teams:FindFirstChild(Team)
	end
	assert(Team, "Invalid team provided!")

	return Player.Team == Team
end
Team:Commit()

-- @ Group
local Group = RequirementType.new("Group")
function Group.Assess(Player : Player, GroupID, MinimumRank, MaximumRank)
	local RankInGroup = Player:GetRankInGroup(GroupID)
	MinimumRank = MinimumRank or 1
	MaximumRank = MaximumRank or 255
	return (RankInGroup >= MinimumRank) and (RankInGroup <= MaximumRank)
end
Group:Commit()

-- @ Gamepass
local Gamepass = RequirementType.new("Gamepass")
function Gamepass.Assess(Player, GamepassID)
	return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassID)
end
Gamepass:Commit()

-- @ User ID
local UserID = RequirementType.new("UserID")
function UserID.Assess(Player, UserID)
	return Player.UserId == UserID
end
UserID:Commit()

-- @ Player
local Player = RequirementType.new("Player")
function Player.Assess(Player, Property, ExpectedValue)
	return Player[Property] == ExpectedValue
end
Player:Commit()

-- @ Test
local Test = RequirementType.new("Test")
function Test.Assess(Player, ReturnValue)
	return ReturnValue
end
Test:Commit()

-- @ All
local All = RequirementType.new("All")
function All.Assess(Player, ...)
	local AllRequirements = table.pack(...) 	
	for Key, OtherRequirement in AllRequirements do
		if Key == "n" then
			continue
		end
		
		if not OtherRequirement:Assess(Player) then
			return false
		end
	end
	return true
end
All:Commit()

-- @ Any
local Any = RequirementType.new("Any")
function Any.Assess(Player, ...)
	local AllRequirements = table.pack(...) 	
	for Key, OtherRequirement in AllRequirements do
		if Key == "n" then
			continue
		end

		if OtherRequirement:Assess(Player) then
			return true
		end
	end
	return false
end
Any:Commit()

-- @ None
local None = RequirementType.new("None")
function None.Assess(Player, ...)
	local AllRequirements = table.pack(...) 	
	for Key, OtherRequirement in AllRequirements do
		if Key == "n" then
			continue
		end

		if OtherRequirement:Assess(Player) then
			return false
		end
	end
	return true
end
None:Commit()

-- @ Exclusive
local Exclusive = RequirementType.new("Exclusive")
function Exclusive.Assess(Player, ExclusiveExpectation, ...)
	ExclusiveExpectation = ExclusiveExpectation or 1
	local MetRequirements = 0
	
	local AllRequirements = table.pack(...) 	
	for Key, OtherRequirement in AllRequirements do
		if Key == "n" then
			continue
		end

		if OtherRequirement:Assess(Player) then
			MetRequirements += 1
		end
	end
	
	return MetRequirements == ExclusiveExpectation
end
Exclusive:Commit()

-- @ Function / Custom
local Custom = RequirementType.new("Function")
function Custom.Assess(Player, Function)
	return Function(Player)
end
Custom:Commit()

return setmetatable({}, {
	__index = function(_, Key)
		return RequirementType[Key] or RequirementType.BuiltInTypes[Key]
	end,
})
