extends Node

signal load_settings

var SETTINGS_DATA: Dictionary

const dataFolder = "user://"
const fileName = "settings.cfg"
var path = dataFolder + fileName

var noSaveFile: bool


func _ready() -> void:
	DirAccess.make_dir_absolute(dataFolder)
	
	if FileAccess.file_exists(path):
		get_data()
	else:
		noSaveFile = true


func save_data() -> void:
	var config := ConfigFile.new()
	
	for section in SETTINGS_DATA:
		for key in SETTINGS_DATA[section]:
			config.set_value(section, key, SETTINGS_DATA[section][key])
	
	var err = config.save(path)
	
	if err != OK:
		print("Failed to save data!")
		return
	
	if noSaveFile:
		noSaveFile = false


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
