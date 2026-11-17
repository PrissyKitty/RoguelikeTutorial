class_name RoomGeneration
extends Node

@export var map_size: int = 7 # width and height of room grid
@export var rooms_to_generate: int = 12 # max amount of rooms that can be generated in map_size grid
var room_count: int = 0 # keeps track of how many rooms have been generated
var map: Array[bool] # determines true, or false if a room exists, or not
var rooms: Array[Room] # keeps track of rooms
var room_pos_offset: float = 160 # amount of pixels rooms are generated from each other

var first_room_x: int = 3 # starting room centered on 0-7 grid
var first_room_y: int = 3
var first_room: Room # references Room class from room.gd to keep track of first room

var room_scene: PackedScene = preload("res://Scenes/Rooms/room_template.tscn")

@export var player: CharacterBody2D

func _ready() -> void:
	_generate()
	
	# room layout preview
	#for x in range(map_size):
		#var line: String
		#for y in range(map_size):
			#line += "# " if _get_map(x, y) else "0 "
		#print(line)

func _generate():
	room_count = 0
	map.resize(map_size * map_size) # defines size of map array
	
	_check_room(first_room_x, first_room_y, Vector2.ZERO, true)
	_instatiate_rooms()

func _check_room(x: int, y: int, desired_direction: Vector2, is_first_room: bool = false): # recurrsive func, calls itself repeatedly to fill room layout
	if room_count >= rooms_to_generate: # prevents more rooms from being generated once limit is reached
		return
	
	if x < 0 or x > map_size - 1 or y < 0 or y > map_size - 1: # confines rooms to map bounds. Between 0 and map_size. First room is at 3
		return
	
	if _get_map(x, y) == true: # if a room already exists in grid space, skip grid space
		return
	
	room_count += 1
	_set_map(x, y, true) # sets an array value in map array
	
	var go_north: bool = randf() > (0.2 if desired_direction == Vector2.UP else 0.8) # randf random number between 0-1. if greater than 0.2, 80% north room, else 20% north room. Adds randomization so map isn't equal in all directions
	var go_south: bool = randf() > (0.2 if desired_direction == Vector2.DOWN else 0.8)
	var go_east: bool = randf() > (0.2 if desired_direction == Vector2.RIGHT else 0.8)
	var go_west: bool = randf() > (0.2 if desired_direction == Vector2.LEFT else 0.8)
	
	if go_north or is_first_room: 
		_check_room(x, y - 1, Vector2.UP if is_first_room else desired_direction) # always go north first room, else chance of go north
	if go_south or is_first_room: 
		_check_room(x, y + 1, Vector2.DOWN if is_first_room else desired_direction)
	if go_east or is_first_room: 
		_check_room(x + 1, y, Vector2.RIGHT if is_first_room else desired_direction)
	if go_west or is_first_room: 
		_check_room(x - 1, y, Vector2.LEFT if is_first_room else desired_direction)

func _instatiate_rooms():
	for x in range(map_size):
		for y in range(map_size):
			if _get_map(x, y) == false: # only continue if no room at grid space
				continue
			
			var room: Room = room_scene.instantiate() # instantiates the preloaded room scene
			var is_first_room: bool = first_room_x == x and first_room_y == y # if conditions true, then this is first room
			
			get_tree().root.add_child.call_deferred(room) # gets the root node of the room scene. call deferred runs line after scene tree has been loaded
			rooms.append(room) # adds room to the rooms array
			
			room.global_position = Vector2(x, y) * room_pos_offset # sets new room pos to be the correct distance to tile rooms
			
			if is_first_room:
				first_room = room # instantiates the first room
			
			room.initialize() # calls initialize func from room script
	
	for room in rooms:
		var map_pos: Vector2 = _get_map_index(room)
		var x = map_pos.x
		var y = map_pos.y
		
		if y > 0 and _get_map(x, y - 1): # since map_size is 7, range is 0-6, so checking between 0 and map_size - 1
			room.set_neighbor.call_deferred(Room.Direction.NORTH, get_room_from_map(x, y - 1)) # room script has to load onready vars first, so call_deferred
		if y < map_size - 1 and _get_map(x, y + 1):
			room.set_neighbor.call_deferred(Room.Direction.SOUTH, get_room_from_map(x, y + 1))
		if x < map_size + 1 and _get_map(x + 1, y):
			room.set_neighbor.call_deferred(Room.Direction.EAST, get_room_from_map(x + 1, y))
		if x > 0 and _get_map(x - 1, y):
			room.set_neighbor.call_deferred(Room.Direction.WEST, get_room_from_map(x - 1, y))
	
	first_room.player_enter.call_deferred(Room.Direction.NORTH, player, true) # call deferred so room has time to instantiate


func get_room_from_map(x: int, y: int) -> Room:
	for room in rooms: # loops through every room
		var pos = _get_map_index(room) # gets room Vector2i value
		
		if pos.x != x or pos.y != y: # if position doesn't = current room, continue
			continue
		
		return room
	
	return null # ends for loop to prevent error

func _get_map_index(room: Room) -> Vector2i: # gets x, y value for room as integer, needs to be int not float to avoid errors
	return Vector2i(room.global_position / room_pos_offset) # takes global pos and divides by offset to give a simple room index number

func _get_map(x: int, y: int) -> bool:
	return map[x + y * map_size] # arrays only have 1 dimension. This turns it into a 2D array for map grid

func _set_map(x: int, y:int, value: bool): # sets a value in the map array
	map[x + y * map_size] = value
