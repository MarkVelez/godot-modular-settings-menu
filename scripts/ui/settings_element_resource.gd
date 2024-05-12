extends Resource
class_name SettingsElementResource

# Used for loading saved/default value for an element
func load_element_settings(defaultValue, section: String, element: String):
	var currentValue
	
	# Check if no save file exists
	if SettingsDataManager.noSaveFile:
		# Assign default value as current value
		currentValue = defaultValue
		# Add default value of element to the settings data
		SettingsDataManager.SETTINGS_DATA[section][element] = currentValue
	else:
		# Get the current value from the settings data
		currentValue = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Return the retrieved current value
	return currentValue


# Used to initialize an option button element
func init_option_button_element(OPTION_LIST: Dictionary, optionButton: OptionButton, currentValue) -> int:
	var index: int = 0
	var selectedIndex: int
	
	# Add the options from the received option list of the element
	for option in OPTION_LIST:
		optionButton.add_item(option, index)
		# Select the option that was loaded
		if option == currentValue:
			optionButton.select(index)
			selectedIndex = index
		
		index += 1
	
	# Return the index for the selected option
	return selectedIndex


# Used to update values of the section cache the element is under (used for option button elements)
func option_selected(sectionRef: TabBar, elementRef: Node, index: int) -> void:
	# Update the settings cache with the selected option
	sectionRef.SETTINGS_SECTION_CACHE[elementRef.name] = elementRef.options.get_item_text(index)
	# Check if the selected value is different than the saved value
	sectionRef.settings_changed()
	
	# Update the element's values
	elementRef.currentValue = elementRef.options.get_item_text(index)
	elementRef.selectedIndex = index


# Used to update values of the section cache the element is under (used for slider elements)
func value_changed(sectionRef: TabBar, elementRef: Node, value: float) -> void:
	# Update the settings cache with the new slider value
	sectionRef.SETTINGS_SECTION_CACHE[elementRef.name] = value
	# Check if the new value is different than the saved value
	sectionRef.settings_changed()
