extends Node
class_name HealthComponent

signal onHealthChange(changeAmount: int, newHealth: int)
signal onDeath()

@export_category("Health")
@export var maxHealth := 10
var health : int = maxHealth

func changeHealth(amount : int) -> void:
	health += amount
	onHealthChange.emit(amount)
	if (health <= 0):
		onDeath.emit()

func setHealth(newValue : int, emitOnHealthChange : bool) -> void:
	var changeAmount = newValue - health
	health = newValue
	if (emitOnHealthChange):
		onHealthChange.emit(changeAmount, newValue)
	
	if (health <= 0):
		onDeath.emit()
