extends Control

func _ready():
	resize()
	get_tree().get_root().size_changed.connect(resize)
	
func resize():
	size = get_tree().get_root().size
