--------------------------------------------------
-- Defaults
--------------------------------------------------
local _defaultConfig = {
  profile = {
    minimapButton = {
      hide = true,
      lock = false,
      minimapPos = 0,
    },
    config = {
      safeDismount = true,
      summonList = {}
    }
  },
  char = {
    level = level,
    race = race,
    class = class,
    faction = faction,
    hasRidingSkill = hasRidingSkill,
    hasFlyingSkill = hasFlyingSkill,
    prof = {},
    classmounts = true,
    mounts = {
      ground = {},
      flying = {},
      water = {},
      aq = {}
    },
    lastMount = 0
  }
}
  
  
function Mountie_GetDefaultConfig()
  return _defaultConfig
end
  