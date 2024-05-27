extends Node2D

@export var players_container: Node2D
@export var player_scene: PackedScene
@export var spawn_points: Array[Node2D]

var next_spawn_point_index = 0

func _ready():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_disconnected.connect(delete_player)
	
	for id in multiplayer.get_peers():
		add_player(id)
	add_player(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(delete_player)

func add_player(id):
	var player_instance = player_scene.instantiate()
	players_container.add_child(player_instance)
	player_instance.name = str(id)
	player_instance.position = get_spawn_point()
	
func delete_player(id):
	if not players_container.has_node(str(id)):
		return
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].position
	next_spawn_point_index = wrapi(next_spawn_point_index + 1, 0, len(spawn_points) - 1)
	return spawn_point
