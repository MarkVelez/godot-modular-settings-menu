extends TabBar

signal apply_settings

@onready var section: String = name

var REFERENCE_TABLE: Dictionary
var SETTINGS_CACHE: Dictionary


func _ready():
	owner.connect("get_settings", get_settings)
	owner.connect("clear_cache", clear_cache)
	
	if SettingsDataManager.noSaveFile:
		SettingsDataManager.SETTINGS_DATA = {
			name: {}
		}


func get_settings() -> void:
	SETTINGS_CACHE = SettingsDataManager.SETTINGS_DATA[section].duplicate(true)
	
	if SettingsDataManager.noSaveFile:
		SettingsDataManager.call_deferred("save_data")


func clear_cache() -> void:
	SETTINGS_CACHE.clear()


func settings_changed() -> void:
	if SETTINGS_CACHE == SettingsDataManager.SETTINGS_DATA[section]:
		owner.applyButton.set_disabled(true)
	else:
		owner.applyButton.set_disabled(false)


func on_apply_settings() -> void:
	SettingsDataManager.SETTINGS_DATA[section] = SETTINGS_CACHE.duplicate(true)
	SettingsDataManager.save_data()
	emit_signal("apply_settings")
