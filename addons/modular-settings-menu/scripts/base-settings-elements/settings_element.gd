extends Control
class_name SettingsElement
## The base script for settings elements.

## Identifier for the element.
## This value is used as the key in the settings data.
@export var IDENTIFIER: String = "Element"

## Toggle based on whether the element handles a setting that requires an in game node to exist.
@export var IS_IN_GAME_SETTING: bool

## The name of the section the element is under.
@onready var SECTION: String = ParentRef.IDENTIFIER

## Reference to the section the settings element is under.
var ParentRef: SettingsSection

# Multi element flags
## Flag to turn an element into the main element of a multi element.
var IS_MULTI_ELEMENT: bool = false
## Flag to turn an element into a sub element of a multi element.
var IS_SUB_ELEMENT: bool = false

## Current value of the element.
var currentValue


func _enter_tree() -> void:
	if not IS_MULTI_ELEMENT:
		ParentRef = owner


func _ready() -> void:
	SettingsDataManager.connect("settings_retrieved", load_settings)
	# Check if the element is a sub element
	if not IS_SUB_ELEMENT:
		ParentRef.connect("apply_button_pressed", _apply_settings)
		# Add an entry of the settings element to the section's reference table
		ParentRef.ELEMENT_REFERENCE_TABLE_[IDENTIFIER] = self


## Used to initialize a settings element.
## This function is overwritten by each [b]type[/b] of element.
func init_element() -> void:
	return


## Loads the saved or default value of the element.
func load_settings() -> void:
	# List of valid values for the element
	var VALUES_: Dictionary = get_valid_values()
	VALUES_.make_read_only()
	
	# Check if no save file exists
	if SettingsDataManager.noSaveFile:
		# Assign default value as current value
		currentValue = VALUES_["defaultValue"]
		# Add default value of element to the settings data
		SettingsDataManager.settingsData_[SECTION][IDENTIFIER] = currentValue
	else:
		# Verify the existance and validity of the element in the settings data
		if verify_settings_data(VALUES_):
			# Get the current value from the settings data
			currentValue = SettingsDataManager.settingsData_[SECTION][IDENTIFIER]
		else:
			# Assign default value as current value
			currentValue = VALUES_["defaultValue"]
			# Add default value of the element to the settings data
			SettingsDataManager.settingsData_[SECTION][IDENTIFIER] = currentValue
			SettingsDataManager.invalidSaveFile = true
	
	init_element()
	
	# Check if the current element is in an in game menu or if it is a sub element
	if (
		ParentRef.SettingsMenuRef.IS_IN_GAME_MENU == IS_IN_GAME_SETTING
		or not IS_SUB_ELEMENT
	):
		# Apply the loaded values to the game
		call_deferred("_apply_settings")


## Used to get the valid values an element can have for validating settings data.
## This function is overwritten by each [b]type[/b] of element.
func get_valid_values() -> Dictionary:
	return {}


## Checks if the loaded values are valid for the element.
## If a value is wrong, it will be fixed automatically.
func verify_settings_data(VALUES_: Dictionary) -> bool:
	# Check if an entry exists for the element
	if not entry_exists():
		return false
	
	# Get the value of the element
	var RETRIEVED_VALUE = SettingsDataManager.settingsData_[SECTION][IDENTIFIER]
	
	# Check if the retrieved value is the correct type
	if not is_valid_type(VALUES_, RETRIEVED_VALUE):
		return false
	
	# Check if the retrieved value has the expected value
	if not is_valid_value(VALUES_, RETRIEVED_VALUE):
		return false
	
	return true


## Used by verify_settings_data() to check if the element 
## and the section it is under exists in the settings data.
func entry_exists() -> bool:
	# Check if the section exists in settings data
	if not SettingsDataManager.settingsData_.has(SECTION):
		push_warning("Settings section missing: ", SECTION)
		return false
	
	# Check if the element exists in the settings data
	if not SettingsDataManager.settingsData_[SECTION].has(IDENTIFIER):
		push_warning("Settings element is missing: ", IDENTIFIER)
		return false
	
	return true


## Used by verify_settings_data() to check if the retrieved value has the correct type.
func is_valid_type(VALUES_: Dictionary, RETRIEVED_VALUE) -> bool:
	if typeof(RETRIEVED_VALUE) != typeof(VALUES_["defaultValue"]):
		push_warning(
			"Invalid value type of '"
			+ type_string(typeof(RETRIEVED_VALUE))
			+ "' for element '"
			+ IDENTIFIER
			+ "' expected value type of '"
			+ type_string(typeof(VALUES_["defaultValue"]))
			+ "'"
		)
		return false
	
	return true


## Used by verify_settings_data() to check if the retrieved value has a valid value.
func is_valid_value(VALUES_: Dictionary, RETRIEVED_VALUE) -> bool:
	# Get the type of the valid value
	match typeof(VALUES_["defaultValue"]):
		# If the type is either string or bool
		TYPE_STRING, TYPE_BOOL:
			# Check if the retrieved value is valid
			if not VALUES_["validOptions"].has(RETRIEVED_VALUE):
				push_warning(
					"Invalid value '"
					+ str(RETRIEVED_VALUE)
					+ "' for element '"
					+ IDENTIFIER
					+ "' expected values: "
					+ str(VALUES_["validOptions"])
				)
				return false
		# If the type is either int or float
		TYPE_INT, TYPE_FLOAT:
			# Check if the retrieved value is valid
			if (
				RETRIEVED_VALUE < VALUES_["minValue"]
				or RETRIEVED_VALUE > VALUES_["maxValue"]
			):
				# Special check if max fps is set to 0 (unlimited)
				if IDENTIFIER == "MaxFPS" and RETRIEVED_VALUE == 0:
					return true
				
				push_warning(
					"Invalid value "
					+ str(RETRIEVED_VALUE)
					+ " for element '"
					+ IDENTIFIER
					+ "' expected values between "
					+ str(VALUES_["minValue"])
					+ " and "
					+ str(VALUES_["maxValue"])
				)
				return false
	
	return true


## Used to apply in game settings that require a node to exist to be applied,
## i.e., world environment related settings and or most gameplay settings.
func apply_in_game_setting(value = null) -> bool:
	if ParentRef.SettingsMenuRef.IS_IN_GAME_MENU:
		SettingsDataManager.call_deferred(
			"emit_signal",
			"applied_in_game_setting",
			SECTION,
			IDENTIFIER,
			value
		)
		return true
	
	return false


## Called to apply the setting to the game.
## This function is overwritten by each [b]element[/b].
func _apply_settings() -> void:
	return
