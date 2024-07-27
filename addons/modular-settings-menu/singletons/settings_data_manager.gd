extends Node
## Handles the loading and saving of settings data.

## Emitted when loading the settings data.
signal load_settings
## Emitted when applying specific settings to in game objects.
signal apply_in_game_settings(section: StringName, setting: StringName, value)

## Resource for common functions between settings elements.
const ElementResource: Resource = preload("../resources/settings_element_resource.tres")

## Path to the settings save file.
var dataFolder: String = OS.get_user_data_dir()
## Name of the file that the settings data is saved in.
const fileName: String = "settings"
## Extension for the save file.
const fileExtension: String = ".cfg"
## The path to the save file on the computer.
var path: String = dataFolder + "/" + fileName + fileExtension

## Dictionary that stores all settings data.
var SETTINGS_DATA: Dictionary
## A reference table of all sections.
var SECTION_REFERENCE_TABLE: Dictionary
## A reference table of all element panels.
var ELEMENT_PANEL_REFERENCE_TABLE: Dictionary

## The number of elements that have been changed since the settings have been saved.
var changedElementsCount: int = 0

## Flag for checking if a save file exists.
var noSaveFile: bool
## Flag for checking if an invalid value was found in the save file.
var invalidSaveFile: bool = false


func _ready() -> void:
	# Verify the directory
	DirAccess.make_dir_absolute(dataFolder)
	
	# Check if a save file exists
	if FileAccess.file_exists(path):
		# Proceed normally by retrieving data from the save file
		call_deferred(&"get_data")
	else:
		# Enable the no save file flag
		noSaveFile = true
		push_warning("No save file found")


## Called to save the settings data to the save file.
func save_data() -> void:
	# Create a new config instance
	var config := ConfigFile.new()
	
	# Add the data from the settings data dictionary
	for section in SETTINGS_DATA:
		for element in SETTINGS_DATA[section]:
			config.set_value(section, element, SETTINGS_DATA[section][element])
	
	# Save the data to the specified directory
	var err = config.save(path)
	
	# Check for errors
	if err != OK:
		push_error("Failed to save data: ", err)
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
	var err := config.load(path)
	# Temporary data dictionary
	var DATA: Dictionary = {}
	
	# Check for errors
	if err != OK:
		push_error("Failed to load settings data: ", err)
		return
	
	# Add the retrieved data to the settings data dictionary
	for section in config.get_sections():
		DATA[section] = {}
		for key in config.get_section_keys(section):
			DATA[section][key] = config.get_value(section, key)
	
	# Verify the validity of the loaded data
	verify_settings_data(DATA)
	
	# Copy the retrieved data into the settings data dictionary
	SETTINGS_DATA = DATA.duplicate(true)


## Checks if the save file has any invalid entries and removes them or adds missing sections.
func verify_settings_data(DATA: Dictionary) -> void:
	# List of valid entries to compare to
	var VALID_ENTRIES: Dictionary = SECTION_REFERENCE_TABLE.duplicate()
	# Merge the element panel references into the valid entries
	VALID_ENTRIES.merge(ELEMENT_PANEL_REFERENCE_TABLE)
	# List of invalid entries to be removed
	var INVALID_ENTRIES: Dictionary = {}
	
	# Itterate through the loaded settings data
	for section in DATA:
		if is_valid_section(INVALID_ENTRIES, section):
			verify_elements(DATA, INVALID_ENTRIES, section)
	
	# Check if there are any sections missing from the retrieved data
	check_for_missing_sections(DATA, VALID_ENTRIES)
	
	# Check if there are any invalid entries
	if INVALID_ENTRIES.size() > 0:
		# Set the invalid save file flag to true
		invalidSaveFile = true
		remove_invalid_entries(DATA, INVALID_ENTRIES, VALID_ENTRIES)


## Used by the verify_settings_data() function to verify the retrieved sections.
func is_valid_section(INVALID_ENTRIES: Dictionary, section: String) -> bool:
	# Check if the section is in either of the reference tables
	if SECTION_REFERENCE_TABLE.has(section) or ELEMENT_PANEL_REFERENCE_TABLE.has(section):
		return true
		
	# Add the invalid section to the invalid entries list
	INVALID_ENTRIES[section] = []
	push_warning("Invalid section '", section, "' found")
	return false


## Used by the verify_settings_data() function to verify the elements inside of the retrieved sections.
func verify_elements(DATA: Dictionary, INVALID_ENTRIES: Dictionary, section: String) -> void:
	# Array of all elements under the section
	var VALID_SECTION_ELEMENTS: Array = get_valid_elements(section)
	
	# Itterate through all the elements in the section
	for element in DATA[section]:
		# Check for invalid elements
		if not VALID_SECTION_ELEMENTS.has(element):
			# Check if the element is in a valid section
			if not INVALID_ENTRIES.has(section):
				# Add the section to the invalid entries list
				INVALID_ENTRIES[section] = []
			
			# Add the invalid element to the invalid entries list
			INVALID_ENTRIES[section].append(element)
			push_warning("Invalid element '", element, "' found in section '", section, "'")


## Used by the verify_elements() function to retrieve the valid elements for the retrieved section.
func get_valid_elements(section: String) -> Array:
	# Check if the section is a settings section
	if SECTION_REFERENCE_TABLE.has(section):
		return SECTION_REFERENCE_TABLE[section].ELEMENT_REFERENCE_TABLE.keys()
	
	# Check if the section is an element panel
	if ELEMENT_PANEL_REFERENCE_TABLE.has(section):
		return ELEMENT_PANEL_REFERENCE_TABLE[section].ELEMENT_REFERENCE_TABLE.keys()
	
	return []


## Used by the verify_settings_data() function to check if any expected sections are missing.
func check_for_missing_sections(DATA: Dictionary, VALID_ENTRIES: Dictionary) -> void: 
	# Itterate through all valid sections
	for section in VALID_ENTRIES:
		# Check if the section is missing from the loaded data
		if not DATA.has(section):
			# Add an empty entry for the section
			DATA[section] = {}
			# Set the invalid save file flag to true
			invalidSaveFile = true
			push_warning("Settings section is missing: ", section)


## Used by the verify_settings_data() function to remove invalid entires from the retrieved data.
func remove_invalid_entries(DATA: Dictionary, INVALID_ENTRIES: Dictionary, VALID_ENTRIES: Dictionary) -> void:
	# Itterate through the sections in the invalid entries list
	for section in INVALID_ENTRIES:
		# Check if the section is valid
		if VALID_ENTRIES.has(section):
			# Itterate through the invalid elements
			for element in INVALID_ENTRIES[section]:
				# Remove the invalid element
				DATA[section].erase(element)
		else:
			# Remove the invalid section
			DATA.erase(section)
