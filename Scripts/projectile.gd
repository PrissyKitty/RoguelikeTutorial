extends Area2D

@export var base_speed: float = 100

var owner_character: CharacterBody2D

func _process(delta: float) -> void:
	translate(-transform.y * base_speed * delta) # moves projectile in the upwards direction. delta is per second, instead of per frame for consistency
	

func _on_body_entered(body: Node2D) -> void:
	if body == owner_character: # ignores owner character
		return
	
	if body.has_method("take_damage"): 
		body.take_damage(1)
	
	queue_free() # deletes projectile after dealing damage, or entering a body

func _on_timer_timeout() -> void:
	queue_free() # deletes projectile after timer ends
