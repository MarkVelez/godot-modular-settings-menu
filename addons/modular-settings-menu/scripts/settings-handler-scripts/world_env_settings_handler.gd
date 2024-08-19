extends Node

@export var WorldEnvRef: WorldEnvironment

@onready var EnvironmentRef: Environment = WorldEnvRef.environment


func _ready():
	SettingsDataManager.connect("applied_in_game_setting", apply_in_game_settings)


# Called by elements to apply in game settings
func apply_in_game_settings(section: String, element: String, value) -> void:
	match element:
		"SSRQuality":
			if SettingsDataManager.settingsData_[section][element] == "Disabled":
				EnvironmentRef.set_ssr_enabled(false)
				return
			EnvironmentRef.set_ssr_enabled(true)
			EnvironmentRef.set_ssr_max_steps(value["maxSteps"])
			EnvironmentRef.set_ssr_fade_in(value["fadeIn"])
			EnvironmentRef.set_ssr_fade_out(value["fadeOut"])
		
		"SSAOQuality":
			EnvironmentRef.set_ssao_enabled(
				false if value == "Disabled" else true
			)
		
		"SSILQuality":
			EnvironmentRef.set_ssil_enabled(
				false if value == "Disabled" else true
			)
		
		"SDFGIQuality":
			EnvironmentRef.set_sdfgi_enabled(
				false if value == "Disabled" else true
			)
		
		"GlowQuality":
			EnvironmentRef.set_glow_enabled(
				false if value == "Disabled" else true
			)
