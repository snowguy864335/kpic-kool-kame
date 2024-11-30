extends Node
class_name HealthComponent

signal onHealthChange(changeAmount: int, newHealth: int)
signal onDeath()

@export_category("Health")
@export var maxHealth := 10
@onready var health : int = maxHealth

@rpc("any_peer", "call_local")
func changeHealth(amount : int) -> void:
	health += amount
	onHealthChange.emit(amount)
	if (health <= 0):
		onDeath.emit()
		get_parent().queue_free()
	

@rpc("any_peer", "call_local")
func setHealth(newValue : int, emitOnHealthChange : bool) -> void:
	var changeAmount = newValue - health
	health = newValue
	if (emitOnHealthChange):
		onHealthChange.emit(changeAmount, newValue)
	
	if (health <= 0):
		onDeath.emit()
