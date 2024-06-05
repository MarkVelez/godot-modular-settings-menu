extends HBoxContainer

# Slider nodes
@onready var sliderRef: HSlider = $Slider
@onready var valueBoxRef := $Value


# Called to initialize the sliderRef/spin box of the element
func init_slider(minValue: float, maxValue: float, stepValue: float, currentValue: float) -> void:
	# Apply the min/max/step/current value of the sliderRef
	sliderRef.set_min(minValue)
	sliderRef.set_max(maxValue)
	sliderRef.set_step(stepValue)
	sliderRef.set_value(currentValue)
	
	# Connect the value changed signal for the sliderRef
	if not sliderRef.is_connected("value_changed", slider_value_changed):
		sliderRef.connect("value_changed", slider_value_changed)
	
	# Check if the value box is a spin box or a label
	if valueBoxRef is SpinBox:
		# Apply the min/max/step/current value of the spin box
		valueBoxRef.set_min(minValue)
		valueBoxRef.set_max(maxValue)
		valueBoxRef.set_step(stepValue)
		valueBoxRef.set_value(currentValue)
		
		# Add caret blink to spin box
		valueBoxRef.get_line_edit().set_caret_blink_enabled(true)
		
		valueBoxRef.set_suffix(owner.valueSuffix)
		
		# Connect the value changed signal of the spin box
		if not valueBoxRef.is_connected("value_changed", value_box_value_changed):
			valueBoxRef.connect("value_changed", value_box_value_changed)
	else:
		# Set the text as the current value
		valueBoxRef.set_text(str(currentValue) + owner.valueSuffix)


func slider_value_changed(value) -> void:
	if valueBoxRef is SpinBox:
		valueBoxRef.set_value(value)
	else:
		valueBoxRef.set_text(str(value) + owner.valueSuffix)
	
	# Pass the new value up to the element
	owner.value_changed(value)


func value_box_value_changed(value) -> void:
	sliderRef.set_value(value)
