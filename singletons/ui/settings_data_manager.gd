extends Node

signal load_settings
signal apply_in_game_settings(section: StringName, setting: StringName, value)

# Dictionary that stores all settings data
var SETTINGS_DATA: Dictionary
# Used to check for unused sections and elements in settings data
var VALID_SETTINGS: Dictionary
# List of settings that need to be applied when the game scene has been loaded
# Used when the settings menu is not an in game one
var IN_GAME_SETTINGS: Dictionary

# Path to the settings save file
var dataFolder: String = OS.get_user_data_dir()
var fileName: String = "/settings.cfg"
var path: String = dataFolder + fileName

# Flag for checking if a save file exists
var noSaveFile: bool
# Flat for checking if an invalid value was found in the save file
var invalidSaveFile: bool = false


func _ready() -> void:
	# Verify the directory
	DirAccess.make_dir_absolute(dataFolder)
	
	# Check if a save file exists
	if FileAccess.file_exists(path):
		# Proceed normally by retrieving data from the save file
		get_data()
	else:
		# Enable the no save file flag
		noSaveFile = true
	
	# Call signal for loading all settings at the end of the frame to let the elements initialize
	call_deferred("emit_signal", "load_settings")
	call_deferred("verify_settings_data")


# Called to save the settings data to the save file
func save_data() -> void:
	# Create a new config instance
	var config := ConfigFile.new()
	
	# Add the data from the settings data dictionary
	for section in SETTINGS_DATA:
		for key in SETTINGS_DATA[section]:
			config.set_value(section, key, SETTINGS_DATA[section][key])
	
	# Save the data to the specified directory
	var err = config.save(path)
	
	# Check for errors
	if err != OK:
		print("Failed to save data!")
		print(err)
		return
	
	# Disable the no save file flag if it was enabled
	if noSaveFile:
		noSaveFile = false
	
	# Disable the invalid save file flag if it was enabled
	if invalidSaveFile:
		invalidSaveFile = false


# Called to retrieve data from the save file
func get_data() -> void:
	# Create a new config instance
	var config := ConfigFile.new()
	# Load the save data
	var err := config.load(path)
	
	# Check for errors
	if err != OK:
		print("Failed to load settings data!")
		print(err)
		return
	
	# Add the retrieved data to the settings data dictionary
	for section in config.get_sections():
		SETTINGS_DATA[section] = {}
		for key in config.get_section_keys(section):
			SETTINGS_DATA[section][key] = config.get_value(section, key)


# Used for verifying the integrity of the save file
func verify_settings_data() -> void:
	# List of invalid entries to be removed
	var INVALID_ENTRIES: Dictionary = {}
	
	# Itterate through the loaded settings data
	for section in SETTINGS_DATA:
		# Check for invalid sections
		if !VALID_SETTINGS.has(section):
			# Add the invalid section to the invalid entries list
			INVALID_ENTRIES[section] = []
			print("Invalid section ", section, " found!")
		else:
			# Itterate through all the elements in the section
			for element in SETTINGS_DATA[section]:
				# Check for invalid elements
				if !VALID_SETTINGS[section].has(element):
					# Check if the element is in a valid section
					if !INVALID_ENTRIES.has(section):
						# Add the section to the invalid entries list
						INVALID_ENTRIES[section] = []
					
					# Add the invalid element to the invalid entries list
					INVALID_ENTRIES[section].append(element)
					print("Invalid element ", element, " found in section ", section, "!")
	
	# Check if there are any invalid entries
	if INVALID_ENTRIES.size() > 0:
		# Set the invalid save file flag to true
		invalidSaveFile = true
		
		# Itterate through the sections in the invalid entries list
		for section in INVALID_ENTRIES:
			# Check if the section is invalid
			if !VALID_SETTINGS.has(section):
				# Remove the invalid section
				SETTINGS_DATA.erase(section)
			else:
				# Itterate through the invalid elements
				for element in INVALID_ENTRIES[section]:
					# Remove the invalid element
					SETTINGS_DATA[section].erase(element)
