@tool
extends EditorPlugin

# adds teh custom node.
func _enter_tree():
	add_custom_type("VirtualJoystick", "Node2D", preload("res://addons/Virtual Joystick/joystick.gd"), preload("res://addons/Virtual Joystick/icon.png"))

# removes the custom node.
func _exit_tree():
	remove_custom_type("VirtualJoystick")
