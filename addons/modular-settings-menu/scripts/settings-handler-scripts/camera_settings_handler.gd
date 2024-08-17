extends Node

@export var CameraRef: Camera3D


func _ready():
	# Connect neccessary signal
	SettingsDataManager.connect("applied_in_game_setting", apply_in_game_settings)


# Called to apply in game settings for the specific node
func apply_in_game_settings(section: String, element: String, _value) -> void:
	match element:
		"FOV":
			# Set the camera FOV to the value stored in the settings data dictionary
			CameraRef.set_fov(SettingsDataManager.settingsData_[section][element])
		"DepthOfField":
			var enabled: bool
			# Check if the current value of the element is disabled
			if SettingsDataManager.settingsData_[section][element] == "Disabled":
				enabled = false
			else:
				enabled = true
			
			# Disable/Enable DOF
			CameraRef.attributes.set_dof_blur_far_enabled(enabled)
			CameraRef.attributes.set_dof_blur_near_enabled(enabled)
