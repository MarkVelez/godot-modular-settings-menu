extends Button

# Reference to the element's panel
@export var ElementPanel: PackedScene

# Reference to the node the settings element is under
@onready var parentRef: Node = owner
# Identifier for the element (used as the key for the section in the settings data)
@onready var identifier: StringName = name

# Reference to the element's extra panel
var elementPanelRef: Node


func _ready():
	# Connect necessary signals
	connect(&"pressed", pressed)
	create_element_panel()


func pressed() -> void:
	# Switch panels
	parentRef.settingsMenu.settingsPanel.hide()
	elementPanelRef.show()
	# Populate the settings cache of the panel
	elementPanelRef.get_settings()


# Called to create the element's extra panel
func create_element_panel() -> void:
	var elementPanels: Control = parentRef.settingsMenu.elementPanels
	# Instantiate the element panel
	elementPanelRef = ElementPanel.instantiate()
	
	# Check if the element panel exists
	if not elementPanels.find_child(elementPanelRef.name):
		# Give a reference of the element
		elementPanelRef.panelOwner = self
		elementPanelRef.hide()
		# Add the panel to the element panels list
		elementPanels.add_child(elementPanelRef)
		elementPanelRef.set_owner(parentRef.owner)
