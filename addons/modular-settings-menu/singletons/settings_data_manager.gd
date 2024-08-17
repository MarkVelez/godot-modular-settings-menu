extends Node
## Handles the loading and saving of settings data.

## Emitted when loading the settings data.
signal settings_retrieved
## Emitted when applying specific settings to in game objects.
signal applied_in_game_setting(section: String, setting: String, value)

## PATH to the settings save file.
var DATA_FOLDER: String = OS.get_user_data_dir()
## Name of the file that the settings data is saved in.
const FILE_NAME: String = "settings"
## Extension for the save file.
const FILE_EXTENSION: String = ".cfg"
## The PATH to the save file on the computer.
var PATH: String = DATA_FOLDER + "/" + FILE_NAME + FILE_EXTENSION

## Dictionary that stores all settings data.
var settingsData_: Dictionary
## A reference table of all sections.
var SECTION_REFERENCE_TABLE_: Dictionary
## A reference table of all element panels.
var ELEMENT_PANEL_REFERENCE_TABLE_: Dictionary

## The number of elements that have been changed since the settings have been saved.
var changedElementsCount: int = 0

## Flag for checking if a save file exists.
var noSaveFile: bool
## Flag for checking if an invalid value was found in the save file.
var invalidSaveFile: bool = false


func _ready() -> void:
	# Verify the directory
	DirAccess.make_dir_absolute(DATA_FOLDER)
	
	# Check if a save file exists
	if FileAccess.file_exists(PATH):
		# Proceed normally by retrieving data from the save file
		call_deferred("get_data")
	else:
		# Enable the no save file flag
		noSaveFile = true
		push_warning("No save file found")


## Called to save the settings data to the save file.
func save_data() -> void:
	# Create a new config instance
	var config := ConfigFile.new()
	
	# Add the data from the settings data dictionary
	for section in settingsData_:
		for element in settingsData_[section]:
			config.set_value(section, element, settingsData_[section][element])
	
	# Save the data to the specified directory
	var err = config.save(PATH)
	
	# Check for errors
	if err != OK:
		push_error("Failed to save data_: ", err)
		return
	
	# Disable the no save file flag if it was enabled
	if noSaveFile:
		noSaveFile = false
	
	# Disable the invalid save file flag if it was enabled
	if invalidSaveFile:
		invalidSaveFile = false


## Called to retrieve data from the save file.
func get_data() -> void:
	# Create a new config instance
	var config := ConfigFile.new()
	# Load the save data
	var err := config.load(PATH)
	# Temporary data dictionary
	var data_: Dictionary = {}
	
	# Check for errors
	if err != OK:
		push_error("Failed to load settings data_: ", err)
		return
	
	# Add the retrieved data to the settings data dictionary
	for section in config.get_sections():
		data_[section] = {}
		for key in config.get_section_keys(section):
			data_[section][key] = config.get_value(section, key)
	
	# Verify the validity of the loaded data
	verify_settings_data_(data_)
	
	# Copy the retrieved data into the settings data dictionary
	settingsData_ = data_.duplicate(true)


## Checks if the save file has any invalid entries and removes them or adds missing sections.
func verify_settings_data_(data_: Dictionary) -> void:
	# List of valid entries to compare to
	var validEntries_: Dictionary = SECTION_REFERENCE_TABLE_.duplicate()
	# Merge the element panel references into the valid entries
	validEntries_.merge(ELEMENT_PANEL_REFERENCE_TABLE_)
	# List of invalid entries to be removed
	var invalidEntries_: Dictionary = {}
	
	# Itterate through the loaded settings data
	for section in data_:
		if is_valid_section(invalidEntries_, section):
			verify_elements(data_, invalidEntries_, section)
	
	# Check if there are any sections missing from the retrieved data
	check_for_missing_sections(data_, validEntries_)
	
	# Check if there are any invalid entries
	if invalidEntries_.size() > 0:
		# Set the invalid save file flag to true
		invalidSaveFile = true
		remove_invalid_entries(data_, invalidEntries_, validEntries_)


## Used by the verify_settings_data() function to verify the retrieved sections.
func is_valid_section(invalidEntries_: Dictionary, SECTION: String) -> bool:
	# Check if the section is in either of the reference tables
	if (
		SECTION_REFERENCE_TABLE_.has(SECTION)
		or ELEMENT_PANEL_REFERENCE_TABLE_.has(SECTION)
	):
		return true
		
	# Add the invalid section to the invalid entries list
	invalidEntries_[SECTION] = []
	push_warning("Invalid section '", SECTION, "' found.")
	return false


## Used by the verify_settings_data() function to verify the elements inside of the retrieved sections.
func verify_elements(
	data_: Dictionary,
	invalidEntries_: Dictionary,
	SECTION: String
) -> void:
	# Array of all elements under the section
	var VALID_SECTION_ELEMENTS: Array = get_valid_elements(SECTION)
	
	# Itterate through all the elements in the section
	for element in data_[SECTION]:
		# Check for invalid elements
		if not VALID_SECTION_ELEMENTS.has(element):
			# Check if the element is in a valid section
			if not invalidEntries_.has(SECTION):
				# Add the section to the invalid entries list
				invalidEntries_[SECTION] = []
			
			# Add the invalid element to the invalid entries list
			invalidEntries_[SECTION].append(element)
			push_warning(
				"Invalid element '"
				+ element
				+ "' found in section '"
				+ SECTION
				+ "'."
			)


## Used by the verify_elements() function to retrieve the valid elements for the retrieved section.
func get_valid_elements(SECTION: String) -> Array:
	# Check if the section is a settings section
	if SECTION_REFERENCE_TABLE_.has(SECTION):
		return SECTION_REFERENCE_TABLE_[SECTION].ELEMENT_REFERENCE_TABLE_.keys()
	
	# Check if the section is an element panel
	if ELEMENT_PANEL_REFERENCE_TABLE_.has(SECTION):
		return ELEMENT_PANEL_REFERENCE_TABLE_[SECTION].ELEMENT_REFERENCE_TABLE_.keys()
	
	return []


## Used by the verify_settings_data() function to check if any expected sections are missing.
func check_for_missing_sections(data_: Dictionary, validEntries_: Dictionary) -> void: 
	# Itterate through all valid sections
	for section in validEntries_:
		# Check if the section is missing from the loaded data_
		if not data_.has(section):
			# Add an empty entry for the section
			data_[section] = {}
			# Set the invalid save file flag to true
			invalidSaveFile = true
			push_warning("Settings section is missing: ", section)


## Used by the verify_settings_data() function to remove invalid entires from the retrieved data.
func remove_invalid_entries(
	data_: Dictionary,
	invalidEntries_: Dictionary,
	validEntries_: Dictionary
) -> void:
	# Itterate through the sections in the invalid entries list
	for section in invalidEntries_:
		# Check if the section is valid
		if validEntries_.has(section):
			# Itterate through the invalid elements
			for element in invalidEntries_[section]:
				# Remove the invalid element
				data_[section].erase(element)
		else:
			# Remove the invalid section
			data_.erase(section)
