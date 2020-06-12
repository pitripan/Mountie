local L = LibStub("AceLocale-3.0"):GetLocale("Mountie")
local _Colors = Mountie_GetColors()

local _OffsetY_SummonList = 0
local _OffsetY_Default = 0
local _OffsetY_Step = 36
local _IconSize = 32
local _LineHeight = 32
local _HeaderLineHeight = 16
local _SummonList_LinesToShow = 10


--------------------------------------------------
-- UI Widget Functions
--------------------------------------------------
local function createSlider(parent, name, label, description, minVal, maxVal, valStep, onValueChanged, onShow)
  local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
  local editbox = CreateFrame("EditBox", name.."EditBox", slider, "InputBoxTemplate")

  slider:SetMinMaxValues(minVal, maxVal)
  slider:SetValue(minVal)
  slider:SetValueStep(1)
  slider.text = _G[name.."Text"]
  slider.text:SetText(label)
  slider.textLow = _G[name.."Low"]
  slider.textHigh = _G[name.."High"]
  slider.textLow:SetText(floor(minVal))
  slider.textHigh:SetText(floor(maxVal))
  slider.textLow:SetTextColor(0.4,0.4,0.4)
  slider.textHigh:SetTextColor(0.4,0.4,0.4)
  slider.tooltipText = label
  slider.tooltipRequirement = description

  editbox:SetSize(50,30)
  editbox:SetNumeric(true)
  editbox:SetMultiLine(false)
  editbox:SetMaxLetters(5)
  editbox:ClearAllPoints()
  editbox:SetPoint("TOP", slider, "BOTTOM", 0, -5)
  editbox:SetNumber(slider:GetValue())
  editbox:SetCursorPosition(0);
  editbox:ClearFocus();
  editbox:SetAutoFocus(false)
  editbox.tooltipText = label
  editbox.tooltipRequirement = description

	slider:SetScript("OnValueChanged", function(self,value)
		self.editbox:SetNumber(floor(value))
		if(not self.editbox:HasFocus()) then
			self.editbox:SetCursorPosition(0);
			self.editbox:ClearFocus();
		end
        onValueChanged(self, value)
	end)

  slider:SetScript("OnShow", function(self,value)
      onShow(self, value)
  end)

	editbox:SetScript("OnTextChanged", function(self)
		local value = self:GetText()

		if tonumber(value) then
			if(floor(value) > maxVal) then
				self:SetNumber(maxVal)
			end

			if floor(self:GetParent():GetValue()) ~= floor(value) then
				self:GetParent():SetValue(floor(value))
			end
		end
	end)

	editbox:SetScript("OnEnterPressed", function(self)
		local value = self:GetText()
		if tonumber(value) then
			self:GetParent():SetValue(floor(value))
				self:ClearFocus()
		end
	end)

	slider.editbox = editbox
	return slider
end

local function createCheckbox(parent, name, label, description, hideLabel, onClick)
  local check = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  check.label = _G[check:GetName() .. "Text"]
  if not hideLabel then
    check.label:SetText(label)
    check:SetFrameLevel(8)
  end
  check.tooltipText = label
  check.tooltipRequirement = description

  -- events
  check:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    onClick(self, tick and true or false)
  end)

  return check
end

local function createEditbox(parent, name, tooltipTitle, tooltipDescription, width, height, multiline, onTextChanged)
  local editbox = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	editbox:SetSize(width, height)
	editbox:SetMultiLine(multiline)
	editbox:SetFrameLevel(9)
	editbox:ClearFocus()
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnTextChanged", function(self)
		onTextChanged(self)
	end)
	editbox:SetScript("OnEnter", function(self, motion)
    -- MakePeopleGreetAgain_ShowTooltip(self, tooltipTitle, tooltipDescription)
    
    --following function in main lua
    -- function MakePeopleGreetAgain_ShowTooltip(self, title, description)
    --     if self then
    --       GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    --       GameTooltip:SetText(title)
    --       GameTooltip:AddLine(description, 1, 1, 1, true)
    --       GameTooltip:Show()
    --     end
    --   end
	end)
	editbox:SetScript("OnLeave", function(self, motion)
    -- MakePeopleGreetAgain_HideTooltip(self)

    --following function in main lua
    -- function MakePeopleGreetAgain_HideTooltip(self)
    --     GameTooltip:Hide()
    -- end
	end)

  return editbox
