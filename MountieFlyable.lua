--[[--------------------------------------------------------------------	
  Extended Replacement for the IsFlyableArea API function in World of Warcraft.
  This is based on Phanx's LibFlyable (https://github.com/phanx-wow/LibFlyable).
----------------------------------------------------------------------]]
-- TODO: Wintergrasp (mapID 501) status detection? Or too old to bother with?

----------------------------------------
-- Data
----------------------------------------

local spellForContinent = {
  -- Continents/instances requiring a spell to fly:
  -- Battle for Azeroth Pathfinder
	[1642] = 278833, -- Zandalar
	[1643] = 278833, -- Kul Tiras (incl. Mechagon Island)
	[1718] = 278833, -- Nazjatar

	-- Unflyable continents/instances where IsFlyableArea returns true:
	[1191] = -1, -- Ashran (PvP)
	[1265] = -1, -- Tanaan Jungle Intro
	[1463] = -1, -- Helheim Exterior Area
	[1500] = -1, -- Broken Shore (scenario for DH Vengeance artifact)
	[1669] = -1, -- Argus (mostly OK, few spots are bugged)

	-- Unflyable class halls where IsFlyableArea returns true:
	-- Note some are flyable at the entrance, but not inside;
	-- flying serves no purpose here, so we'll just say no.
	[1519] = -1, -- The Fel Hammer (Demon Hunter)
	[1514] = -1, -- The Wandering Isle (Monk)
	[1469] = -1, -- The Heart of Azeroth (Shaman)
	[1107] = -1, -- Dreadscar Rift (Warlock)
  [1479] = -1, -- Skyhold (Warrior)
  
	-- Unflyable island expeditions where IsFlyableArea returns true:
	[1813] = -1, -- Un'gol Ruins
	[1814] = -1, -- Havenswood
	[1879] = -1, -- Jorundall
	[1882] = -1, -- Verdant Wilds
	[1883] = -1, -- Whispering Reef
	[1892] = -1, -- Rotting Mire
	[1893] = -1, -- The Dread Chain
	[1897] = -1, -- Molten Clay
	[1898] = -1, -- Skittering Hollow
	[1907] = -1, -- Snowblossom Village
	[2124] = -1, -- Crestfall

	-- Unflyable Dungeons where IsFlyableArea returns true:
  [1763] = -1, -- Atal'dazar
  [1004] = -1, -- Scarlet Monastery

	-- Unflyable Warfronts where IsFlyableArea returns true:
	[1943] = -1, -- The Battle of Stormgarde
	[1876] = -1, -- Warfronts Arathi - Horde

	-- Unflyable Raids where IsFlyableArea returns true:
	[2169] = -1, -- Uldir: The Oblivion Door

	-- Unflyable Scenarios where IsFlyableArea returns true:
	[1662] = -1, -- Assault of the Sanctum of Order
	[1906] = -1, -- Zandalar Continent Finale
	[1917] = -1, -- Mag'har Scenario

  -- Unflyable Lesser Visions where IsFlyableArea returns true:
  [2274] = -1, -- Vision of the Twisting Sands
  [2275] = -1, -- Vale of Eternal Twilight
}

-- Workaround for bug in patch 9.0.1
local flyableContinents = {
	-- These continents previously required special spells to fly in.
	-- All such spells were removed from the game in patch 9.0.1, but
	-- the IsFlyableArea() API function was not updated accordingly,
	-- and incorrectly returns false on these continents for characters
	-- who did not know the appropriate spell before the patch.
	-- Draenor Pathfinder (191645) -> since Patch 9.0.1 no longer required to fly. Checking for "Expert Riding" skill (34090) instead 
	[1116] = 34090, -- Draenor
	[1464] = 34090, -- Tanaan Jungle
	[1152] = 34090, -- FW Horde Garrison Level 1
	[1330] = 34090, -- FW Horde Garrison Level 2
	[1153] = 34090, -- FW Horde Garrison Level 3
	[1154] = 34090, -- FW Horde Garrison Level 4
	[1158] = 34090, -- SMV Alliance Garrison Level 1
	[1331] = 34090, -- SMV Alliance Garrison Level 2
	[1159] = 34090, -- SMV Alliance Garrison Level 3
	[1160] = 34090, -- SMV Alliance Garrison Level 4
	-- Broken Isles Pathfinder (233368) -> since Patch 9.0.1 no longer required to fly. Checking for "Expert Riding" skill (34090) instead 
	[1220] = 34090, -- Broken Isles
}

local noFlySubzones = {
	-- Unflyable subzones where IsFlyableArea() returns true:
	["Nespirah"] = true, ["Неспира"] = true, ["네스피라"] = true, ["奈瑟匹拉"] = true, ["奈斯畢拉"] = true,
}

----------------------------------------
-- Logic
----------------------------------------

local GetInstanceInfo = GetInstanceInfo
local GetSubZoneText = GetSubZoneText
local IsFlyableArea = IsFlyableArea
local IsSpellKnown = IsSpellKnown

function MountieIsFlyableArea()
	-- if not IsFlyableArea() -- Workaround for bug in patch 9.0.1
	if noFlySubzones[GetSubZoneText() or ""] then
		return false
	end

	local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
	local reqSpell = spellForContinent[instanceMapID]
	if reqSpell then
		return reqSpell > 0 and IsSpellKnown(reqSpell)
  end
  
	-- Workaround for bug in patch 9.0.1
	-- IsFlyableArea() incorrectly reports false in many locations for
	-- characters who did not have a zone-specific pathfinder spell before
	-- the patch (which removed all such spells from the game).
	if not IsFlyableArea() and not flyableContinents[instanceMapID] then
		-- Continent is not affected by the bug. API is correct.
		return false
	end  

	return IsSpellKnown(34090) or IsSpellKnown(90265)
end