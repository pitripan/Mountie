local L = LibStub("AceLocale-3.0"):GetLocale("Mountie")
local _Colors = Mountie_GetColors()


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
  
  if onTextChanged ~= nil then
    editbox:SetScript("OnTextChanged", function(self)
      onTextChanged(self)
    end)
  end

	editbox:SetScript("OnEnter", function(self, motion)
    Mountie_ShowTooltip(self, tooltipTitle, tooltipDescription)
	end)
	editbox:SetScript("OnLeave", function(self, motion)
    Mountie_HideTooltip(self)
	end)

  return editbox
end

local function createLabel(parent, name, text, inheritsFrom, maxLineWidth)  
  inheritsFrom = inheritsFrom or "GameFontNormal"
  maxLineWidth = maxLineWidth or 0
  local label = parent:CreateFontString(name, "ARTWORK", inheritsFrom)  
  
  if maxLineWidth > 0  then
    local tblLines = {}
    local tblWords = {}
    local width = 0
    local str = ""
    local strSaved = ""

    -- split all single words
    for s in string.gmatch(text, "[^ ]+") do
      table.insert(tblWords, s)
    end

    -- iterate each word
    for i = 1, #tblWords do
      if str == "" then
        str = tblWords[i] 
      else 
        str = str .. " " .. tblWords[i]
      end

      -- set text to label and get width of new FontString
      label:SetText(str)
      width = label:GetStringWidth();

      -- check width and create lines
      if width <= maxLineWidth and i < #tblWords then
        strSaved = str
      else     
        if i == #tblWords then
          strSaved = str
        end

        -- create line and clear values
        table.insert(tblLines, strSaved)
        str = ""
        strSaved = ""
      end     
    end

    -- concatenate final string
    local finalLabelText = tblLines[1]
    for j = 2, #tblLines do
      finalLabelText = finalLabelText .. "\n" .. tblLines[j]
    end
    label:SetText(finalLabelText)
  else 
    label:SetText(text)
  end

  return label
end


--------------------------------------------------
-- General Functions
--------------------------------------------------
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
  minimapButtonCheckbox:SetPoint("TOPLEFT", title, 10, -30)

  -- Safe Dismount Button
  local safeDismountButtonCheckbox = createCheckbox(
    Mountie.optionsFrame,
    "Mountie_SafeDismountButton_Checkbox",
    L["Mountie_SafeDismountButton"],
    L["Mountie_SafeDismountButton_Desc"],
    false,
    function(self, value)
      Mountie.db.profile.config.safeDismount= not Mountie.db.profile.config.safeDismount
    end
  )
  safeDismountButtonCheckbox:SetChecked(Mountie.db.profile.config.safeDismount)
  safeDismountButtonCheckbox:SetPoint("TOPLEFT", minimapButtonCheckbox, 0, -24)

  -- add to interface options
  InterfaceOptions_AddCategory(Mountie.optionsFrame);
end

