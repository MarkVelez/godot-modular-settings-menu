@tool
extends EditorPlugin

var pluginPath: String = get_script().resource_path.get_base_dir()
const settingsDataManagerPath: String = "/singletons/settings_data_manager.gd"


func _enter_tree():
	add_autoload_singleton("SettingsDataManager", pluginPath + settingsDataManagerPath)


func _exit_tree():
	remove_autoload_singleton("SettingsDataManager")
