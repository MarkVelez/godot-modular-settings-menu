extends SettingsElement
class_name SliderElement
## A settings element specifically for elements that have a slider.

# Default values for the element
@export var MIN_VALUE: float = 0
@export var MAX_VALUE: float = 1
@export var STEP_VALUE: float = 0.1
@export var DEFAULT_VALUE: float = 1

## If true, displays 0 to 100 instead of 0 to 1 in the settings,
## but the true value remains the same.
@export var DISPLAY_PERCENT_VALUE: bool = false

## An extra suffix for the value (optional).
@export var VALUE_SUFFIX: String = ""

## Reference to the slider of the element.
@export var SliderRef: HSlider
## Reference to the SpinBox or Label of the element.
@export var ValueBoxRef: Control


## Overwrite for SettingsElement.
func init_element() -> void:
	init_slider(100 if DISPLAY_PERCENT_VALUE else 1)


## Called to initialize the slider element.
func init_slider(FACTOR: float) -> void:
	# Apply the min/max/step/current value of the SliderRef
	SliderRef.set_min(MIN_VALUE * FACTOR)
	SliderRef.set_max(MAX_VALUE * FACTOR)
	SliderRef.set_step(STEP_VALUE * FACTOR)
	SliderRef.set_value(currentValue * FACTOR)
	
	# Connect the value changed signal for the SliderRef
	if not SliderRef.is_connected("value_changed", slider_value_changed):
		SliderRef.connect("value_changed", slider_value_changed.bind(FACTOR))
	
	# Check if the value box is a spin box or a label
	if ValueBoxRef is SpinBox:
		# Apply the min/max/step/current value of the spin box
		ValueBoxRef.set_min(MIN_VALUE * FACTOR)
		ValueBoxRef.set_max(MAX_VALUE * FACTOR)
		ValueBoxRef.set_step(STEP_VALUE * FACTOR)
		ValueBoxRef.set_value(currentValue * FACTOR)
		
		# Add caret blink to spin box
		ValueBoxRef.get_line_edit().set_caret_blink_enabled(true)
		
		ValueBoxRef.set_suffix(VALUE_SUFFIX)
		
		# Connect the value changed signal of the spin box
		if not ValueBoxRef.is_connected("value_changed", value_box_value_changed):
			ValueBoxRef.connect("value_changed", value_box_value_changed)
	else:
		# Set the text as the current value
		ValueBoxRef.set_text(str(currentValue) + VALUE_SUFFIX)


## Gets the valid values from the element to be used for validating data.
func get_valid_values() -> Dictionary:
	# Check if value is out of bounds
	if DEFAULT_VALUE > MAX_VALUE or DEFAULT_VALUE < MIN_VALUE:
		push_warning("Invalid default value for element '" + IDENTIFIER + "'.")
		DEFAULT_VALUE = clampf(DEFAULT_VALUE, MIN_VALUE, MAX_VALUE)
	
	return {
		"defaultValue": DEFAULT_VALUE,
		"minValue": MIN_VALUE,
		"maxValue": MAX_VALUE,
	}


## Used to update values of the section cache the element is under.
func value_changed(value: float) -> void:
	# Check if the settings menu is open
	if ParentRef.settingsCache_.size() > 0:
		ParentRef.settingsCache_[IDENTIFIER] = value
		# Check if the new value is different than the saved value
		ParentRef.settings_changed(IDENTIFIER)
		currentValue = value


func slider_value_changed(value: float, FACTOR: float) -> void:
	if ValueBoxRef is SpinBox:
		ValueBoxRef.set_value(value)
	else:
		ValueBoxRef.set_text(str(value) + VALUE_SUFFIX)
	
	value_changed(value / FACTOR)


func value_box_value_changed(value: float) -> void:
	SliderRef.set_value(value)
