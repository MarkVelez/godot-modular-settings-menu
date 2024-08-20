extends Control
class_name SettingsMenu

## Emitted when the settings menu is made visible.
signal settings_menu_opened
## Emitted when the apply button is pressed.
signal apply_button_pressed
## Emitted when the settings menu is hidden.
signal settings_menu_closed
## Emitted when changes are discarded.
signal changes_discarded

## Used to check if gameplay related settings should be applied
@export var IS_IN_GAME_MENU: bool = true
## Reference to the parent node of the menu UI.
## The node this references will get set visible when pressing the back button.
@export var MenuPanelRef: Node
## List of settings sections that should be left out of the settings menu instance.
@export var IGNORED_SECTIONS_: Array[String]


@onready var DiscardChangesRef: PanelContainer = $DiscardChangesPopup
@onready var SettingsPanelRef: VBoxContainer = $SettingsPanel
@onready var ApplyButtonRef: Button = %ApplyButton

var ElementPanelsRef: Control
var SettingsTabsRef: TabContainer


func _enter_tree() -> void:
	ElementPanelsRef = $ElementPanels
	SettingsTabsRef = $SettingsPanel/SettingsTabs
	ignore_sections()


func _ready():
	# Load the settings menu
	SettingsDataManager.call_deferred("emit_signal", "settings_retrieved")


func on_back_button_pressed() -> void:
	# Check if there have been any changes made
	if ApplyButtonRef.is_disabled():
		hide()
		MenuPanelRef.show()
		# Clear the settings cache
		emit_signal("settings_menu_closed")
	else:
		# Display the discard changes popup
		display_discard_changes(self)


func on_apply_button_pressed() -> void:
	ApplyButtonRef.set_disabled(true)
	# Apply the settings of each section
	emit_signal("apply_button_pressed")
	# Save the updated settings data
	SettingsDataManager.call_deferred("save_data")
	# Reset the changed elements count
	SettingsDataManager.changedElementsCount = 0


func on_visibility_changed() -> void:
	if is_visible_in_tree():
		emit_signal("settings_menu_opened")


# Called to discard the changes in the settings menu
func discard_changes() -> void:
	emit_signal("changes_discarded")
	for SectionRef in SettingsTabsRef.get_children():
		SectionRef.discard_changes()


func display_discard_changes(CallerRef: Control) -> void:
	DiscardChangesRef.show()
	DiscardChangesRef.CallerRef = CallerRef


func ignore_sections() -> void:
	for SectionRef in SettingsTabsRef.get_children():
		if IGNORED_SECTIONS_.has(SectionRef.IDENTIFIER):
			SectionRef.queue_free()
