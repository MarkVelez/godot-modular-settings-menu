extends Node

@export var worldEnv: WorldEnvironment

# List of functions for the settings appropriate for the object
const SETTINGS_FUNCTIONS: Dictionary = {
	"SSRQuality": &"set_ssr_settings",
	"SSAOQuality": &"set_ssao_settings",
	"SSILQuality": &"set_ssil_settings",
	"SDFGIQuality": &"set_sdfgi_settings",
	"GlowQuality": &"set_glow_settings"
}

@onready var env: Environment = worldEnv.environment


func _ready():
	SettingsDataManager.connect(&"apply_in_game_settings", apply_in_game_settings)


# Called by elements to apply in game settings
func apply_in_game_settings(section: StringName, element: StringName, value = null) -> void:
	# Check if the call was for this object
	if SETTINGS_FUNCTIONS.has(element):
		# Call the appropriate function for the setting
		call(SETTINGS_FUNCTIONS[element], section, element, value)


# Used to set the SSR settings
func set_ssr_settings(section: StringName, element: StringName, value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSR and return
		env.set_ssr_enabled(false)
		return
	
	# Enable SSR
	env.set_ssr_enabled(true)
	# Set max steps for SSR
	env.set_ssr_max_steps(value["maxSteps"])
	# Set fade in distance for SSR
	env.set_ssr_fade_in(value["fadeIn"])
	# Set fade out distance for SSR
	env.set_ssr_fade_out(value["fadeOut"])


# Used to set the SSAO settings
func set_ssao_settings(section: StringName, element: StringName, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSAO and return
		env.set_ssao_enabled(false)
		return
	
	# Enable SSAO
	env.set_ssao_enabled(true)


# Used to set the SSIL settings
func set_ssil_settings(section: StringName, element: StringName, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SSIL and return
		env.set_ssil_enabled(false)
		return
	
	# Enable SSIL
	env.set_ssil_enabled(true)


# Used to set the SDFGI settings
func set_sdfgi_settings(section: StringName, element: StringName, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable SDFGI and return
		env.set_sdfgi_enabled(false)
		return
	
	# Enable SDFGI
	env.set_sdfgi_enabled(true)


# Used to set the Glow settings
func set_glow_settings(section: StringName, element: StringName, _value) -> void:
	# Get the value of the element
	var elementValue: String = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the element value is disabled
	if elementValue == "Disabled":
		# Disable Glow and return
		env.set_glow_enabled(false)
		return
	
	# Enable Glow
	env.set_glow_enabled(true)
