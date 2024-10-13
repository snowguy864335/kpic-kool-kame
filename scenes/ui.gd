extends Control

@onready var debug_box = %Debug

func set_property(name : String, value : String):
	var label := debug_box.find_child(name) as RichTextLabel
	label.text = name + ": " + value

func hide_debug():
	$ColorRect.hide()

func show_debug():
	$ColorRect.show()
	
func is_debug_visible() -> bool:
	return $ColorRect.visible
