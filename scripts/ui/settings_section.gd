extends TabBar

signal apply_settings

# Name of the settings section (used as the key for the section in the settings data)
@onready var section: StringName = name
# Reference to the settings menu node
@onready var settingsMenu: Control = owner

# Reference table of all elements under the section
var ELEMENT_REFERENCE_TABLE: Dictionary
# Cache of all the settings values for the section
var SETTINGS_SECTION_CACHE: Dictionary
# A list of all the elements that were changed since the settings were last applied
var CHANGED_ELEMENTS: Array[StringName]


func _ready():
	# Connect neccessary signals from the central root node for the settings
	settingsMenu.connect("get_settings", get_settings)
	settingsMenu.connect("clear_cache", clear_cache)
	
	# Add a reference of the section toe the reference table
	SettingsDataManager.SECTION_REFERENCE_TABLE[section] = self
	
	# Check if a save file exists
	if SettingsDataManager.noSaveFile:
		# Add the section to the settings data dictionary
		SettingsDataManager.SETTINGS_DATA[section] = {}


# Called when opening the settings menu to fill the settings cache
func get_settings() -> void:
	# Copy the settings data for the section into it's cache
	SETTINGS_SECTION_CACHE = SettingsDataManager.SETTINGS_DATA[section].duplicate(true)
	
	# If no save file exists saves the default values retrieved from the section's elements
	if SettingsDataManager.noSaveFile or SettingsDataManager.invalidSaveFile:
		SettingsDataManager.call_deferred("save_data")
	
	CHANGED_ELEMENTS.clear()


# Called to clear the section's cache
func clear_cache() -> void:
	SETTINGS_SECTION_CACHE.clear()


# Called to check for changes between the cache and the settings data
func settings_changed(element: String) -> void:
	# Check if there are differences between the cache and the settings data
	if SETTINGS_SECTION_CACHE == SettingsDataManager.SETTINGS_DATA[section]:
		settingsMenu.applyButton.set_disabled(true)
	else:
		if not CHANGED_ELEMENTS.has(element):
			CHANGED_ELEMENTS.append(element)
		settingsMenu.applyButton.set_disabled(false)


# Called to saved the data in the section's cache to the settings data and apply the settings to the game
func on_apply_settings() -> void:
	SettingsDataManager.SETTINGS_DATA[section] = SETTINGS_SECTION_CACHE.duplicate(true)
	SettingsDataManager.save_data()
	
	for element in CHANGED_ELEMENTS:
		ELEMENT_REFERENCE_TABLE[element].apply_settings()
	
	CHANGED_ELEMENTS.clear()


func discard_changes() -> void:
	# Load the saved settings for each element in the section
	for element in CHANGED_ELEMENTS:
		ELEMENT_REFERENCE_TABLE[element].load_settings()
	
	# Clear the changed elements array
	CHANGED_ELEMENTS.clear()
