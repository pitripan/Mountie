Mountie = LibStub("AceAddon-3.0"):NewAddon("Mountie", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Mountie")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Mountie", {
  type = "data source",
  text = L["Mountie_MMBTooltipTitle"],
  icon = "Interface\\Icons\\Ability_Mount_NightmareHorse", --ABILITY_MOUNT_DREADSTEED
  OnTooltipShow = function(tooltip)
    tooltip:SetText(L["Mountie_MMBTooltipTitle"])
    tooltip:AddLine(L["Mountie_MMBTooltipInfo"], 1, 1, 1)
    tooltip:Show()
  end,
  OnClick = function(self, button)
    if button == "LeftButton" then
      Mountie:ShowHelpFrame()
    elseif button == "RightButton" then
      Mountie:ShowOptionsFrame()
    end
  end})
local MountieMiniMapButton = LibStub("LibDBIcon-1.0")
--
local _Colors = Mountie_GetColors()
local _defaultConfig = Mountie_GetDefaultConfig()


--------------------------------------------------
-- Variable definitions
--------------------------------------------------
local _state = {}
local _flightTest = 60025    -- used for determining the ability to fly in the old world

-- A list of all the Vashj'ir zones for reference
local _vashj = { 
	[613] = true, -- Vashj'ir
	[610] = true, -- Kelp'thar Forest
	[615] = true, -- Shimmering Expanse
	[614] = true  -- Abyssal Depths
}
-- Chauffeured
local _chauffeured = {
	[678] = 179244, -- Chauffeured Mechano-Hog
	[679] = 179245, -- Chauffeured Mekgineer's Chopper
}


--------------------------------------------------
-- Utility Functions
--------------------------------------------------
function panRemoveFromArray(array, removeMe)
  local j, n = 1, #array

  for i = 1, n do
    if (array[i] == removeMe) then
      array[i] = nil
    else
      -- Move i's kept value to j's position, if it's not already there.
      if (i ~= j) then
        array[j] = array[i]
        array[i] = nil
      end
      j = j + 1 -- Increment position of where we'll place the next kept value.
    end
  end

  return t
end

