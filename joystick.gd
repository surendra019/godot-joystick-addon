@tool
extends Node2D

class_name VirtualJoystick

@export var _touch_range: int = 200 #50 for only joystick touch range
@export var _small_circle_radius: int = 20
@export var _big_circle_radius: int = 58
@export var _big_circle_color: Color = Color(0, 0, 0, .9)
@export var _small_circle_color: Color = Color(0.286, 0.286, 0.286, 0.827)
@export var _big_circle_border_color: Color = Color.WHITE
@export var _small_circle_border_color: Color = Color.WHITE
@export var _big_circle_border_width: float = 3.0
@export var _small_circle_border_width: float = 2.0


@onready var front: Control
@onready var back: Control
var center_global: Vector2



@onready var touch = $Touch
var init_pos: Vector2
var max_distance

#useful
var is_pressed: bool #when the joystick is pressed

func get_direction() -> Vector2: #returns the ouput direction of the joystick
	return center_global.direction_to(front.global_position+front.size/2)

# for handling the events
func g_in(event) -> void:
	if is_pressed:
		if event is InputEventScreenDrag:
			var g_pos = self.to_global(touch.position+event.position)
			if center_global.distance_to(g_pos+front.size/2)<=max_distance:
				front.global_position = g_pos-front.size/2
			else:
				var angle = center_global.angle_to_point(g_pos)
				
				front.global_position.x = lerp(front.global_position.x, center_global.x-front.size.x/2 + cos(angle)*max_distance, .15)
				front.global_position.y = lerp(front.global_position.y, center_global.y-front.size.y/2 + sin(angle)*max_distance, .15)

		if event is InputEventScreenTouch:
			if !event.pressed:
				var twn = get_tree().create_tween()
				twn.tween_property(front, "global_position", init_pos, .1)
				twn.play()
				is_pressed = false

func _ready() -> void:
	_add_children()
	
	if !ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse"):
		printerr("Please enable \"Emulate touch from mouse\" in the project settings")
	
	touch.gui_input.connect(g_in)
	touch.gui_input.connect(func(event):
		if event is InputEventScreenDrag:
			is_pressed = true
		if event is InputEventScreenTouch:
			is_pressed = event.pressed
		)
	_set_variables()

func _physics_process(delta) -> void:
	if Engine.is_editor_hint():
		_set_variables()
	

# initializes the variables and properties related to styles and sizes.
func _set_variables() -> void:
	back.size = Vector2(2*_big_circle_radius, 2*_big_circle_radius)
	center_global = back.global_position + back.size/2
	touch.size = Vector2(2*_touch_range,2*_touch_range)
	touch.global_position = center_global-touch.size/2
	front.size = Vector2(2*_small_circle_radius, 2*_small_circle_radius)
	
	_set_style(front, _small_circle_radius, _small_circle_color, _small_circle_border_color, _small_circle_border_width)
	_set_style(back, _big_circle_radius, _big_circle_color, _big_circle_border_color, _big_circle_border_width)
	max_distance = center_global.distance_to(center_global+back.size/2-front.size/2)
	front.position = back.size/2-front.size/2
	self.init_pos = front.global_position
	
# sets the styles.
func _set_style(panel: Panel, radius: float, color: Color, border_color: Color, border_width: float):
	var style_box = panel.get("theme_override_styles/panel")
	style_box.set("corner_radius_top_left", radius)
	style_box.set("bg_color", color)
	style_box.set("corner_radius_top_right", radius)
	style_box.set("corner_radius_bottom_left", radius)
	style_box.set("corner_radius_bottom_right", radius)
	
	style_box.set("border_width_left", border_width)
	style_box.set("border_width_right", border_width)
	style_box.set("border_width_top", border_width)
	style_box.set("border_width_bottom", border_width)
	
	style_box.set("border_color", border_color)
	


# add the necessary nodes.
func _add_children():
	var style_box = StyleBoxFlat.new()
	var big = Panel.new()
	big.set("theme_override_styles/panel", style_box)
	self.add_child(big)
	back = big
	var small =Panel.new()
	back.add_child(small)
	small.set("theme_override_styles/panel", style_box.duplicate())
	front = small
	var control =  Control.new()
	self.add_child(control)
	touch  = control
