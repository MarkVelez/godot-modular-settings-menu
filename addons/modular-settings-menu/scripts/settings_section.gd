extends TabBar

signal apply_settings

# Reference to the settings menu node
@export var SettingsMenuRef: Node

# IDENTIFIER for the section (used as the key for the section in the settings data)
@export var IDENTIFIER: String

# Reference table of all elements under the section
var ELEMENT_REFERENCE_TABLE_: Dictionary
# Cache of all the settings values for the section
var settingsCache_: Dictionary
# A list of all the elements that were changed since the settings were last applied
var changedElements_: Array[String]


func _ready():
	# Connect neccessary signals from the central root node for the settings
	SettingsMenuRef.connect("get_settings", get_settings)
	SettingsMenuRef.connect("apply_settings", on_apply_settings)
	SettingsMenuRef.connect("clear_cache", clear_cache)
	
	# Add a reference of the section to the reference table
	SettingsDataManager.SECTION_REFERENCE_TABLE_[IDENTIFIER] = self
	
	# Check if a save file exists
	if SettingsDataManager.noSaveFile:
		# Add the section to the settings data dictionary
		SettingsDataManager.settingsData_[IDENTIFIER] = {}


# Called when opening the settings menu to fill the settings cache
func get_settings() -> void:
	# Copy the settings data for the section into it's cache
	settingsCache_ = SettingsDataManager.settingsData_[IDENTIFIER].duplicate(true)
	
	# If no save file exists saves the default values retrieved from the section's elements
	if SettingsDataManager.noSaveFile or SettingsDataManager.invalidSaveFile:
		SettingsDataManager.call_deferred("save_data")
	
	# Clear the changed elements array
	changedElements_.clear()


# Called to clear the section's cache
func clear_cache() -> void:
	settingsCache_.clear()


# Called to check for changes between the cache and the settings data
func settings_changed(element: StringName) -> void:
	# Check if there are differences between the cache and the settings data
	if settingsCache_[element] == SettingsDataManager.settingsData_[IDENTIFIER][element]:
		# Check if the element is on the changed elements list
		if changedElements_.has(element):
			# Remove the element from the list
			changedElements_.erase(element)
			# Decrease the changed elements count
			SettingsDataManager.changedElementsCount -= 1
			
		# Check if there are any other changed elements
		if SettingsDataManager.changedElementsCount == 0:
			# Disabled the apply button
			SettingsMenuRef.applyButton.set_disabled(true)
	else:
		SettingsMenuRef.applyButton.set_disabled(false)
		# Check if the element is not the changed elements list
		if not changedElements_.has(element):
			# Add the element to the list
			changedElements_.append(element)
			# Increase the changed elements count
			SettingsDataManager.changedElementsCount += 1


# Called to saved the data in the section's cache to the settings data and apply the settings to the game
func on_apply_settings() -> void:
	# Check if any of the sections elements have been changed
	if changedElements_.size() > 0:
		# Copy the section cache into the settings data dictionary
		SettingsDataManager.settingsData_[IDENTIFIER] = settingsCache_.duplicate(true)
		
		# Apply the settings for the changed elements
		for element in changedElements_:
			ELEMENT_REFERENCE_TABLE_[element].apply_settings()
		
		# Clear the changed elements array
		changedElements_.clear()


func discard_changes() -> void:
	# Check if any of the sections elements have been changed
	if changedElements_.size() > 0:
		# Load the saved settings for each element in the section
		for element in changedElements_:
			ELEMENT_REFERENCE_TABLE_[element].load_settings()
		
		# Clear the changed elements array
		changedElements_.clear()