function panShowArray(array)
  for i = 1, #array do
    print('total:'..#array , 'i:'..i, 'v:'..array[i]);
  end
end

function panTableContains(table, item)
  local index = 1
  while table[index] do
    if item == table[index] then
      return true
    end
    index = index + 1
  end
  return false
end

function panGetPartiallyColoredString(text, coloredText, color)
	local colorString = ""
	colorString = "\124cff" .. color .. coloredText .. "\124r"
	return string.format(text, colorString)
end


--------------------------------------------------
-- General Functions
--------------------------------------------------
local function addMountToSummonList(spellId)
  local mountId = Mountie:GetMountIdBySpellId(spellId)

  if panTableContains(Mountie.db.profile.config.summonList, mountId) == false then
    Mountie.db.profile.config.summonList[#Mountie.db.profile.config.summonList + 1] = mountId

    Mountie:RescanMounts()

    local creatureName = C_MountJournal.GetMountInfoByID(mountId)
    --Mountie:Print(string.format(L["Mountie_SummonList_Add"], creatureName))
  end
end

local function removeMountToSummonList(spellId)
  local mountId = Mountie:GetMountIdBySpellId(spellId)

  if panTableContains(Mountie.db.profile.config.summonList, mountId) == true then
    panRemoveFromArray(Mountie.db.profile.config.summonList, mountId)

    Mountie:RescanMounts()


    local creatureName = C_MountJournal.GetMountInfoByID(mountId)
    --Mountie:Print(string.format(L["Mountie_SummonList_Remove"], creatureName))
  end
end

function Mountie_SetupPopupDialogs()
  -- perform reload when needed
  StaticPopupDialogs["Mountie_PerformReload"] = {
    text = L["Mountie_PerformReload"],
    button1 = L["Mountie_Yes"],
    button2 = L["Mountie_No"],
    OnAccept = function()
      ReloadUI()
    end,
    OnCancel = function()
      Mountie:Print(L["Mountie_NotReloaded"])
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3
  }
end


--------------------------------------------------
-- Interface Events & Functions
--------------------------------------------------
function Mountie_ShowTooltip(self, title, description)
  if self then
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(title)
    GameTooltip:AddLine(description, 1, 1, 1, true)
    GameTooltip:Show()
  end
end

function Mountie_HideTooltip(self)
  GameTooltip:Hide()
end

function Mountie:ExtendMountJournal()
  self.companionButtons = {}

	local numMounts = C_MountJournal.GetNumDisplayedMounts() --C_MountJournal.GetNumMounts()
	local scrollFrame = MountJournal.ListScrollFrame
	local buttons = scrollFrame.buttons

	-- build out check buttons
	for i = 1, #buttons do
    local parent = buttons[i];
  
		if i <= numMounts then
			local button = CreateFrame("CheckButton", "MountieCheckButton" .. i, parent, "UICheckButtonTemplate")
			button:SetEnabled(false)
			button:SetPoint("TOPRIGHT", 0, 0)
			button:HookScript("OnClick", function(self)
				Mountie:MountCheckButton_OnClick(self)
			end)

			self.companionButtons[i] = button
		end
	end

	-- hook up events to update check state on scrolling
	scrollFrame:HookScript("OnMouseWheel", function(self)
		Mountie:MountJournalScrollFrameUpdate()
	end)
	scrollFrame:HookScript("OnVerticalScroll", function(self)
		Mountie:MountJournalScrollFrameUpdate()
	end)
	
  ---- hook up events to update check state on search or filter change
  hooksecurefunc("MountJournal_UpdateMountList", function(self)
		Mountie:MountJournalScrollFrameUpdate()
	end);

	-- force an initial update on the journal, as it's coded to only do it upon scroll or selection
	MountJournal_UpdateMountList()
end

function Mountie:MountJournalScrollFrameUpdate()
  if self.companionButtons then
		local offset = HybridScrollFrame_GetOffset(MountJournal.ListScrollFrame);
	
		for idx, button in ipairs(self.companionButtons) do
			local parent = button:GetParent()
      
      if parent.spellID == 0 then
        _G["MountieCheckButton" .. idx]:Hide()
      else 
        _G["MountieCheckButton" .. idx]:Show()

        -- Get information about the currently selected mount
        local spellID = parent.spellID
        local id = self:FindSelectedMount(spellID)    
        local _, _, _, _, _, _, _, isFactionSpecific, faction, _, isCollected, _ = C_MountJournal.GetMountInfoByID(id)
        local correctFaction = (not isFactionSpecific or (self.db.char.faction == "Horde" and faction == 0) or (self.db.char.faction == "Alliance" and faction == 1) or (self.db.char.faction == "Allianz" and faction == 1))
        
        if correctFaction == true and isCollected == true and parent:IsEnabled() == true then					
          -- Set the checked state based on the currently saved value
          local checked = false;
          for mountType, typeTable in pairs(self.db.char.mounts) do
            if typeTable[spellID] ~= nil then
              checked = typeTable[spellID]
            end
          end

          button:SetEnabled(true)
          button:SetChecked(checked)
          button:SetAlpha(1.0);
        else
          button:SetEnabled(false)
          button:SetChecked(false)
          button:SetAlpha(0.25);
        end
      end    
		end
	end
end

--------------------------------------------------
-- Functions
--------------------------------------------------
function Mountie:ShowHelpFrame()
  -- double call to open the correct interface options panel -> Blizzard needs to fix
  InterfaceOptionsFrame_OpenToCategory(Mountie.helpFrame)
  InterfaceOptionsFrame_OpenToCategory(Mountie.helpFrame)
end

function Mountie:ShowOptionsFrame()
  -- double call to open the correct interface options panel -> Blizzard needs to fix
  InterfaceOptionsFrame_OpenToCategory(Mountie.optionsFrame)
  InterfaceOptionsFrame_OpenToCategory(Mountie.optionsFrame)
end

function Mountie:ToggleMinimapButton()
  self.db.profile.minimapButton.hide = not self.db.profile.minimapButton.hide
  if self.db.profile.minimapButton.hide then
    MountieMiniMapButton:Hide("Mountie")
  else
    MountieMiniMapButton:Show("Mountie")
  end
end

function Mountie:PrintColored(msg, color)
  self:Print("|cff" .. color .. msg .. "|r")
end

function Mountie:OnOptionHide()
  if (self.needReload) then
    self.needReload = false
    StaticPopup_Show("Mountie_PerformReload")
  end
end

function Mountie:DoReload()
  self.needReload = false
  StaticPopup_Show("Mountie_PerformReload")
end

function Mountie:MountieButton_OnClick()
  if IsIndoors() then 
    return 
  end
  
  if IsFlying() then
    if self.db.profile.config.safeDismount == false then
      Dismount()
    end
  else
    -- check if player is not moving
    local speed = GetUnitSpeed("player")
    
    if IsMounted() then
      Dismount()
    else 
      if speed == 0 then
        _state.mount = self:GetRandomMount()

        if _state.mount ~= nil then
          self.db.char.lastMount = _state.mount
        end            
        self:SummonMount(_state.mount)
      end    
    end
  end
end

function Mountie:RescanMounts()
  self.db.char.mounts = {
    ground = {},
    flying = {},
    water = {},
    aq = {}
  }

  local newMounts = 0
  for _, id in pairs(Mountie.db.profile.config.summonList) do
    local name, spellID, _, _, _, _, _, isFactionSpecific, faction, _, isCollected = C_MountJournal.GetMountInfoByID(id)

    --make sure it's valid and not already found
    local correctFaction = not isFactionSpecific or (self.db.char.faction == "Horde" and faction == 0) or (self.db.char.faction == "Alliance" and faction == 1)
    if correctFaction == true and isCollected == true and not self:MountExists(spellID) then
      newMounts = newMounts + 1
      
      local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(id)
      
      -- 284 for 2 Chopper / Mechano-Hog
      -- 269 for 2 Water Striders (Azure and Crimson)
      -- 254 for 1 Subdued Seahorse (Vashj'ir and water)
      -- 248 for 163 "typical" flying mounts, including those that change based on level
      -- 247 for 1 Red Flying Cloud (flying mount)
      -- 242 for 1 Swift Spectral Gryphon (the one we fly while dead)
      -- 241 for 4 Qiraji Battle Tanks (AQ only)
      -- 232 for 1 Abyssal Seahorse (Vashj'ir only)
      -- 231 for 2 Turtles (Riding and Sea)
      -- 230 for 298 land mounts
            
      -- AQ only mounts
      if mountType == 241 then
        self.db.char.mounts["aq"] = self.db.char.mounts["aq"] or {}
        self.db.char.mounts["aq"][spellID] = true
      end
            
      -- flying
      if mountType == 247 or mountType == 248 then    
        self.db.char.mounts["flying"] = self.db.char.mounts["flying"] or {}
        self.db.char.mounts["flying"][spellID] = true
      end
      
      -- water / swimming
      if mountType == 231 or mountType == 232 or mountType == 254 or mountType == 269 then
        self.db.char.mounts["water"] = self.db.char.mounts["water"] or {}
        self.db.char.mounts["water"][spellID] = true
      end
      
      -- ground
      if mountType == 230 or mountType == 231 or mountType == 269 or mountType == 284 then
        self.db.char.mounts["ground"] = self.db.char.mounts["ground"] or {}
        self.db.char.mounts["ground"][spellID] = true
      end
    end
  end
end

function Mountie:MountExists(spellID)
  for mountType, typeTable in pairs(self.db.char.mounts) do
    if typeTable[spellID] ~= nil then
      return true
    end
  end
  return false
end

function Mountie:GetRandomMount()
	-- Determine state order for looking for a mount
  local typeList = {}
  local shiftKeyDown = IsShiftKeyDown()
  
  -- if Level <20 or summon list is empty, summon chauffeured
  --if self.db.char.level < minLevel or next(self.db.profile.config.summonList) == nil then
  if self.db.char.hasRidingSkill == false or next(self.db.profile.config.summonList) == nil then
    local id = (self.db.char.faction == "Horde") and 678 or 679
    local chauffeurMount = select(5, C_MountJournal.GetMountInfoByID(id)) and _chauffeured[id]
    return chauffeurMount
	end
    
  if _state.zone == 766 then -- in AQ
    typeList = { "aq", "ground", "flying" }
  elseif _state.isSwimming == true then  
		if _state.isFlyable == true and self.db.char.hasFlyingSkill and shiftKeyDown then
			typeList = { "flying", "ground" }
    elseif shiftKeyDown then
      typeList = { "ground" }
    else 
      typeList = { "water", "flying", "ground" }
		end        
	elseif _state.isFlyable == true and self.db.char.hasFlyingSkill then
		typeList = { "flying", "ground" }
	else
		typeList = { "ground", "flying" }
	end
    
	-- Cycle through the type list
	for i, type in pairs(typeList) do
		-- Make a sublist of any valid mounts of the selected type
    local mounts = {}

		for mount, active in pairs(self.db.char.mounts[type]) do
      if self.db.char.mounts[type][mount] == true and self:CheckProfession(mount) and self:CheckClass(mount) then
        mounts[#mounts + 1] = mount
			end
    end
        
    if #mounts > 1 then
      panRemoveFromArray(mounts, self.db.char.lastMount)
    end
      
    -- If there were any matching mounts of the current type, then proceed, otherwise move to the next type
    if #mounts > 0 then
      -- Grab a random mount from the narrowed list
      local rand = random(1, #mounts)
      local mount = mounts[rand]
            
      if _state.mount == mount and #mounts > 1 then
        while _state.mount == mount do
          rand = random(1, #mounts)
          mount = mounts[rand]
        end
      end
            
      return mount
    end
	end
	
  -- If this point has been reached, then no matching mount was found
  self:Print("GetRandomMount -> No mount found.")
	return nil
end

function Mountie:SummonMount(mount)
  for _, id in pairs(C_MountJournal.GetMountIDs()) do
    local _, spellID = C_MountJournal.GetMountInfoByID(id)
    if spellID == mount then
      C_MountJournal.SummonByID(id)
      return
    end
  end
end

function Mountie:GetMountIdBySpellId(spell) 
  for _, id in pairs(C_MountJournal.GetMountIDs()) do
    local _, spellID = C_MountJournal.GetMountInfoByID(id)
    if spellID == spell then
      return id
    end
  end
end

function Mountie:FindSelectedMount(selectedSpellID)
	for _, id in pairs(C_MountJournal.GetMountIDs()) do
		local _, spellID = C_MountJournal.GetMountInfoByID(id)
		if spellID == selectedSpellID then
			return id
		end
	end

	return nil
end

function Mountie:MountCheckButton_OnClick(button)
  local spellId = button:GetParent().spellID
  local isChecked = button:GetChecked()

  if isChecked then
    addMountToSummonList(spellId)
  else
    removeMountToSummonList(spellId)
  end
end

function Mountie:ShowHelp()
  Mountie:Print(L["Mountie_Help"])
  Mountie:Print(L["Mountie_Help_Default"])
  Mountie:Print(L["Mountie_Help_Minimap"])
end

--------------------------------------------------
-- Special Mount Restrictions
--------------------------------------------------
-- Class Mounts
local classmounts =  {	
  [54729] = "DEATHKNIGHT", --Winged Steed of the Ebon Blade
	[229387] = "DEATHKNIGHT", --Deathlord's Vilebrood Vanquisher
	[229417] = "DEMONHUNTER", --Slayer's Felbroken Shrieker
	[229386] = "HUNTER", --Huntmaster's Loyal Wolfhawk
	[229438] = "HUNTER", --Huntmaster's Fierce Wolfhawk
	[229439] = "HUNTER", --Huntmaster's Dire Wolfhawk
	[229376] = "MAGE", --Archmage's Prismatic Disc
	[229385] = "MONK", --Ban-Lu, Grandmaster's Companion
	[231435] = "PALADIN", --Highlord's Golden Charger
	[231589] = "PALADIN", --Highlord's Valorous Charge
	[231588] = "PALADIN", --Highlord's Vigilant Charger
	[231587] = "PALADIN", --Highlord's Vengeful Charger
	[229377] = "PRIEST", --High Priest's Lightsworn Seeker
	[231434] = "ROGUE", --Shadowblade's Murderous Omen
	[231523] = "ROGUE", --Shadowblade's Lethal Omen
	[231524] = "ROGUE", --Shadowblade's Baneful Omen
	[231525] = "ROGUE", --Shadowblade's Crimson Omen
	[231442] = "SHAMAN", --Farseer's Raging Tempest
	[238452] = "WARLOCK", --Netherlord's Brimstone Wrathsteed
	[238454] = "WARLOCK", --Netherlord's Accursed Wrathsteed
	[232412] = "WARLOCK", --Netherlord's Chaotic Wrathsteed
	[229388] = "WARRIOR", --Battlelord's Bloodthirsty War Wyrm
}
function Mountie:CheckClass(spell)
	if classmounts[spell] then
		if classmounts[spell] == self.db.char.class2 then
			return self.db.char.classmounts
		else
			return false
		end
	end
	return true
end

-- Profession restricted mounts
local TAILORING_ID = 110426
local ENGINEERING_ID = 110403
local profMounts =  {
	[61451] = { TAILORING_ID, 300 }, --Flying Carpet
	[61309] = { TAILORING_ID, 425 }, --Magnificent Flying Carpet
	[75596] = { TAILORING_ID, 425 }, --Frosty Flying Carpet
	
	[44153] = { ENGINEERING_ID, 300 }, --Flying Machine
	[44151] = { ENGINEERING_ID, 375 }, --Turbo-Charged Flying Machine
}
function Mountie:CheckProfession(spell)
	if profMounts[spell] then
		local skill = GetSpellInfo(profMounts[spell][1])
		local req = profMounts[spell][2]
		if self.db.char.prof[skill] then
			return self.db.char.prof[skill] >= req
		else
			return false
		end
	end
	return true
end


------------------------------------------------------------------
-- Setup Macro
------------------------------------------------------------------
function Mountie:SetupMacro()
  if InCombatLockdown() then
    return
  end
    
  -- Create base macro for mount selection
  local index = GetMacroIndexByName("Mountie")
  if index == 0 then
    index = CreateMacro("Mountie", "Ability_Mount_NightmareHorse", "/script MountieButton:Click(GetMouseButtonClicked());", nil)
    Mountie:PrintColored(L["Mountie_MacroCreated"], _Colors.green.lightgreen)
  end
end


--------------------------------------------------
-- Register Slash Commands
--------------------------------------------------
SLASH_RELOADUI1 = "/rl";
SlashCmdList.RELOADUI = ReloadUI;

function Mountie:ChatCommands(msg)
  local msg, msgParam = strsplit(" ", msg, 2)
  
  -- if msg == "minimap" then
  --   Mountie:ToggleMinimapButton()
  -- else
    Mountie:ShowOptionsFrame()
  -- end
end


--------------------------------------------------
-- Main Events
--------------------------------------------------
function Mountie:OnInitialize()
  -- register database
  self.db = LibStub("AceDB-3.0"):New("MountieDB", _defaultConfig, true) -- true = by default all chars use default profile
  self.needReload = false

  self.db.RegisterCallback(self, "OnProfileChanged", "DoReload");
  self.db.RegisterCallback(self, "OnProfileCopied", "DoReload");
  self.db.RegisterCallback(self, "OnProfileReset", "DoReload");

  -- setup options frame
  Mountie_SetupOptionsUI();
  self:SecureHookScript(self.optionsFrame, "OnHide", "OnOptionHide")

  -- setup profile options
  profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("Mountie_Profiles", profileOptions)
  profileSubMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Mountie_Profiles", L["Mountie_Profiles"], L["Mountie_Title_Short"])

  -- setup help site
  --LibStub("AceConfig-3.0"):RegisterOptionsTable("Mountie_Help", nil)
  Mountie_SetupHelpUI();
  --helpSubMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.helpFrame, L["Mountie_Help"], L["Mountie_Title_Short"])

  -- register minimap button
  MountieMiniMapButton:Register("Mountie", LDB, self.db.profile.minimapButton)

  -- register slash commands
  self:RegisterChatCommand("mountie", "ChatCommands")

  -- setup popup dialogs
  Mountie_SetupPopupDialogs()
end

function Mountie:OnEnable()
  -- Setup current character values
  self.db.char.level = UnitLevel("player")
  self.db.char.race = select(2, UnitRace("player"))
  self.db.char.class = UnitClass("player")
  self.db.char.class2 = select(2, UnitClass("player"))
  self.db.char.faction = UnitFactionGroup("player")
  self.db.char.hasRidingSkill = IsSpellKnown(33388) or IsSpellKnown(33391)
  self.db.char.hasFlyingSkill = IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(90265)

	local prof1, prof2 = GetProfessions()
	if prof1 ~= nil then
		local name1, _, rank1 = GetProfessionInfo(prof1)
		local name2, _, rank2 = GetProfessionInfo(prof2)
		self.db.char.prof = {
			[name1] = rank1,
			[name2] = rank2
		}
  end
    
  self:SetupMacro();

  -- Track the current zone and player state for summoning restrictions
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA")						-- new world zone
  self:RegisterEvent("ZONE_CHANGED", "UpdateZoneStatus")			-- new sub-zone
  self:RegisterEvent("ZONE_CHANGED_INDOORS", "UpdateZoneStatus")	-- new city sub-zone
  self:RegisterEvent("SPELL_UPDATE_USABLE", "UpdateZoneStatus")	-- self-explanatory
  
  -- -- Perform an initial scan
  self:RescanMounts()
  self:ZONE_CHANGED_NEW_AREA()

  self:RegisterEvent("ADDON_LOADED")
end

function Mountie:ZONE_CHANGED_NEW_AREA()
	if not InCombatLockdown() then
		_state.zone = C_Map.GetBestMapForUnit("player")
	end
	self:UpdateZoneStatus()
end

function Mountie:UpdateZoneStatus(event)
  if InCombatLockdown() or _state.inCombat or _state.inPetBattle then 
    return 
  end
  
  -- set swimming
  _state.isSwimming = IsSwimming() or IsSubmerged()
  
  -- set flying
  local usable, _ = IsUsableSpell(_flightTest)
  if IsFlyableArea() and usable == true then
    _state.isFlyable = true
  else
    _state.isFlyable = false
  end
end

function Mountie:ADDON_LOADED(event, addon)
	if (addon == "Blizzard_Collections") then
		self:ExtendMountJournal()
	end
end