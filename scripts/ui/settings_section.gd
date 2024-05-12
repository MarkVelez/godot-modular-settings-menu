extends TabBar

signal apply_settings

# Name of the settings section (used as the key for the section in the settings data)
@onready var section: String = name

# Reference table of all elements under the section (does not include sub elements)
var REFERENCE_TABLE: Dictionary
# Cache of all the settings values for the section
var SETTINGS_SECTION_CACHE: Dictionary


func _ready():
	# Connect neccessary signals from the central root node for the settings
	owner.connect("get_settings", get_settings)
	owner.connect("clear_cache", clear_cache)
	
	# Add section to the settings data if no save file exists
	if SettingsDataManager.noSaveFile:
		SettingsDataManager.SETTINGS_DATA = {
			name: {}
		}


# Called when opening the settings menu to fill the settings cache
func get_settings() -> void:
	# Copy the settings data for the section into it's cache
	SETTINGS_SECTION_CACHE = SettingsDataManager.SETTINGS_DATA[section].duplicate(true)
	
	# If no save file exists saved the default values retrieved from the section's elements
	if SettingsDataManager.noSaveFile:
		SettingsDataManager.call_deferred("save_data")


# Called to clear the section's cache
func clear_cache() -> void:
	SETTINGS_SECTION_CACHE.clear()


# Called to check for changes between the cache and the settings data
func settings_changed() -> void:
	# Enable/disable the apply button if there are or aren't differences
	if SETTINGS_SECTION_CACHE == SettingsDataManager.SETTINGS_DATA[section]:
		owner.applyButton.set_disabled(true)
	else:
		owner.applyButton.set_disabled(false)


# Called to saved the data in the section's cache to the settings data and apply the settings to the game
func on_apply_settings() -> void:
	SettingsDataManager.SETTINGS_DATA[section] = SETTINGS_SECTION_CACHE.duplicate(true)
	SettingsDataManager.save_data()
	emit_signal("apply_settings")
