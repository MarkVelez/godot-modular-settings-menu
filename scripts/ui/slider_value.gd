extends Node

@onready var slider: HSlider = $Slider
@onready var valueBox: SpinBox = $Value


func init_slider() -> void:
	slider.min_value = owner.minValue * 100
	slider.max_value = owner.maxValue * 100
	slider.step = owner.stepValue * 100
	slider.value = owner.currentValue * 100
	
	valueBox.min_value = owner.minValue * 100
	valueBox.max_value = owner.maxValue * 100
	valueBox.step = owner.stepValue * 100
	valueBox.value = owner.currentValue * 100
	
	slider.connect("value_changed", slider_value_changed)
	valueBox.connect("value_changed", value_changed)


func slider_value_changed(value: float) -> void:
	valueBox.value = value


func value_changed(value: float) -> void:
	slider.value = value
	owner.currentValue = value / 100
	owner.value_changed()
