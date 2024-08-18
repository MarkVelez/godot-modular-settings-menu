extends Button
class_name ButtonElement

## Reference to the element's panel scene.
@export var ElementPanelScene: PackedScene

## Reference to the node the settings element is under.
@onready var ParentRef: Node = owner

## Reference to the element's panel.
var ElementPanelRef: Node


func _ready():
	# Connect necessary signals
	connect("pressed", pressed)
	create_element_panel()


func pressed() -> void:
	# Switch panels
	ParentRef.SettingsMenuRef.SettingsPanelRef.hide()
	ElementPanelRef.show()
	# Populate the settings cache of the panel
	ElementPanelRef.get_settings()


## Called to create the element's panel.
func create_element_panel() -> void:
	var ElementPanelsRef: Control = ParentRef.SettingsMenuRef.ElementPanelsRef
	ElementPanelRef = ElementPanelScene.instantiate()
	
	# Check if the element panel exists
	if not ElementPanelsRef.find_child(ElementPanelRef.name):
		# Give a reference of the element
		ElementPanelRef.PanelOwnerRef = self
		ElementPanelRef.hide()
		# Add the panel to the element panels list
		ElementPanelsRef.add_child(ElementPanelRef)
		ElementPanelRef.set_owner(ParentRef.SettingsMenuRef)
