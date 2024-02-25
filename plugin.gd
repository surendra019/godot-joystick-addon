@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Joystick", "Node2D", preload("res://addons/Joystick/joystick.gd"), preload("res://icon.png"))
	pass


func _exit_tree():
	remove_custom_type("Joystick")
	pass
