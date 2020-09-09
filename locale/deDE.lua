local L = LibStub("AceLocale-3.0"):NewLocale("Mountie", "deDE")
if not L then return end

-- Put the language in this locale here
L["Loaded language"] = "Deutsch"


--------------------------------------------------
-- General
--------------------------------------------------
L["Mountie_Title"] = "Mountie"
L["Mountie_Title_Short"] = "Mountie"

L["Mountie_Yes"] = "Ja"
L["Mountie_No"] = "Nein"

L["Mountie_PerformReload"] = "Das Interface muss neu geladen werden, damit Mountie weiterhin ordnungsgemäß funktioniert.\n\nMöchtest du das UI jetzt neu laden?"
L["Mountie_NotReloaded"] = "Das Interface wurde nicht neu geladen. Deine Änderungen sind noch nicht gültig."

L["Mountie_MacroCreated"] = "Das Makro [Mountie] wurde in den allgemeinen Makros erstellt."


--------------------------------------------------
-- UI elements
--------------------------------------------------
L["Mountie_MMBTooltipTitle"] = "Mountie"
L["Mountie_MMBTooltipInfo"] = "\124cffFF4500Linksklick:\124r Öffne die Hilfeseite.\n\124cffFF4500Rechtsklick:\124r Öffne das Optionsmenü."

L["Mountie_MinimapButton"] = "Minikarten Schaltfläche"
L["Mountie_MinimapButton_Desc"] = "Zeigt oder versteckt die Schaltfläche an der Minikarte."

L["Mountie_SafeDismountButton"] = "Sicheres Absitzen"
L["Mountie_SafeDismountButton_Desc"] = "Wenn aktiviert, ist es nicht möglich während des Fliegens von einem Reittier abzusitzen."

L["Mountie_SummonList_Add"] = "Das Reittier [%s] wurde auf die Beschwörungsliste gesetzt."
L["Mountie_SummonList_Remove"] = "Das Reittier [%s] wurde von der Beschwörungsliste entfernt."

L["Mountie_Profiles"] = "Profile"


--------------------------------------------------
-- Help
--------------------------------------------------
L["Mountie_Help"] = "Hilfe"

L["Mountie_Help_Opener"] = "Mithilfe von Mountie kannst du in deiner Reittiersammlung bestimmte Reittiere markieren (Checkbox rechts), die dann über das Makro 'Mountie' zufällig aufgerufen werden können. Die Auswahl des nächsten Reittiers erfolgt anhand bestimmter Kriterien:"

L["Mountie_Help_CriteriaList1"] = "- der Charakter hat die Fähigkeit Bodenreittiere zu benutzen"
L["Mountie_Help_CriteriaList2"] = "- der Charakter hat die Fähigkeit Flugreittiere zu benutzen"
L["Mountie_Help_CriteriaList3"] = "- ist es möglich am aktuellen Standort des Charakters zu fliegen"
L["Mountie_Help_CriteriaList4"] = "- befindet sich der Charakter schwimmend im Wasser"
L["Mountie_Help_CriteriaList5"] = "- gibt es spezielle Reittiere für diese Zone"
L["Mountie_Help_CriteriaList6"] = "- wurden Reittiere des entsprechenden Typs für Mountie zur Zufallsauswahl markiert"

L["Mountie_Help_MacroOpener"] = "Um Mountie zu verwenden, kannst du dir aus deinen allgemeinen Makros einfach das 'Mountie'-Makro in deine Aktionsleiste ziehen oder alternativ ein eigenes Makro erstellen. Dieses sollte dann folgenden Aufruf beinhalten:"
L["Mountie_Help_MacroCommand"] = "/script MountieButton:Click(GetMouseButtonClicked());"

L["Mountie_Help_SelectionOpener"] = "Für die Auswahl des nächsten zufälligen Reittiers - vorausgesetzt, dass du mindestens ein Reittier des jeweiligen Typs für Mountie markiert hast - gibt es folgende Reihenfolge der Prioritäten:"

L["Mountie_Help_SelectionPriorityList1"] = "- Falls dein Charakter über keinerlei Reitfähigkeiten verfügt oder du keine Reittiere für Mountie markiert hast, wird versucht das jeweilige Chauffeur-Reittier der Fraktion zu beschwören, falls du es freigeschaltet hast."
L["Mountie_Help_SelectionPriorityList2"] = "- Falls sich dein Charakter in Ahn'Qiraj befindet und du die dortigen speziellen Reitdrohnen freigeschaltet hast, werden diese priorisiert ausgewählt."
L["Mountie_Help_SelectionPriorityList3"] = "- Falls dein Charakter gerade im Wasser schwimmt und du zusätzlich die [Shift]-Taste gedrückt hältst, wird ein Flugreittier beschworen, sofern du im aktuellen Gebiet fliegen kannst."
L["Mountie_Help_SelectionPriorityList4"] = "- Falls dein Charakter gerade im Wasser schwimmt und du zusätzlich die [Shift]-Taste gedrückt hältst, wird ein Bodenreittier beschworen, sofern du im aktuellen Gebiet nicht fliegen kannst oder keine Flugreittiere für Mountie markiert wurden."
L["Mountie_Help_SelectionPriorityList5"] = "- Falls dein Charakter gerade im Wasser schwimmt, wird ein Wasserreittier beschworen. Sofern keine Wasserreittiere für Mountie markiert wurden, wird versucht ein Flugreittier auszuwählen. Sollte dies nicht möglich sein, da du im aktuellen Gebiet nicht fliegen kannst, wird anschließend versucht ein Bodenreittier zu beschwören."
L["Mountie_Help_SelectionPriorityList6"] = "- Falls dein Charakter im aktuellen Gebiet fliegen kann, wird versucht ein Flugreittier zu beschwören. Sofern keine Flugreittiere für Mountie markiert wurden, wird versucht ein Bodenreittier auszuwählen."
L["Mountie_Help_SelectionPriorityList7"] = "- In allen anderen Fällen wird versucht ein Bodenreittier zu beschwören. Sofern keine Bodenreittiere für Mountie markiert wurden, wird versucht ein Flugreittier (natürlich nur zum Reiten auf dem Boden) auszuwählen."


--------------------------------------------------
-- Error messages
--------------------------------------------------
