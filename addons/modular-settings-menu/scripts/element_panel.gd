extends SettingsSection

# Panel node references
@onready var BackButtonRef: Button = $VBoxContainer/HBoxContainer/BackButton
@onready var ApplyButtonRef: Button = $VBoxContainer/HBoxContainer/ApplyButton

# Reference to the element this panel belongs to
var PanelOwnerRef: ButtonElement


func _ready():
	# Connect neccessary signals
	BackButtonRef.connect("pressed", on_back_pressed)
	ApplyButtonRef.connect("pressed", on_apply_settings)
	
	# Add a reference of the section to the reference table
	SettingsDataManager.ELEMENT_PANEL_REFERENCE_TABLE_[IDENTIFIER] = self
	
	# Check if a save file exists
	if SettingsDataManager.noSaveFile:
		# Add the section to the settings data dictionary
		SettingsDataManager.settingsData_[IDENTIFIER] = {}
	
	SettingsMenuRef = owner
	# Load the settings of the elements inside of the panel
	call_deferred("init_elements")


# Called to load the settings of the elements inside of the panel
func init_elements() -> void:
	for element in ELEMENT_REFERENCE_TABLE_:
		ELEMENT_REFERENCE_TABLE_[element].load_settings()


func settings_changed(elementId: String) -> void:
	ApplyButtonRef.set_disabled(check_for_changes(elementId))


func on_back_pressed():
	# Check if there have been any changes made
	if ApplyButtonRef.is_disabled():
		# Clear the cache and return normally
		settingsCache_.clear()
		hide()
		SettingsMenuRef.SettingsPanelRef.show()
	else:
		SettingsMenuRef.display_discard_changes(self)


func on_apply_settings():
	super.on_apply_settings()
	# Save the updated settings data
	SettingsDataManager.call_deferred("save_data")
	ApplyButtonRef.set_disabled(true)
