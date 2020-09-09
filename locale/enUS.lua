local L = LibStub("AceLocale-3.0"):NewLocale("Mountie", "enUS", true)

-- Put the language in this locale here
L["Loaded language"] = "English"


--------------------------------------------------
-- General
--------------------------------------------------
L["Mountie_Title"] = "Mountie"
L["Mountie_Title_Short"] = "Mountie"

L["Mountie_Yes"] = "Yes"
L["Mountie_No"] = "No"

L["Mountie_PerformReload"] = "The interface needs to be reloaded for Mountie to continue to work properly.\n\nDo you want to reload the UI now?"
L["Mountie_NotReloaded"] = "The interface has not been reloaded. Your changes are not valid yet."

L["Mountie_MacroCreated"] = "The [Mountie] macro was created in the general macros."


--------------------------------------------------
-- UI elements
--------------------------------------------------
L["Mountie_MMBTooltipTitle"] = "Mountie"
L["Mountie_MMBTooltipInfo"] = "\124cffFF4500Left-click:\124r Open the help page.\n\124cffFF4500Right-click:\124r Open the options menu."

L["Mountie_MinimapButton"] = "Minimap button"
L["Mountie_MinimapButton_Desc"] = "Shows or hides the minimap button."

L["Mountie_SafeDismountButton"] = "Safe dismounting"
L["Mountie_SafeDismountButton_Desc"] = "When enabled, it is not possible to dismount from a mount while flying."

L["Mountie_SummonList_Add"] = "The mount [%s] has been added to the summoning list."
L["Mountie_SummonList_Remove"] = "The mount [%s] has been removed from the summoning list."

L["Mountie_Profiles"] = "Profiles"


--------------------------------------------------
-- Help
--------------------------------------------------
L["Mountie_Help"] = "Help"

L["Mountie_Help_Opener"] = "Mountie allows you to select certain mounts in your mount journal (checkbox on the right), which can then be randomly summoned via the 'Mountie' macro. The selection of the next mount is based on certain criteria:"

L["Mountie_Help_CriteriaList1"] = "- the character has the ability to use ground mounts"
L["Mountie_Help_CriteriaList2"] = "- the character has the ability to use flying mounts"
L["Mountie_Help_CriteriaList3"] = "- it is possible to fly at the current location of the character"
L["Mountie_Help_CriteriaList4"] = "- the character is swimming in the water"
L["Mountie_Help_CriteriaList5"] = "- there are special mounts for this zone"
L["Mountie_Help_CriteriaList6"] = "- mounts of the corresponding type were marked for random selection"

L["Mountie_Help_MacroOpener"] = "To use Mountie, you can simply drag the 'Mountie' macro from your general macros into your action bar or alternatively create your own macro. This macro should then contain the following call:"
L["Mountie_Help_MacroCommand"] = "/script MountieButton:Click(GetMouseButtonClicked());"

L["Mountie_Help_SelectionOpener"] = "For the selection of the next random mount - provided that you have at least one mount of that type selected for Mountie - the order of priority is as follows:"

L["Mountie_Help_SelectionPriorityList1"] = "- If your character does not have any riding abilities or you have no mounts marked for Mountie, it will try to summon the faction's chauffeur mount if you have unlocked it."
L["Mountie_Help_SelectionPriorityList2"] = "- If your character is in Ahn'Qiraj and you have unlocked the special riding drones there, they will be prioritized."
L["Mountie_Help_SelectionPriorityList3"] = "- If your character is swimming in the water and you hold down the [Shift] key, a flying mount will be summoned if you can fly in the current area."
L["Mountie_Help_SelectionPriorityList4"] = "- If your character is currently swimming in the water and you hold down the [Shift] key, a ground mount will be summoned if you cannot fly in the current area or if no flying mounts are selected for Mountie."
L["Mountie_Help_SelectionPriorityList5"] = "- If your character is currently swimming in the water, a water mount is summoned. If no water mounts have been marked for Mountie, an attempt is made to select a flying mount. If this is not possible because you cannot fly in the current area, the addon will try to summon a ground mount."
L["Mountie_Help_SelectionPriorityList6"] = "- If your character is able to fly in the current area, it will try to summon a flying mount. If no flying mounts are selected for Mountie, the addon will try to select a ground mount."
L["Mountie_Help_SelectionPriorityList7"] = "- In all other cases, an attempt is made to summon a ground mount. If no ground mounts are marked for Mountie, the addon will try to select a flying mount (only for riding on the ground, of course)."


--------------------------------------------------
-- Error messages
--------------------------------------------------
