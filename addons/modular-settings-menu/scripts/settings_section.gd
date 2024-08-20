extends Control
class_name SettingsSection
## The base script for settings sections.

## Emitted when the apply button is pressed.
signal apply_button_pressed
## Emitted when a setting has it's value changed.
signal setting_changed(elementId: String)

## Identifier for the section.
## This value is used as the key in the settings data.
@export var IDENTIFIER: String

## Reference to the settings menu node.
var SettingsMenuRef: SettingsMenu

## Reference table of all elements under the section.
var ELEMENT_REFERENCE_TABLE_: Dictionary
## Cache of all the settings values for the section.
var settingsCache_: Dictionary
## A list of all the elements that were changed since the settings were last applied.
var changedElements_: Array[String]


func _enter_tree() -> void:
	SettingsMenuRef = owner


func _ready():
	# Connect neccessary signals from the central root node for the settings
	SettingsMenuRef.connect("settings_menu_opened", get_settings)
	SettingsMenuRef.connect("apply_button_pressed", on_apply_settings)
	SettingsMenuRef.connect("settings_menu_closed", clear_cache)
	
	# Add a reference of the section to the reference table
	SettingsDataManager.SECTION_REFERENCE_TABLE_[IDENTIFIER] = self
	
	# Check if a save file exists
	if SettingsDataManager.noSaveFile:
		# Add the section to the settings data dictionary
		SettingsDataManager.settingsData_[IDENTIFIER] = {}


## Called when opening the settings menu to fill the settings cache.
func get_settings() -> void:
	# Copy the settings data for the section into it's cache
	settingsCache_ =\
		SettingsDataManager.settingsData_[IDENTIFIER].duplicate(true)
	
	# If no save file exists saves the default values retrieved from the section's elements
	if SettingsDataManager.noSaveFile or SettingsDataManager.invalidSaveFile:
		SettingsDataManager.call_deferred("save_data")
	
	# Clear the changed elements array
	changedElements_.clear()


## Called to clear the section's cache.
func clear_cache() -> void:
	settingsCache_.clear()


## Called when a setting has been changed.
func settings_changed(elementId: String) -> void:
	SettingsMenuRef.ApplyButtonRef.set_disabled(check_for_changes(elementId))
	emit_signal("setting_changed", elementId)


## Called to check for changes between the cache and the settings data.
func check_for_changes(elementId: String) -> bool:
	var cacheValue = settingsCache_[elementId]
	var savedValue = SettingsDataManager.settingsData_[IDENTIFIER][elementId]
	# Check if there are differences between the cache and the settings data
	if cacheValue == savedValue:
		# Check if the element is on the changed elements list
		if changedElements_.has(elementId):
			# Remove the element from the list
			changedElements_.erase(elementId)
			# Decrease the changed elements count
			SettingsDataManager.changedElementsCount -= 1
			
		# Check if there are any other changed elements
		if SettingsDataManager.changedElementsCount == 0:
			# Disabled the apply button
			return true
	
	# Check if the element is not the changed elements list
	if not changedElements_.has(elementId):
		# Add the element to the list
		changedElements_.append(elementId)
		# Increase the changed elements count
		SettingsDataManager.changedElementsCount += 1
	
	# Enable the apply button
	return false


## Called to saved the data in the section's cache to the settings data
## and apply the settings to the game.
func on_apply_settings() -> void:
	# Check if any of the sections elements have been changed
	if changedElements_.size() > 0:
		# Copy the section cache into the settings data dictionary
		SettingsDataManager.settingsData_[IDENTIFIER] = settingsCache_.duplicate(true)
		
		# Apply the settings for the changed elements
		for element in changedElements_:
			ELEMENT_REFERENCE_TABLE_[element]._apply_settings()
		
		# Clear the changed elements array
		changedElements_.clear()


## Called to discard changes that have been made since the last save.
func discard_changes() -> void:
	# Check if any of the sections elements have been changed
	if changedElements_.size() > 0:
		# Load the saved settings for each element in the section
		for element in changedElements_:
			ELEMENT_REFERENCE_TABLE_[element].load_settings()
		
		# Clear the changed elements array
		changedElements_.clear()
