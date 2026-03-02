# Requirement.lua

This descrpition has been copied from the original site of publication.

---


Hey!

A few years ago I made QuickPerms, and despite being terribly scripted I've found it useful in many projects since. I thought I'd invent a prettier and more useful alternative.

**Core Features**

* You or your client can easily declare 'requirements' a player must meet.
* You can use the requirements object to quickly "assess" whether a player meets them.

Example Usages:
```lua
local Requirement = require(script.Parent.Requirement)
-- Somewhere in your system's configuration file...
local AdminConsoleAccess = Requirement.Any(
	Requirement.Player("Name", "Alexplazz"),
	Requirement.Friends(241617708),
	Requirement.All(
		Requirement.AccountAge(30),
		Requirement.Gamepass(241617708)
	)
)

local RedDoorAccess = Requirement.None(
	Requirement.Group(25245345),
	Requirement.Player("Name", "ABadMan205")
)


-- Now that you've declared the requiremets in your config, elsewhere you may do this:
if AdminConsoleAccess:Assess(plr) then
	
end
```
If you have a custom API / system you want to link to the requirements module, you may do so like this:
```lua
local Requirement = require(script.Parent.Requirement)

-- Setup the new requirement type
local HasTycoonColor = Requirement.new("HasTycoonColor")
function HasTycoonColor.Assess(Player, NeededColor)
	return Player:GetAttribute("OwnedTycoonColor") == NeededColor
end
HasTycoonColor:Commit() -- Commit it to the Requirements module / table.


-- It can now be used normally:
-- EG: AccountAge 10+, and has red tycoon.

local MayUseRedAdmin = Requirement.All(
	Requirement.HasTycoonColor("Red"),
	Requirement.AccountAge(10)
)

-- You can, of course, use them directly.
local LikeTHis = Requirement.HasTycoonColor("Red")

if LikeTHis:Assess(plr) then
	print("They have red!")
end

if MayUseRedAdmin:Assess(plr) then
	print("They have red, and are over 10 days!")
end
```


Here's a full list of built in requirements, and how to use them:
```lua
local Requirement = require(script.Parent.Requirement)

--[[
    ### Owner Check ###
    - Determines if the player is the game owner/creator.
--]]
local ButtonAccess = Requirement.Owner()
if ButtonAccess:Assess(Player) then
	print("Welcome, owner!")
end

--[[
    ### Friends Check ###
    - Checks if the player is friends with a specific Roblox user ID.
    - Argument: User ID (integer) of the friend to check.
--]]
local FriendsWithOwner = Requirement.Friends(241617708)
if FriendsWithOwner:Assess(Player) then
	print("You're friends!")
end

--[[
    ### Proximity Check ###
    - Checks if the player is within a specified proximity to an object or position.
    
    Arguments:
    1. `position`: Either a `Vector3` or an `Instance` with a `Vector3` position property.
    2. `minDistance` (optional): Minimum proximity required. Default is `15`.
    3. `maxDistance` (optional): Maximum proximity allowed. Default is `30`.

    The requirement is satisfied if the player is within the specified range.
--]]
local ProximityToDoor = Requirement.Proximity(workspace.SwordStone)
if ProximityToDoor:Assess(Player) then
	print("Close enough.")
end

--[[
    ### Account Age Check ###
    - Checks if the player's account is at least the specified number of days old.
    
    Argument:
    - `requiredDays`: Minimum account age in days.
--]]
local AgeRequirement = Requirement.AccountAge(31) -- Requires account to be at least 31 days old.
if AgeRequirement:Assess(Player) then
	print("Meets age requirement")
end

--[[
    ### Team Check ###
    - Checks if the player belongs to a specific team.
    
    Argument:
    - `teamNameOrInstance`: The `Team` instance or the string name of the team.
    
    Note: If the team cannot be found, an error will be thrown.
--]]
local Team = Requirement.Team("HCPD")
if Team:Assess(Player) then
	print("Welcome, police")
end

--[[
    ### Group Check ###
    - Checks if the player is in a specified Roblox group and within a rank range.
    
    Arguments:
    1. `GroupID` (integer): The Roblox group ID.
    2. `MinimumRank` (integer, optional): The lowest rank allowed (default: `1`).
    3. `MaximumRank` (integer, optional): The highest rank allowed (default: `255`).

    Returns:
    - `true` if the player’s rank in the group falls within the specified range.
--]]
local GroupCheck = Requirement.Group(1234567, 10, 200) -- Example group ID and rank range.
if GroupCheck:Assess(Player) then
	print("You meet the group rank requirement.")
end

--[[
    ### Gamepass Check ###
    - Checks if the player owns a specific gamepass.
    
    Argument:
    - `GamepassID` (integer): The ID of the gamepass.

    Returns:
    - `true` if the player owns the gamepass.
--]]
local GamepassCheck = Requirement.Gamepass(9876543) -- Example gamepass ID.
if GamepassCheck:Assess(Player) then
	print("You own the gamepass!")
end

--[[
    ### UserID Check ###
    - Checks if the player's UserId matches a specified value.
    
    Argument:
    - `UserID` (integer): The exact UserId to match.

    Returns:
    - `true` if the player's UserId matches the given ID.
--]]
local UserIDCheck = Requirement.UserID(241617708)
if UserIDCheck:Assess(Player) then
	print("You are the specified user.")
end

--[[
    ### Player Property Check ###
    - Checks if a player's property matches an expected value.
    
    Arguments:
    1. `Property` (string): The property name to check.
    2. `ExpectedValue`: The expected value of the property.

    Returns:
    - `true` if the player's property matches the expected value.
--]]
local PlayerPropertyCheck = Requirement.Player("TeamColor", BrickColor.new("Bright blue"))
if PlayerPropertyCheck:Assess(Player) then
	print("You are on the blue team.")
end

--[[
    ### Test Requirement ###
    - A general-purpose test function that always returns a specified value.
    
    Argument:
    - `ReturnValue` (boolean): The value to return.

    Returns:
    - The specified `ReturnValue`.
--]]
local TestRequirement = Requirement.Test(true)
if TestRequirement:Assess(Player) then
	print("Test requirement passed.")
end
```

