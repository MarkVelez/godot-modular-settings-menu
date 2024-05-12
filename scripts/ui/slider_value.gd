extends HBoxContainer

@onready var slider: HSlider = $Slider
@onready var valueBox: SpinBox = $Value


# Called to initialize the slider/spin box of the element
func init_slider() -> void:
	# Apply the min/max/step/current value of the slider
	slider.min_value = owner.minValue * 100
	slider.max_value = owner.maxValue * 100
	slider.step = owner.stepValue * 100
	slider.value = owner.currentValue * 100
	
	# Apply the min/max/step/current value of the spin box
	valueBox.min_value = owner.minValue * 100
	valueBox.max_value = owner.maxValue * 100
	valueBox.step = owner.stepValue * 100
	valueBox.value = owner.currentValue * 100
	
	# Connect the value changed signals of the two nodes
	slider.connect("value_changed", slider_value_changed)
	valueBox.connect("value_changed", value_changed)


func slider_value_changed(value: float) -> void:
	valueBox.value = value


func value_changed(value: float) -> void:
	slider.value = value
	# Pass the new value up to the element (divided by hundred because the assigned values are percentage)
	owner.currentValue = value / 100
	owner.value_changed()
