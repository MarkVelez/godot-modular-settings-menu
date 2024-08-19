extends Node

@export var CameraRef: Camera3D


func _ready():
	# Connect neccessary signal
	SettingsDataManager.connect("applied_in_game_setting", apply_in_game_settings)


# Called to apply in game settings for the specific node
func apply_in_game_settings(section: String, element: String, value) -> void:
	match element:
		"FOV":
			CameraRef.set_fov(value)
		"DepthOfField":
			var enabled: bool = false if value == "Disabled" else true
			# Disable/Enable DOF
			CameraRef.attributes.set_dof_blur_far_enabled(enabled)
			CameraRef.attributes.set_dof_blur_near_enabled(enabled)
