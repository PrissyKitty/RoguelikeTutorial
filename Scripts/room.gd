class_name Room
extends StaticBody2D

enum Direction
{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@export var doors_always_open: bool = false # if room does not contain enemies, don't want doors to close

@onready var entrance_north: RoomEntrance = $Entrance_North
@onready var entrance_south: RoomEntrance = $Entrance_South
@onready var entrance_east: RoomEntrance = $Entrance_East
@onready var entrance_west: RoomEntrance = $Entrance_West

var enemies_in_room: int

func _ready() -> void:
	pass

func initialize(): # use for if a room needs a particular function when initialized
	pass

func set_neighbor(neighbor_direction: Direction, neighbor_room: Room):
	if neighbor_direction == Direction.NORTH:
		entrance_north.set_neighbor(neighbor_room)
	elif neighbor_direction == Direction.SOUTH:
		entrance_south.set_neighbor(neighbor_room)
	elif neighbor_direction == Direction.EAST:
		entrance_east.set_neighbor(neighbor_room)
	elif neighbor_direction == Direction.WEST:
		entrance_west.set_neighbor(neighbor_room)

func player_enter(entry_direction: Direction, player: CharacterBody2D, first_room: bool = false):
	if entry_direction == Direction.NORTH:
		player.global_position = entrance_north.player_spawn.global_position # refs player_spawn from room_entrance script
	elif entry_direction == Direction.SOUTH:
		player.global_position = entrance_south.player_spawn.global_position
	elif entry_direction == Direction.EAST:
		player.global_position = entrance_east.player_spawn.global_position
	elif entry_direction == Direction.WEST:
		player.global_position = entrance_west.player_spawn.global_position
	
	if first_room:
		player.global_position = global_position # sets player position at center of first room, which is the global_position of room
	
	GlobalSignals.OnPlayerEnterRoom.emit(self) # sends self, since requires room and is in room script
	
	if enemies_in_room > 0 and not doors_always_open: # is enemies in room and not an empty room, close doors upon entry
		close_doors()
	else:
		open_doors()

func _on_defeat_enemy(enemy):
	pass

func open_doors():
	entrance_north.open_door.call_deferred()
	entrance_south.open_door.call_deferred()
	entrance_east.open_door.call_deferred()
	entrance_west.open_door.call_deferred()

func close_doors():
	entrance_north.close_door.call_deferred()
	entrance_south.close_door.call_deferred()
	entrance_east.close_door.call_deferred()
	entrance_west.close_door.call_deferred()
