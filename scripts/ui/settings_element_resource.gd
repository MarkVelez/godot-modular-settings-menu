extends Resource
class_name SettingsElementResource


# Used to initialize a settings element
func init_element(elementType: StringName, sectionRef: Node, elementRef: Node) -> void:
	# Connect type specific signals
	match elementType:
		&"option":
			elementRef.optionsRef.connect("item_selected", Callable(elementRef, &"option_selected"))
		&"toggle":
			elementRef.toggleRef.connect("toggled", Callable(elementRef, &"toggled"))
		&"button":
			elementRef.connect("pressed", Callable(elementRef, &"pressed"))
	
	SettingsDataManager.connect("load_settings", Callable(elementRef, &"load_settings"))
	
	# Check if the element is a sub element
	if not elementRef.isSubElement:
		sectionRef.connect("apply_settings", Callable(elementRef, &"apply_settings"))
	
		# Add an entry of the settings element to the section's reference table
		sectionRef.ELEMENT_REFERENCE_TABLE[elementRef.element] = elementRef


# Used to initialize sub elements
func init_sub_elements(SUB_ELEMENTS: Array[Node], sectionRef) -> void:
	# Itterate through the sub elements
	for subElementRef in SUB_ELEMENTS:
		# Give section information to sub element
		subElementRef.sectionRef = sectionRef
		subElementRef.section = sectionRef.section
		sectionRef.ELEMENT_REFERENCE_TABLE[subElementRef.element] = subElementRef


# Used for loading saved/default value for an element
func load_element_settings(VALUES: Dictionary, sectionRef: Node, elementRef: Node):
	var section: StringName = sectionRef.section
	var element: StringName = elementRef.element
	var isInGameSetting: bool = elementRef.isInGameSetting
	var isSubElement: bool = elementRef.isSubElement
	var currentValue
	
	# Check if no save file exists
	if SettingsDataManager.noSaveFile:
		# Assign default value as current value
		currentValue = VALUES["defaultValue"]
		# Add default value of element to the settings data
		SettingsDataManager.SETTINGS_DATA[section][element] = currentValue
	else:
		# Verify the existance and validity of the element in the settings data
		if verify_settings_data(VALUES, section, element):
			# Get the current value from the settings data
			currentValue = SettingsDataManager.SETTINGS_DATA[section][element]
		else:
			# Assign default value as current value
			currentValue = VALUES["defaultValue"]
			# Add default value of the element to the settings data
			SettingsDataManager.SETTINGS_DATA[section][element] = currentValue
			SettingsDataManager.invalidSaveFile = true
	
	# Check if the current element is in an in game menu or if it is a sub element
	if sectionRef.settingsMenu.isInGameMenu == isInGameSetting or not isSubElement:
		# Apply the loaded values to the game
		elementRef.call_deferred("apply_settings")
	
	# Return the retrieved current value
	return currentValue


# Checks if the loaded values are valid for the element and fixes them if they are not
func verify_settings_data(VALUES: Dictionary, section: StringName, element: StringName) -> bool:
	# Check if the section exists in settings data
	if SettingsDataManager.SETTINGS_DATA.has(section):
		# Check if the element exists in the settings data
		if not SettingsDataManager.SETTINGS_DATA[section].has(element):
			push_warning("Settings element does not exist: ", element)
			return false
	else:
		push_warning("Settings section does not exist: ", section)
		return false
	
	# Get the value of the element
	var retrievedValue = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the retrieved value is the correct type
	if typeof(retrievedValue) != typeof(VALUES["defaultValue"]):
		push_warning("Invalid value type ", type_string(typeof(retrievedValue)), " for element ", element, " expected value type ", type_string(typeof(VALUES["defaultValue"])))
		return false
	
	# Check if the retrieved value is a string
	if typeof(VALUES["defaultValue"]) == TYPE_STRING or typeof(VALUES["defaultValue"]) == TYPE_BOOL:
		# Check if the retrieved value is valid
		if not VALUES["validOptions"].has(retrievedValue):
			push_warning("Invalid value ", retrievedValue, " for element ", element, " expected values ", VALUES["validOptions"])
			return false
	
	# Check if the retrieved value is a number
	if typeof(VALUES["defaultValue"]) == TYPE_FLOAT or typeof(VALUES["defaultValue"]) == TYPE_INT:
		# Check if the retrieved value is valid
		if retrievedValue < VALUES["minValue"] or retrievedValue > VALUES["maxValue"]:
			# Special check if max fps is set to 0 (unlimited)
			if element == "MaxFPS" and retrievedValue == 0:
				return true
			
			push_warning("Invalid value ", retrievedValue, " for element ", element, " expected values between ", VALUES["minValue"], " and ", VALUES["maxValue"])
			return false
	
	return true


# Used to initialize an option button element
func init_option_button_element(OPTION_LIST, optionButtonRef: OptionButton, currentValue, elementRef: Node) -> void:
	var index: int = 0
	# Get the current item count of the option button
	var itemCount: int = optionButtonRef.get_item_count()
	
	# Add the options from the received option list of the element
	for option in OPTION_LIST:
		# Check if the option button has not been initialized yet
		if itemCount == 0:
			optionButtonRef.add_item(option, index)
		# Select the option that was loaded
		if option == currentValue:
			optionButtonRef.select(index)
			elementRef.selectedIndex = index
		
		index += 1


# Used to update values of the section cache the element is under (used for option button elements)
func option_selected(sectionRef: TabBar, elementRef: Node, index: int) -> void:
	# Check if the settings menu is open
	if sectionRef.SETTINGS_SECTION_CACHE.size() > 0:
		# Update the settings cache with the selected option
		sectionRef.SETTINGS_SECTION_CACHE[elementRef.element] = elementRef.optionsRef.get_item_text(index)
		# Check if the selected value is different than the saved value
		sectionRef.settings_changed(elementRef.element)
	
		# Update the element's values
		elementRef.currentValue = elementRef.optionsRef.get_item_text(index)
		elementRef.selectedIndex = index


# Used to update values of the section cache the element is under (used for slider elements)
func value_changed(sectionRef: TabBar, elementRef: Node, value) -> void:
	# Check if the settings menu is open
	if sectionRef.SETTINGS_SECTION_CACHE.size() > 0:
		# Update the settings cache with the new slider value
		sectionRef.SETTINGS_SECTION_CACHE[elementRef.element] = value
		# Check if the new value is different than the saved value
		sectionRef.settings_changed(elementRef.element)


# Used to update values of the section cache the element is under (used for toggle elements)
func toggled(sectionRef: TabBar, elementRef: Node, state: bool) -> void:
	# Check if the settings menu is open
	if sectionRef.SETTINGS_SECTION_CACHE.size() > 0:
		# Update the settings cache with the new toggle state
		sectionRef.SETTINGS_SECTION_CACHE[elementRef.element] = state
		# Check if the new state is different than the saved state
		sectionRef.settings_changed(elementRef.element)
		
		# Update the element's values
		elementRef.currentValue = state


func apply_in_game_setting(sectionRef: Node, elementRef: Node, value = null) -> bool:
	var section: StringName = sectionRef.section
	var element: StringName = elementRef.element
	
	if sectionRef.settingsMenu.isInGameMenu:
		SettingsDataManager.call_deferred("emit_signal", "apply_in_game_settings", section, element, value)
		return true
	
	return false
