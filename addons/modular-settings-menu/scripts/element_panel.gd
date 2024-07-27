extends Control

signal apply_settings

# Panel node references
@onready var backButton: Button = $VBoxContainer/HBoxContainer/BackButton
@onready var applyButton: Button = $VBoxContainer/HBoxContainer/ApplyButton
@onready var discardChangesPopup: Node = $DiscardChangesPopup

# Identifier for the element panel (used as the key for the panel in the settings data)
@onready var identifier: StringName = name
# Reference to the settings menu node
@onready var settingsMenu: Node = owner

# Reference table of all elements under the section
var ELEMENT_REFERENCE_TABLE: Dictionary
# Cache of all the settings values for the section
var SETTINGS_CACHE: Dictionary
# A list of all the elements that were changed since the settings were last applied
var CHANGED_ELEMENTS: Array[String]

# Reference to the element this panel belongs to
var panelOwner: Node


func _ready():
	# Connect necessary signals
	backButton.connect(&"pressed", back_button_pressed)
	applyButton.connect(&"pressed", apply_button_pressed)
	
	# Add a reference of the panel to the reference table
	SettingsDataManager.ELEMENT_PANEL_REFERENCE_TABLE[identifier] = self
	
	# Check if a save file exists
	if SettingsDataManager.noSaveFile:
		# Add the section to the settings data dictionary
		SettingsDataManager.SETTINGS_DATA[identifier] = {}
	
	# Load the settings of the elements inside of the panel
	call_deferred(&"init_elements")


# Called to load the settings of the elements inside of the panel
func init_elements() -> void:
	for element in ELEMENT_REFERENCE_TABLE:
		ELEMENT_REFERENCE_TABLE[element].load_settings()


# Called when opening the settings menu to fill the settings cache
func get_settings() -> void:
	# Copy the settings data for the section into it's cache
	SETTINGS_CACHE = SettingsDataManager.SETTINGS_DATA[identifier].duplicate(true)
	
	# If no save file exists saves the default values retrieved from the section's elements
	if SettingsDataManager.noSaveFile or SettingsDataManager.invalidSaveFile:
		SettingsDataManager.call_deferred(&"save_data")
	
	# Clear the changed elements array
	CHANGED_ELEMENTS.clear()


# Called to check for changes between the cache and the settings data
func settings_changed(element: StringName) -> void:
	# Check if there are differences between the cache and the settings data
	if SETTINGS_CACHE[element] == SettingsDataManager.SETTINGS_DATA[identifier][element]:
		# Check if the element is on the changed elements list
		if CHANGED_ELEMENTS.has(element):
			# Remove the element from the list
			CHANGED_ELEMENTS.erase(element)
			# Decrease the changed elements count
			SettingsDataManager.changedElementsCount -= 1
			
		# Check if there are any other changed elements
		if SettingsDataManager.changedElementsCount == 0:
			# Disabled the apply button
			applyButton.set_disabled(true)
	else:
		applyButton.set_disabled(false)
		# Check if the element is not the changed elements list
		if not CHANGED_ELEMENTS.has(element):
			# Add the element to the list
			CHANGED_ELEMENTS.append(element)
			# Increase the changed elements count
			SettingsDataManager.changedElementsCount += 1


func discard_changes() -> void:
	# Check if any of the sections elements have been changed
	if CHANGED_ELEMENTS.size() > 0:
		# Load the saved settings for each element in the section
		for element in CHANGED_ELEMENTS:
			ELEMENT_REFERENCE_TABLE[element].load_settings()
		
		# Clear the changed elements array
		CHANGED_ELEMENTS.clear()


func back_button_pressed():
	# Check if there have been any changes made
	if applyButton.is_disabled():
		# Clear the cache and return normally
		SETTINGS_CACHE.clear()
		hide()
		owner.settingsPanel.show()
	else:
		# Display the discard changes popup
		discardChangesPopup.show()


func apply_button_pressed():
	# Check if any of the sections elements have been changed
	if CHANGED_ELEMENTS.size() > 0:
		# Copy the section cache into the settings data dictionary
		SettingsDataManager.SETTINGS_DATA[identifier] = SETTINGS_CACHE.duplicate(true)
		
		# Apply the settings for the changed elements
		for element in CHANGED_ELEMENTS:
			ELEMENT_REFERENCE_TABLE[element].apply_settings()
		
		# Clear the changed elements array
		CHANGED_ELEMENTS.clear()
	
	# Save the updated settings data
	SettingsDataManager.call_deferred(&"save_data")
	
	applyButton.set_disabled(true)
