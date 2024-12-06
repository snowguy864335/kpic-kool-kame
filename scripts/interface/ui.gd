extends Control

@onready var debug_box = %Debug

func set_property(property_name : String, value : String):
	var label := debug_box.find_child(property_name) as RichTextLabel
	label.text = property_name + ": " + value

func hide_debug():
	$ColorRect.hide()

func show_debug():
	$ColorRect.show()
	
func is_debug_visible() -> bool:
	return $ColorRect.visible