end

local function createLabel(parent, name, text)
	local label = parent:CreateFontString(name, "ARTWORK", "GameFontNormal")
	label:SetText(text)
  return label
end

local function createMountLineForConfig(prefix, position)
  local scrollFrameWidth = Mountie.optionsFrame.scrollFrameSummonList:GetWidth()

  -- Texture: item icon
  local wtfNewItemIcon = Mountie.optionsFrame.scrollFrameSummonList:CreateTexture("MountieItemIcon_"..prefix.."_"..position, "ARTWORK")
  wtfNewItemIcon:SetPoint("TOPLEFT", Mountie.optionsFrame.scrollFrameSummonList, "TOPLEFT", 0, _OffsetY_SummonList)
  wtfNewItemIcon:SetWidth(_IconSize)
  wtfNewItemIcon:SetHeight(_IconSize)
  wtfNewItemIcon:Hide()

  -- Button: item name
  local fontForName = CreateFont("fontForName")
  fontForName:SetTextColor(1, 1, 1, 1)

  local wtfNewItemName = CreateFrame("Button", "MountieItemName_"..prefix.."_"..position, Mountie.optionsFrame.scrollFrameSummonList, "Mountie_TransparentButtonTemplate")
  wtfNewItemName:SetPoint("LEFT", wtfNewItemIcon, _IconSize + 4, 0)
  wtfNewItemName:SetText("")
  wtfNewItemName:SetSize(scrollFrameWidth - 80, _LineHeight)
  wtfNewItemName:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(self:GetText())
    GameTooltip:Show()
  end)
  wtfNewItemName:SetNormalFontObject(fontForName)
  wtfNewItemName:SetHighlightFontObject(fontForName)
  wtfNewItemName:GetFontString():SetPoint("LEFT")
  wtfNewItemName:Hide()

  -- Button: ignore item
  local wtfNewItemIgnore = CreateFrame("Button", "MountieItemIgnore_"..prefix.."_"..position, Mountie.optionsFrame.scrollFrameSummonList, "Mountie_ItemIgnoreButtonTemplate")
  wtfNewItemIgnore:SetPoint("RIGHT", wtfNewItemIcon, scrollFrameWidth - _IconSize, 0)
  wtfNewItemIgnore:SetSize(_IconSize, _IconSize)
  wtfNewItemIgnore:Hide()

  -- set new vertical offset
  _OffsetY_SummonList = _OffsetY_SummonList - _OffsetY_Step
end


--------------------------------------------------
-- General Functions
--------------------------------------------------
local function removeItemFromSummonList(itemId)
  if panTableContains(Mountie.db.profile.config.summonList, itemId) == true then
    panRemoveFromArray(Mountie.db.profile.config.summonList, itemId)
  end

  -- refresh UI list
  Mountie_SummonList_Update(Mountie.optionsFrame.scrollFrameSummonList)
end

local function sortSummonListByName(self, button)
  local helperTable = {}
  local linesSorted = {}

  for i = 1, #Mountie.db.profile.config.summonList do
    mountId = Mountie.db.profile.config.summonList[i]

    local creatureName = C_MountJournal.GetMountInfoByID(mountId)

    table.insert(helperTable, {
      mountId = mountId,
      mountName = creatureName
    })
  end

  if button == "LeftButton" then
    table.sort(helperTable, function(a, b)
      return a.mountName < b.mountName
    end)
  elseif button == "RightButton" then
    table.sort(helperTable, function(a, b)
      return a.mountName > b.mountName
    end)
  end

  -- fill sorted array
  for i = 1, #helperTable do
    linesSorted[i] = helperTable[i].mountId
  end

  -- replace old array with sorted array
  Mountie.db.profile.config.summonList = linesSorted

  -- refresh UI list
  Mountie_SummonList_Update()    
