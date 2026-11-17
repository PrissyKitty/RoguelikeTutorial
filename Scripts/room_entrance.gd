class_name RoomEntrance
extends Node2D

@export var direction: Room.Direction = Room.Direction.NORTH # set direction in inspector for each entrance node

@onready var barrier: StaticBody2D = $Barrier
@onready var barrier_collider: CollisionShape2D = $Barrier/CollisionShape2D

@onready var door: Node2D = $Door
@onready var door_shut: StaticBody2D = $Door/Door_Shut
@onready var door_shut_collider: CollisionShape2D = $Door/Door_Shut/CollisionShape2D

@onready var player_spawn: Node2D = $PlayerSpawn
@onready var exit_trigger: Area2D = $ExitTrigger

var neighbor: Room

func _ready() -> void:
	exit_trigger.body_entered.connect(_on_body_entered_exit_trigger) # connects body_entered signal to on exit trigger body entered
	toggle_barrier(true)

func set_neighbor(neighbor_room: Room):
	neighbor = neighbor_room
	toggle_barrier(false) # if neighboring room, no barrier, yes door

func toggle_barrier(toggle: bool):
	barrier.visible = toggle
	barrier_collider.disabled = !toggle # ! = not. will be opposite of whatever toggle is. 
	
	door.visible = !toggle # if barrier is visible, door will not be visible

func open_door(): # call_deferred in room script open_door func
	if barrier.visible: 
		return
	
	door_shut.visible = false
	door_shut_collider.disabled = true

func close_door():
	if barrier.visible: 
		return
	
	door_shut.visible = true
	door_shut_collider.disabled = false

func _on_body_entered_exit_trigger(body: Node2D) -> void:
	if body.is_in_group("Player"):
		neighbor.player_enter(_get_neighbor_entry_direction(), body) # neighbor is of class Room, has access to player_enter func, which requires direction, and player


func _get_neighbor_entry_direction() -> Room.Direction: # if exiting room from a direction, enter next room from opposite direction
	if direction == Room.Direction.NORTH:
		return Room.Direction.SOUTH
	elif direction == Room.Direction.SOUTH:
		return Room.Direction.NORTH
	elif direction == Room.Direction.EAST:
		return Room.Direction.WEST
	else:
		return Room.Direction.EAST
