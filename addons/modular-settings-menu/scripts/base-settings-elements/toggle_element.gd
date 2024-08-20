extends SettingsElement
class_name ToggleElement
## A settings element specifically for elements that have a toggle button.

## Default value for the element
@export var DEFAULT_VALUE: bool = false

## Reference to the toggle button of the element.
@export var ToggleRef: Button


func _ready() -> void:
	super._ready()
	ToggleRef.connect("toggled", toggled)


## Overwrite for SettingsElement.
func init_element() -> void:
	ToggleRef.set_pressed(currentValue)


## Gets the valid values from the element to be used for validating data.
func get_valid_values() -> Dictionary:
	return {
		"defaultValue": DEFAULT_VALUE,
		"validOptions": [true, false]
	}


## Used to update values of the section cache the element is under.
func toggled(state: bool) -> void:
	# Check if the settings menu is open
	if ParentRef.settingsCache_.size() > 0:
		# Update the settings cache with the new toggle state
		ParentRef.settingsCache_[IDENTIFIER] = state
		# Check if the new state is different than the saved state
		ParentRef.settings_changed(IDENTIFIER)
		currentValue = state
