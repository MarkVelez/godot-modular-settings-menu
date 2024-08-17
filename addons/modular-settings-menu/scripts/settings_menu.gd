extends Control
class_name SettingsMenu

signal get_settings
signal apply_settings
signal clear_cache

## Used to check if gameplay related settings should be applied
@export var IS_IN_GAME_MENU: bool = true
## Reference to the parent node of the menu UI.
## The node this references will get set visible when pressing the back button.
@export var MenuPanelRef: Node
## List of settings sections to be added to the settings menu.
@export var SETTINGS_SECTIONS_: Array[PackedScene]

@onready var DiscardChangesRef: PanelContainer = $DiscardChangesPopup
@onready var SettingsPanelRef: VBoxContainer = $SettingsPanel
@onready var ApplyButtonRef: Button = %ApplyButton

var ElementPanelsRef: Control
var SettingsTabsRef: TabContainer


func _enter_tree() -> void:
	ElementPanelsRef = $ElementPanels
	SettingsTabsRef = $SettingsPanel/SettingsTabs
	add_sections()


func _ready():
	# Load the settings data
	SettingsDataManager.call_deferred("emit_signal", "load_settings")


func back_button_pressed() -> void:
	# Check if there have been any changes made
	if ApplyButtonRef.is_disabled():
		hide()
		MenuPanelRef.show()
		# Clear the settings cache
		emit_signal("clear_cache")
	else:
		# Display the discard changes popup
		display_discard_changes(self)


func apply_button_pressed() -> void:
	ApplyButtonRef.set_disabled(true)
	# Apply the settings of each section
	emit_signal("apply_settings")
	# Save the updated settings data
	SettingsDataManager.call_deferred("save_data")
	# Reset the changed elements count
	SettingsDataManager.changedElementsCount = 0


# Called to discard the changes in the current section
func discard_changes() -> void:
	# Discard the changes in the current section
	SettingsTabsRef.get_child(SettingsTabsRef.current_tab).discard_changes()


func display_discard_changes(CallerRef: Control) -> void:
	DiscardChangesRef.show()
	DiscardChangesRef.CallerRef = CallerRef


func add_sections() -> void:
	for SectionScene in SETTINGS_SECTIONS_:
		var SectionRef: SettingsSection = SectionScene.instantiate()
		SettingsTabsRef.add_child(SectionRef)
		SectionRef.SettingsMenuRef = self