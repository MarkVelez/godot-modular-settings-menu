extends Control
class_name MultiElement
## A wrapper node for multi elements.

@export var MainElementRef: SettingsElement
@export var SUB_ELEMENTS_: Array[SettingsElement]

var ParentRef: SettingsSection

var currentValue :
	get:
		return MainElementRef.currentValue


func _enter_tree() -> void:
	ParentRef = owner
	ParentRef.connect("setting_changed", update_element)
	ParentRef.connect("apply_button_pressed", apply_settings)
	ParentRef.SettingsMenuRef.connect("changes_discarded", load_settings)
	SettingsDataManager.connect("settings_retrieved", load_settings)
	init_main_element()
	init_sub_elements()


func init_main_element() -> void:
	var elementId: String = MainElementRef.IDENTIFIER
	MainElementRef.IS_MULTI_ELEMENT = true
	MainElementRef.ParentRef = ParentRef
	ParentRef.ELEMENT_REFERENCE_TABLE_[elementId] = MainElementRef


## Used to initialize sub elements of the multi element.
func init_sub_elements() -> void:
	for ElementRef in SUB_ELEMENTS_:
		ElementRef.IS_MULTI_ELEMENT = true
		ElementRef.IS_SUB_ELEMENT = true
		ElementRef.ParentRef = ParentRef
		ParentRef.ELEMENT_REFERENCE_TABLE_[ElementRef.IDENTIFIER] = ElementRef


## Called when settings are loaded to display the appropriate elements.
func load_settings() -> void:
	call_deferred("_display_sub_elements")


## Called when the main element's value changes do display the appropriate elements.
func update_element(elementId: String) -> void:
	if elementId == MainElementRef.IDENTIFIER:
		call_deferred("_display_sub_elements")


## Called to update the visibility of sub elements based on the main elements's current value.
## This function is overwritten by the multi element wrapper.
func _display_sub_elements() -> void:
	return


## Called when the apply button is pressed.
func apply_settings() -> void:
	if ParentRef.changedElements_.has(MainElementRef.IDENTIFIER):
		for SubElementRef in SUB_ELEMENTS_:
			if (
				not SubElementRef.is_visible_in_tree()
				or ParentRef.changedElements_.has(SubElementRef.IDENTIFIER)
			):
				continue
			SubElementRef._apply_settings()
