extends CharacterBody2D

@export var move_speed: float = 50

@export var shoot_rate: float = 0.4
var last_shoot_time: float

var projectile_scene: PackedScene = preload("res://Scenes/Projectiles/projectile.tscn")

@onready var sprite: Sprite2D = $Sprite
@onready var weapon_origin: Node2D = $Weapon
@onready var muzzle: Node2D = $Weapon/Muzzle

func _physics_process(_delta: float) -> void:
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_input * move_speed
	move_and_slide()

func _process(_delta: float) -> void: # not dependent on physics system
	var mouse_pos: Vector2 = get_global_mouse_position()
	var mouse_dir: Vector2 = (mouse_pos - global_position).normalized() # difference between mouse and player position. Normalized makes vector length always equal 1
	weapon_origin.rotation_degrees = rad_to_deg(mouse_dir.angle()) + 90 # converts Vector2 to angle, since rotation requires angle, then converts from rad to deg. + 90 to correct offset
	
	sprite.flip_h = mouse_dir.x < 0 # flip_h is bool. if mouse_dir is negative, set to true
	
	if Input.is_action_pressed("attack"):
		if Time.get_unix_time_from_system() - last_shoot_time > shoot_rate: # only shoots if enough time has elapsed
			_shoot()

func _shoot():
	last_shoot_time = Time.get_unix_time_from_system()
	
	var proj = projectile_scene.instantiate() # instantiates projectile scene
	get_tree().root.add_child(proj) # adds projectile to scene
	proj.global_position = muzzle.global_position # sets projectile pos to = muzzle pos
	proj.rotation = weapon_origin.rotation # sets projectile rotation to = weapon origin
	proj.owner_character = self # sets player as owner character. owner character set in projectile script

func take_damage(amount: int):
	pass
