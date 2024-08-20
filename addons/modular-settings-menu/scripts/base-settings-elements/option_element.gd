extends SettingsElement
class_name OptionElement
## A settings element specifically for elements that have option buttons.

## Default value for the element.
## Value has to exist in OPTION_LIST_ otherwise the first option will be used.
@export var DEFAULT_VALUE: String

## Element node references
@export var OptionsRef: OptionButton

## List of options related to the settings element
var OPTION_LIST_

## Index of the currently selected item
var selectedIndex: int


func _ready() -> void:
	super._ready()
	OPTION_LIST_.make_read_only()
	OptionsRef.connect("item_selected", option_selected)


func init_element() -> void:
	fill_options_button()


func get_valid_values() -> Dictionary:
	if not OPTION_LIST_.has(DEFAULT_VALUE):
		push_warning("Invalid default value for element '" + IDENTIFIER + "'.")
		if OPTION_LIST_ is Dictionary:
			DEFAULT_VALUE = OPTION_LIST_.keys()[0]
		else:
			DEFAULT_VALUE = OPTION_LIST_[0]
	
	return {
		"defaultValue": DEFAULT_VALUE,
		"validOptions": OPTION_LIST_
	}


## Used to initialize the option button element.
func fill_options_button() -> void:
	var index: int = 0
	# Get the current item count of the option button
	var itemCount: int = OptionsRef.get_item_count()
	
	# Add the options from the received option list of the element
	for option in OPTION_LIST_:
		# Check if the option button has not been initialized yet
		if itemCount == 0:
			OptionsRef.add_item(option, index)
		# Select the option that was loaded
		if option == currentValue:
			OptionsRef.select(index)
			selectedIndex = index
		
		index += 1


func option_selected(index: int) -> void:
	# Check if the settings menu is open
	if ParentRef.settingsCache_.size() > 0:
		# Update the settings cache with the selected option
		ParentRef.settingsCache_[IDENTIFIER] = OptionsRef.get_item_text(index)
		# Check if the selected value is different than the saved value
		ParentRef.settings_changed(IDENTIFIER)
	
		# Update the element's values
		currentValue = OptionsRef.get_item_text(index)
		selectedIndex = index
