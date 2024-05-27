extends Node

@export var ip_line_edit: LineEdit
@export var status_label: Label
@export var level_container: Node
@export var level_scene: PackedScene
@export var not_connected_hbox: HBoxContainer
@export var host_hbox: HBoxContainer
@export var ui: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_host_button_pressed() -> void:
	not_connected_hbox.hide()
	host_hbox.show()
	status_label.text = "Hosting!"
	Lobby.create_game()

func _on_join_button_pressed() -> void:
	not_connected_hbox.hide()
	Lobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."

func _on_start_button_pressed() -> void:
	hide_menu.rpc()
	change_level.call_deferred(level_scene)
	
	
func change_level(scene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.queue_free()
	level_container.add_child(scene.instantiate())


func _on_connection_failed():
	not_connected_hbox.show()
	status_label.text = "Failed to connect"
	
func _on_connected_to_server():
	status_label.text = "Connected!"
	
@rpc("call_local", "authority", "reliable")
func hide_menu():
	ui.hide()
