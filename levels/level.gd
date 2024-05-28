extends Node2D

signal level_complete

@export var players_container: Node2D
@export var player_scenes: Array[PackedScene]
@export var spawn_points: Array[Node2D]
@export var key_door: KeyDoor

var next_spawn_point_index = 0
var next_character_index = 0

func _ready():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_disconnected.connect(delete_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
		
	add_player(1)
	
	key_door.all_players_finished.connect(_on_all_players_finished)

func _exit_tree():
	if multiplayer.multiplayer_peer == null:
		return
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(delete_player)

func add_player(id):
	var player_instance = get_next_character()
	player_instance.global_position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

	
func delete_player(id):
	if not players_container.has_node(str(id)):
		return
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].global_position
	next_spawn_point_index = wrapi(next_spawn_point_index + 1, 0, len(spawn_points))
	return spawn_point

func get_next_character():
	var character = player_scenes[next_character_index].instantiate()
	next_character_index = wrapi(next_character_index +1, 0, len(player_scenes))
	return character

func _on_all_players_finished():
	level_complete.emit()
	key_door.all_players_finished.disconnect(_on_all_players_finished)