function Mountie_SetupHelpUI()
  local MAX_FRAME_WIDTH = 550

  Mountie.helpFrame = CreateFrame("Frame", "Mountie_Help", Mountie.optionsFrame)
  Mountie.helpFrame.name = L["Mountie_Help"]
  Mountie.helpFrame.parent = Mountie.optionsFrame.name
  Mountie.helpFrame:SetAllPoints()
  HideUIPanel(Mountie.helpFrame)

  local title = Mountie.helpFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 10, -10)
  title:SetText(L["Mountie_Title"] .. " :: " .. L["Mountie_Help"])

  -- Opener
  local helpLabelOpener = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_Opener", L["Mountie_Help_Opener"], "Mountie_HelpFont_Normal", MAX_FRAME_WIDTH)
  helpLabelOpener:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)

  -- Criteria list
  local helpLabelCriteriaList1 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList1", L["Mountie_Help_CriteriaList1"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList1:SetPoint("TOPLEFT", helpLabelOpener, "BOTTOMLEFT", 20, -10)
  local helpLabelCriteriaList2 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList2", L["Mountie_Help_CriteriaList2"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList2:SetPoint("TOPLEFT", helpLabelCriteriaList1, "BOTTOMLEFT", 0, -5)
  local helpLabelCriteriaList3 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList3", L["Mountie_Help_CriteriaList3"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList3:SetPoint("TOPLEFT", helpLabelCriteriaList2, "BOTTOMLEFT", 0, -5)
  local helpLabelCriteriaList4 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList4", L["Mountie_Help_CriteriaList4"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList4:SetPoint("TOPLEFT", helpLabelCriteriaList3, "BOTTOMLEFT", 0, -5)
  local helpLabelCriteriaList5 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList5", L["Mountie_Help_CriteriaList5"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList5:SetPoint("TOPLEFT", helpLabelCriteriaList4, "BOTTOMLEFT", 0, -5)  
  local helpLabelCriteriaList6 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_CriteriaList6", L["Mountie_Help_CriteriaList6"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelCriteriaList6:SetPoint("TOPLEFT", helpLabelCriteriaList5, "BOTTOMLEFT", 0, -5)  

  -- Macro
  local helpLabelMacroOpener = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_MacroOpener", L["Mountie_Help_MacroOpener"], "Mountie_HelpFont_Normal", MAX_FRAME_WIDTH)
  helpLabelMacroOpener:SetPoint("TOPLEFT", helpLabelCriteriaList6, "BOTTOMLEFT", -20, -15)

  local helpEditBoxMacroCommand = createEditbox(
    Mountie.helpFrame, 
    "Mountie_HelpEditBox_MacroCommand", 
    "", 
    "", 
    400, 
    30, 
    false, 
    function(self)
      self:SetText(L["Mountie_Help_MacroCommand"])
    end
  )
  helpEditBoxMacroCommand:SetPoint("TOPLEFT", helpLabelMacroOpener, "BOTTOMLEFT", 20, -5)
  helpEditBoxMacroCommand:SetText(L["Mountie_Help_MacroCommand"])
  
  -- Selection opener
  local helpLabelSelectionOpener = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionOpener", L["Mountie_Help_SelectionOpener"], "Mountie_HelpFont_Normal", MAX_FRAME_WIDTH)
  helpLabelSelectionOpener:SetPoint("TOPLEFT", helpEditBoxMacroCommand, "BOTTOMLEFT", -20, -15)

  -- Selection priority list
  local helpLabelSelectionPriorityList1 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList1", L["Mountie_Help_SelectionPriorityList1"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList1:SetPoint("TOPLEFT", helpLabelSelectionOpener, "BOTTOMLEFT", 20, -10)
  local helpLabelSelectionPriorityList2 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList2", L["Mountie_Help_SelectionPriorityList2"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList2:SetPoint("TOPLEFT", helpLabelSelectionPriorityList1, "BOTTOMLEFT", 0, -5)
  local helpLabelSelectionPriorityList3 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList3", L["Mountie_Help_SelectionPriorityList3"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList3:SetPoint("TOPLEFT", helpLabelSelectionPriorityList2, "BOTTOMLEFT", 0, -5)
  local helpLabelSelectionPriorityList4 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList4", L["Mountie_Help_SelectionPriorityList4"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList4:SetPoint("TOPLEFT", helpLabelSelectionPriorityList3, "BOTTOMLEFT", 0, -5)
  local helpLabelSelectionPriorityList5 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList5", L["Mountie_Help_SelectionPriorityList5"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList5:SetPoint("TOPLEFT", helpLabelSelectionPriorityList4, "BOTTOMLEFT", 0, -5)
  local helpLabelSelectionPriorityList6 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList6", L["Mountie_Help_SelectionPriorityList6"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList6:SetPoint("TOPLEFT", helpLabelSelectionPriorityList5, "BOTTOMLEFT", 0, -5)
  local helpLabelSelectionPriorityList7 = createLabel(Mountie.helpFrame, "Mountie_HelpLabel_SelectionPriorityList7", L["Mountie_Help_SelectionPriorityList7"], "Mountie_HelpFont_Small", MAX_FRAME_WIDTH)
  helpLabelSelectionPriorityList7:SetPoint("TOPLEFT", helpLabelSelectionPriorityList6, "BOTTOMLEFT", 0, -5)  

  -- add to interface options
  InterfaceOptions_AddCategory(Mountie.helpFrame);
end