Finally, here are the 'operators' you can use to join different conditions together.
```
--[[
    ### All Requirement ###
    - Ensures that the player meets all provided requirements.

    Arguments:
    - `...`: A variable number of Requirement instances.

    Returns:
    - `true` if all requirements pass.
    - `false` if any requirement fails.
--]]
local AllCheck = Requirement.All(
	Requirement.AccountAge(31),
	Requirement.Team("HCPD")
)
if AllCheck:Assess(Player) then
	print("Player meets all requirements!")
end

--[[
    ### Any Requirement ###
    - Ensures that the player meets at least one of the provided requirements.

    Arguments:
    - `...`: A variable number of Requirement instances.

    Returns:
    - `true` if at least one requirement passes.
    - `false` if all requirements fail.
--]]
local AnyCheck = Requirement.Any(
	Requirement.Gamepass(987654),
	Requirement.Team("HCPD")
)
if AnyCheck:Assess(Player) then
	print("Player meets at least one requirement!")
end

--[[
    ### None Requirement ###
    - Ensures that the player fails all provided requirements.

    Arguments:
    - `...`: A variable number of Requirement instances.

    Returns:
    - `true` if none of the requirements pass.
    - `false` if any requirement passes.
--]]
local NoneCheck = Requirement.None(
	Requirement.Gamepass(987654),
	Requirement.Team("HCPD")
)
if NoneCheck:Assess(Player) then
	print("Player meets none of the requirements!")
end

--[[
    ### Exclusive Requirement ###
    - Ensures that the player meets exactly a specific number of requirements.

    Arguments:
    1. `ExclusiveExpectation` (integer, optional): The exact number of requirements that must pass (default: `1`).
    2. `...`: A variable number of Requirement instances.

    Returns:
    - `true` if the player meets exactly `ExclusiveExpectation` number of requirements.
    - `false` otherwise.
--]]
local ExclusiveCheck = Requirement.Exclusive(1,
	Requirement.Gamepass(987654),
	Requirement.Team("HCPD"),
	Requirement.AccountAge(31)
)
if ExclusiveCheck:Assess(Player) then
	print("Player meets exactly one requirement!")
end
```

Get the module here!
https://create.roblox.com/store/asset/87699372127510/Requirement

---



Update:
You may use the + operator to mean ‘this or this’ requirement.
You may use the * operator to mean ‘this and this’ requirement.

```lua
local Requirement = require(script.Parent.Requirement)
local Test = (Requirement.Test(true) + Requirement.Test(false)) * Requirement.Test(true)

print(Test:Assess())
```
