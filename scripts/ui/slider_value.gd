extends HBoxContainer

@onready var slider: HSlider = $Slider
@onready var valueBox := $Value


# Called to initialize the slider/spin box of the element
func init_slider(minValue: float, maxValue: float, stepValue: float, currentValue: float) -> void:
	# Apply the min/max/step/current value of the slider
	slider.min_value = minValue
	slider.max_value = maxValue
	slider.step = stepValue
	slider.value = currentValue
	
	# Connect the value changed signal for the slider
	if !slider.is_connected("value_changed", slider_value_changed):
		slider.connect("value_changed", slider_value_changed)
	
	# Check if the value box is a spin box or a label
	if valueBox is SpinBox:
		# Apply the min/max/step/current value of the spin box
		valueBox.min_value = minValue
		valueBox.max_value = maxValue
		valueBox.step = stepValue
		valueBox.value = currentValue
		
		# Add caret blink to spin box
		valueBox.get_line_edit().caret_blink = true
		
		valueBox.suffix = owner.valueSuffix
		
		# Connect the value changed signal of the spin box
		if !valueBox.is_connected("value_changed", value_box_value_changed):
			valueBox.connect("value_changed", value_box_value_changed)
	else:
		# Set the text as the current value
		valueBox.set_text(str(currentValue) + owner.valueSuffix)


func slider_value_changed(value) -> void:
	if valueBox is SpinBox:
		valueBox.value = value
	else:
		valueBox.set_text(str(value) + owner.valueSuffix)
	
	# Pass the new value up to the element
	owner.value_changed(value)


func value_box_value_changed(value) -> void:
	slider.value = value
