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
	SettingsDataManager.connect("load_settings", load_settings)
	ParentRef.connect("setting_changed", update_element)
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
	call_deferred("display_sub_elements")


## Called when the main element's value changes do display the appropraite elements.
func update_element(elementId: String) -> void:
	if elementId == MainElementRef.IDENTIFIER:
		call_deferred("display_sub_elements")


## Called to update the visibility of sub elements based on the main elements's current value.
## This function is overwritten by the multi element wrapper.
func _display_sub_elements() -> void:
	return
