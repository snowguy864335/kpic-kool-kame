extends Control
class_name SpellHud

@export var cooldown_done_color : Color
@export var cooling_down_color : Color

var timer : Timer
var charges_left : int
var use_charges : bool

@onready var progress_bar = $ProgressBar
@onready var charges_label = $Charges

func track_cooldown(spell_timer : Timer):
	timer = spell_timer


func set_charges(charges : int):
	use_charges = true
	charges_left = charges
	

func _process(_delta: float) -> void:
	if use_charges:
		charges_label.visible = true
		charges_label.text = str(charges_left) + " charges left"
	
	progress_bar.value = timer.time_left / timer.wait_time * 100.
	var box : StyleBoxFlat = progress_bar.get_theme_stylebox("background")
	if timer.time_left == 0:
		box.bg_color = cooldown_done_color
	else:
		box.bg_color = cooling_down_color