end

local function getPartiallyColoredString(text, coloredText, color)
  local colorString = ""
  colorString = "\124cff" .. color .. coloredText .. "\124r"
  return string.format(text, colorString)
end

local function getColoredString(text, color)
  return "\124cff" .. color .. text .. "\124r"
end

--------------------------------------------------
-- Interface Events & Functions
--------------------------------------------------
function Mountie_SetupOptionsUI()
  Mountie.optionsFrame = CreateFrame("Frame", "Mountie_Options", InterfaceOptionsFramePanelContainer)
  Mountie.optionsFrame.name = L["Mountie_Title"]
  Mountie.optionsFrame:SetAllPoints()
  HideUIPanel(Mountie.optionsFrame)

  local title = Mountie.optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 10, -10)
  title:SetText(L["Mountie_Title"])

  -- Minimap Button
  do
    local minimapButtonCheckbox = createCheckbox(
      Mountie.optionsFrame,
      "Mountie_MinimapButton_Checkbox",
      L["Mountie_MinimapButton"],
      L["Mountie_MinimapButton_Desc"],
      false,
      function(self, value)
        Mountie:ToggleMinimapButton()
      end
    )
    minimapButtonCheckbox:SetChecked(not Mountie.db.profile.minimapButton.hide)
    minimapButtonCheckbox:SetPoint("TOPLEFT", layoutLabel, 300, 0)
  end

  -- ignore list
  do
    local ignoreListLabel = createLabel(Mountie.optionsFrame, "ignoreListLabel", L["Mountie_SummonListHeader"])
    ignoreListLabel:SetPoint("TOPLEFT", Mountie.optionsFrame, "TOPLEFT", 20, -80)

    -- setup scroll frame
    Mountie.optionsFrame.scrollFrameSummonList = CreateFrame("ScrollFrame", "Mountie_SummonList_ScrollFrame", Mountie.optionsFrame, "FauxScrollFrameTemplate")
    Mountie.optionsFrame.scrollFrameSummonList:SetPoint("TOPLEFT", Mountie.optionsFrame, "TOPLEFT", 20, -100)
    Mountie.optionsFrame.scrollFrameSummonList:SetPoint("BOTTOMRIGHT", Mountie.optionsFrame, "BOTTOMRIGHT", -36, 16)
    -- Mountie.optionsFrame.scrollFrameSummonList:SetBackdrop({
    --   bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    -- 	--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    --   tile = false,
    --   tileSize = 0,
    --   edgeSize = 32,
    --   insets = { left = 0, right = 0, top = 0, bottom = 0 },
    -- })
    Mountie.optionsFrame.scrollFrameSummonList:SetScript("OnVerticalScroll", function(self, offset)
      FauxScrollFrame_OnVerticalScroll(self, offset, 16, Mountie_SummonList_Update)
    end)
    Mountie.optionsFrame.scrollFrameSummonList:SetScript("OnShow", Mountie_SummonList_Update)

    -- create header line
    do
      local scrollFrameWidth = Mountie.optionsFrame.scrollFrameSummonList:GetWidth()

      local fontForButtons = CreateFont("fontForButtons")
      fontForButtons:SetTextColor(0.3, 0.7, 1.0, 1)

      -- FontString: item icon
      local wtfItemIconHeader = Mountie.optionsFrame.scrollFrameSummonList:CreateFontString("MountieItemIconHeader_SummonList", "OVERLAY", "Mountie_DisplayListFont")
      wtfItemIconHeader:SetPoint("TOPLEFT", Mountie.optionsFrame.scrollFrameSummonList, "TOPLEFT", 0, _OffsetY_SummonList)
      wtfItemIconHeader:SetText("-")
      wtfItemIconHeader:SetTextColor(1, 1, 1, 0)

      -- Button: item name
      local wtfItemNameHeader = CreateFrame("Button", "MountieItemNameHeader_SummonList", Mountie.optionsFrame.scrollFrameSummonList, "Mountie_TransparentButtonTemplate")
      wtfItemNameHeader:SetPoint("LEFT", wtfItemIconHeader, _IconSize + 4, 0)
      wtfItemNameHeader:SetText("Item")
      wtfItemNameHeader:SetSize(scrollFrameWidth - 80, _HeaderLineHeight)
      wtfItemNameHeader:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      wtfItemNameHeader:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(L["Mountie_SortBy_Tooltip"])
        GameTooltip:Show()
      end)
      wtfItemNameHeader:SetScript("OnClick", function(self, button)
        sortSummonListByName(self, button)
      end)
      wtfItemNameHeader:SetNormalFontObject(fontForButtons)
      wtfItemNameHeader:SetHighlightFontObject(fontForButtons)
      wtfItemNameHeader:GetFontString():SetPoint("LEFT")

      -- FontString: ignore item
      local wtfItemIgnoreHeader = Mountie.optionsFrame.scrollFrameSummonList:CreateFontString("MountieItemIgnoreHeader_SummonList", "OVERLAY", "Mountie_DisplayListFont")
      wtfItemIgnoreHeader:SetPoint("RIGHT", wtfItemIconHeader, scrollFrameWidth - _HeaderLineHeight, 0)
      wtfItemIgnoreHeader:SetText("-")
      wtfItemIgnoreHeader:SetTextColor(1, 1, 1, 0)

      -- set new vertical offset
      _OffsetY_SummonList = _OffsetY_SummonList - _HeaderLineHeight
    end

    -- pre-create all lines to show
    for line = 1, _SummonList_LinesToShow, 1 do
      createMountLineForConfig("SummonList", line)
    end
  end

  -- add to interface options
  InterfaceOptions_AddCategory(Mountie.optionsFrame);
