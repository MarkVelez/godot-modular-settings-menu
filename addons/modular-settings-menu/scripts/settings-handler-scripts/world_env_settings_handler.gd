extends Node

@export var WorldEnvRef: WorldEnvironment

# List of functions for the settings appropriate for the object
const SETTINGS_FUNCTIONS_: Dictionary = {
	"SSRQuality": "set_ssr_settings",
	"SSAOQuality": "set_ssao_settings",
	"SSILQuality": "set_ssil_settings",
	"SDFGIQuality": "set_sdfgi_settings",
	"GlowQuality": "set_glow_settings"
}

@onready var EnvironmentRef: Environment = WorldEnvRef.environment


func _ready():
	SettingsDataManager.connect("applied_in_game_setting", apply_in_game_settings)


# Called by elements to apply in game settings
func apply_in_game_settings(section: String, element: String, value = null) -> void:
	# Check if the call was for this object
	if SETTINGS_FUNCTIONS_.has(element):
		# Call the appropriate function for the setting
		call(SETTINGS_FUNCTIONS_[element], section, element, value)


# Used to set the SSR settings
func set_ssr_settings(section: String, element: String, value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.settingsData_[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSR and return
		EnvironmentRef.set_ssr_enabled(false)
		return
	
	# Enable SSR
	EnvironmentRef.set_ssr_enabled(true)
	# Set max steps for SSR
	EnvironmentRef.set_ssr_max_steps(value["maxSteps"])
	# Set fade in distance for SSR
	EnvironmentRef.set_ssr_fade_in(value["fadeIn"])
	# Set fade out distance for SSR
	EnvironmentRef.set_ssr_fade_out(value["fadeOut"])


# Used to set the SSAO settings
func set_ssao_settings(section: String, element: String, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.settingsData_[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSAO and return
		EnvironmentRef.set_ssao_enabled(false)
		return
	
	# Enable SSAO
	EnvironmentRef.set_ssao_enabled(true)


# Used to set the SSIL settings
func set_ssil_settings(section: String, element: String, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.settingsData_[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSIL and return
		EnvironmentRef.set_ssil_enabled(false)
		return
	
	# Enable SSIL
	EnvironmentRef.set_ssil_enabled(true)


# Used to set the SDFGI settings
func set_sdfgi_settings(section: String, element: String, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.settingsData_[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SDFGI and return
		EnvironmentRef.set_sdfgi_enabled(false)
		return
	
	# Enable SDFGI
	EnvironmentRef.set_sdfgi_enabled(true)


# Used to set the Glow settings
func set_glow_settings(section: String, element: String, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.settingsData_[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable Glow and return
		EnvironmentRef.set_glow_enabled(false)
		return
	
	# Enable Glow
	EnvironmentRef.set_glow_enabled(true)
