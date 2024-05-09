extends Resource
class_name SettingsElementResource


func load_element_settings(defaultValue, section: String, element: String):
	var currentValue
	
	if SettingsDataManager.noSaveFile:
		currentValue = defaultValue
		SettingsDataManager.SETTINGS_DATA[section][element] = currentValue
	else:
		currentValue = SettingsDataManager.SETTINGS_DATA[section][element]
	
	return currentValue


func init_option_button_element(OPTION_LIST: Dictionary, optionButton: OptionButton, currentValue) -> int:
	var index: int = 0
	var selectedIndex: int
	
	for option in OPTION_LIST:
		optionButton.add_item(option, index)
		if option == currentValue:
			optionButton.select(index)
			selectedIndex = index
		
		index += 1
	
	return selectedIndex


func option_selected(SECTION_CACHE: Dictionary, sectionRef: Node, elementRef: Node, index: int) -> void:
	SECTION_CACHE[elementRef.name] = elementRef.options.get_item_text(index)
	sectionRef.settings_changed()
	elementRef.selectedIndex = index