end

function Mountie_SummonList_Update()
  local numItems = #Mountie.db.profile.config.summonList

  --function: FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth)
  FauxScrollFrame_Update(Mountie.optionsFrame.scrollFrameSummonList, numItems, _SummonList_LinesToShow, _LineHeight)

  local offset = FauxScrollFrame_GetOffset(Mountie.optionsFrame.scrollFrameSummonList)

  for line = 1, _SummonList_LinesToShow, 1 do
    local lineplusoffset = line + offset
    local mountId = Mountie.db.profile.config.summonList[lineplusoffset]

    if lineplusoffset > numItems then
      -- hide line
      _G["MountieItemName_SummonList_"..line]:Hide()
      _G["MountieItemIcon_SummonList_"..line]:Hide()
      _G["MountieItemIgnore_SummonList_"..line]:Hide()
    else
      local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, 
        action, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountId)

      -- local r, g, b, hex = GetItemQualityColor(itemRarity)

      _G["MountieItemIcon_SummonList_"..line]:SetTexture(icon)
      _G["MountieItemName_SummonList_"..line]:SetText(creatureName)
      -- _G["MountieItemName_SummonList_"..line]:GetFontString():SetTextColor(r, g, b, 1)
      _G["MountieItemIgnore_SummonList_"..line]:SetScript("OnClick", function(self)
        -- removeItemFromSummonList(mountId)
        Mountie:Print(string.format(L["Mountie_SummonList_Unignore"], creatureName))
      end)
      -- show line
      _G["MountieItemIcon_SummonList_"..line]:Show()
      _G["MountieItemName_SummonList_"..line]:Show()
      _G["MountieItemIgnore_SummonList_"..line]:Show()
    end
  end

  Mountie.optionsFrame.scrollFrameSummonList:Show()
end
