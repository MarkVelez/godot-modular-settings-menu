extends TabBar

signal apply_settings

# Name of the settings section (used as the key for the section in the settings data)
@onready var section: StringName = name
# Reference to the settings menu node
@onready var settingsMenu: Node = owner

# Reference table of all elements under the section
var ELEMENT_REFERENCE_TABLE: Dictionary
# Cache of all the settings values for the section
var SETTINGS_SECTION_CACHE: Dictionary
# A list of all the elements that were changed since the settings were last applied
var CHANGED_ELEMENTS: Array[StringName]


func _ready():
	# Connect neccessary signals from the central root node for the settings
	settingsMenu.connect("get_settings", get_settings)
	settingsMenu.connect("apply_settings", on_apply_settings)
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


# Called to clear the section's cache
func clear_cache() -> void:
	SETTINGS_SECTION_CACHE.clear()


# Called to check for changes between the cache and the settings data
func settings_changed(element: StringName) -> void:
	# Check if there are differences between the cache and the settings data
	if SETTINGS_SECTION_CACHE[element] == SettingsDataManager.SETTINGS_DATA[section][element]:
		settingsMenu.applyButton.set_disabled(true)
		# Check if the element is on the changed elements list
		if CHANGED_ELEMENTS.has(element):
			# Remove the element from the list
			CHANGED_ELEMENTS.erase(element)
	else:
		settingsMenu.applyButton.set_disabled(false)
		# Check if the element is not the changed elements list
		if not CHANGED_ELEMENTS.has(element):
			# Add the element to the list
			CHANGED_ELEMENTS.append(element)


# Called to saved the data in the section's cache to the settings data and apply the settings to the game
func on_apply_settings() -> void:
	# Check if any of the sections elements have been changed
	if CHANGED_ELEMENTS.size() > 0:
		# Copy the section cache into the settings data dictionary
		SettingsDataManager.SETTINGS_DATA[section] = SETTINGS_SECTION_CACHE.duplicate(true)
		
		# Apply the settings for the changed elements
		for element in CHANGED_ELEMENTS:
			ELEMENT_REFERENCE_TABLE[element].apply_settings()
		
		# Clear the changed elements array
		CHANGED_ELEMENTS.clear()


func discard_changes() -> void:
	# Check if any of the sections elements have been changed
	if CHANGED_ELEMENTS.size() > 0:
		# Load the saved settings for each element in the section
		for element in CHANGED_ELEMENTS:
			ELEMENT_REFERENCE_TABLE[element].load_settings()
		
		# Clear the changed elements array
		CHANGED_ELEMENTS.clear()
