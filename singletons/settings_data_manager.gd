extends Node

signal set_default_value
signal load_settings

var DEFAULT_SETTINGS: Dictionary
var SETTINGS_DATA: Dictionary

const dataFolder = "user://"
const fileName = "settings.cfg"
var path = dataFolder + fileName


func _ready() -> void:
	DirAccess.make_dir_absolute(dataFolder)
	if !FileAccess.file_exists(path):
		emit_signal("set_default_value")
		SETTINGS_DATA = DEFAULT_SETTINGS.duplicate(true)
		save_data()
	else:
		get_data()


func save_data() -> void:
	var config := ConfigFile.new()
	
	for section in SETTINGS_DATA:
		for key in SETTINGS_DATA[section]:
			config.set_value(section, key, SETTINGS_DATA[section][key])
	
	var err = config.save(path)
	
	if err != OK:
		print("Failed to save data!")


func get_data() -> void:
	var config := ConfigFile.new()
	var err := config.load(path)
	
	if err != OK:
		print("Failed to load settings data!")
		return
	
	for section in config.get_sections():
		SETTINGS_DATA[section] = {}
		for key in config.get_section_keys(section):
			SETTINGS_DATA[section][key] = config.get_value(section, key)
	
	emit_signal("load_settings")
