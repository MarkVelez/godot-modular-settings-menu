extends Resource
class_name SettingsElementResource

# Used for loading saved/default value for an element
func load_element_settings(VALUES: Dictionary, section: StringName, element: StringName):
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
			# Add default value of element to the settings data
			SettingsDataManager.SETTINGS_DATA[section][element] = currentValue
			SettingsDataManager.invalidSaveFile = true
	
	# Add the element to the valid settings dictionary
	SettingsDataManager.VALID_SETTINGS[section].append(element)
	
	# Return the retrieved current value
	return currentValue


# Used for verifying the integrity of the save file
func verify_settings_data(VALUES: Dictionary, section: StringName, element: StringName) -> bool:
	# Check if the section exists in settings data
	if SettingsDataManager.SETTINGS_DATA.has(section):
		# Check if the element exists in the settings data
		if !SettingsDataManager.SETTINGS_DATA[section].has(element):
			print("Settings element does not exist!")
			return false
	else:
		print("Settings section does not exist!")
		return false
	
	# Get the value of the element
	var retrievedValue = SettingsDataManager.SETTINGS_DATA[section][element]
	
	# Check if the retrieved value is the correct type
	if typeof(retrievedValue) != typeof(VALUES["defaultValue"]):
		print("Invalid value type ", type_string(typeof(retrievedValue)), " for element ", element, " expected value type ", type_string(typeof(VALUES["defaultValue"])), "!")
		return false
	
	# Check if the retrieved value is a string
	if typeof(VALUES["defaultValue"]) == TYPE_STRING:
		# Check if the retrieved value is valid
		if !VALUES["validOptions"].has(retrievedValue):
			print("Invalid value ", retrievedValue, " for element ", element, " expected values ", VALUES["validOptions"], "!")
			return false
	
	# Check if the retrieved value is a number
	if typeof(VALUES["defaultValue"]) == TYPE_FLOAT || typeof(VALUES["defaultValue"]) == TYPE_INT:
		# Check if the retrieved value is valid
		if retrievedValue < VALUES["minValue"] || retrievedValue > VALUES["maxValue"]:
			# Special check if max fps is set to 0 (unlimited)
			if element == "MaxFPS" && retrievedValue == 0:
				return true
			
			print("Invalid value ", retrievedValue, " for element ", element, " expected values between ", VALUES["minValue"], " and ", VALUES["maxValue"], "!")
			return false
	
	return true


# Used to initialize an option button element
func init_option_button_element(OPTION_LIST, optionButton: OptionButton, currentValue) -> int:
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
	sectionRef.SETTINGS_SECTION_CACHE[elementRef.element] = elementRef.options.get_item_text(index)
	# Check if the selected value is different than the saved value
	sectionRef.settings_changed(elementRef.element)
	
	# Update the element's values
	elementRef.currentValue = elementRef.options.get_item_text(index)
	elementRef.selectedIndex = index


# Used to update values of the section cache the element is under (used for slider elements)
func value_changed(sectionRef: TabBar, elementRef: Node, value) -> void:
	# Update the settings cache with the new slider value
	sectionRef.SETTINGS_SECTION_CACHE[elementRef.element] = value
	# Check if the new value is different than the saved value
	sectionRef.settings_changed(elementRef.element)


func apply_in_game_setting(sectionRef: Node, elementRef: Node, value = null) -> void:
	if sectionRef.owner.isInGameMenu:
		SettingsDataManager.call_deferred("emit_signal", "apply_in_game_settings", elementRef.section, elementRef.element, value)
	else:
		SettingsDataManager.IN_GAME_SETTINGS[elementRef.element] = elementRef
