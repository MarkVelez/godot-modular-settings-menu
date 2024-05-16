extends Node

signal load_settings
signal apply_in_game_settings(section: StringName, setting: StringName)

# Dictionary that stores all settings data
var SETTINGS_DATA: Dictionary
# List of settings that need to be applied when the game scene has been loaded
# Used when the settings menu is not an in game one
var IN_GAME_SETTINGS: Dictionary

# Path to the settings save file
const dataFolder: String = "user://"
const fileName: String = "settings.cfg"
var path: String = dataFolder + fileName

# Flag for checking if a save file exists
var noSaveFile: bool


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
