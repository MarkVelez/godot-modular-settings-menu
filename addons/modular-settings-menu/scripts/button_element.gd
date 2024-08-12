extends Button

# Reference to the element's panel
@export var ElementPanelScene: PackedScene

# Reference to the node the settings element is under
@onready var ParentRef: Node = owner

# Reference to the element's extra panel
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


# Called to create the element's extra panel
func create_element_panel() -> void:
	var elementPanelsRef: Control = ParentRef.SettingsMenuRef.ElementPanelsRef
	# Instantiate the element panel
	ElementPanelRef = ElementPanelScene.instantiate()
	
	# Check if the element panel exists
	if not elementPanelsRef.find_child(ElementPanelRef.name):
		# Give a reference of the element
		ElementPanelRef.panelOwner = self
		ElementPanelRef.hide()
		# Add the panel to the element panels list
		elementPanelsRef.add_child(ElementPanelRef)
		ElementPanelRef.set_owner(ParentRef.SettingsMenuRef)
