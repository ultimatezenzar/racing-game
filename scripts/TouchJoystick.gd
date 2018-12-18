extends Node2D

export var dead_zone = 5; #joystick deadzone radius
export var circle_pad_radius = 25; #radius of the circle pad
export var outer_ring_radius = 70; #radius of the outer ring of the joystick

onready var CirclePadHitbox = get_node("Circle Pad/Circle Pad Hitbox"); #retrieve useful nodes
onready var CirclePad = get_node("Circle Pad");

onready var OuterRingHitbox = get_node("Outer Ring/Outer Ring Hitbox");
onready var OuterRing = get_node("Outer Ring");

var lastScreenTouch = Vector2(); #previous screentouch location
var lastTouchIndex = null; #records which touch index should be tracked

signal _joystick_pressed; #called when the user pressed the joystick
signal _joystick_released; #called when the user released the joystick
signal _joystick_axis_changed(value); #called when the axis is changed by user input

func _draw():
	draw_circle(Vector2(0,0), outer_ring_radius, Color(0,0,0)); #black circle shows outer ring
	draw_circle(Vector2(0,0), dead_zone, Color(255, 0, 0)); #draw a red circle to show deadzone

func _ready():
	CirclePadHitbox.shape.radius = circle_pad_radius; #set the user defined radii
	OuterRingHitbox.shape.radius = outer_ring_radius;

func getStickPosition(): #returns vector scaled to return a vector between (-1, -1) and (1, 1)
	if (abs(CirclePad.position.length()) > dead_zone):
		return CirclePad.position / outer_ring_radius;
	else:
		return Vector2(0,0); #return 0,0 if circle pad is inside the deadzone

func _physics_process(delta):
	CirclePad.move_and_collide(lastScreenTouch - CirclePad.position); #move and collide to is an offset so current location must be subtracted first

func _unhandled_input(event): #tracks screentouch events
	if (event.is_class("InputEventScreenDrag")): #if the last touch was outside the joystick range it will be ignored
		if (lastTouchIndex == event.index):
			var temp = to_local(event.position); #store and convert touch loaction into a local point
			if (abs(temp.length()) > outer_ring_radius): #if the length exceeds the allowed range
				lastScreenTouch = temp.normalized() * outer_ring_radius; #normalize the vector to keep its direction but reduce the length to the maximum radius
				get_tree().set_input_as_handled(); #stops the input from being sent to other nodes
				self.emit_signal("_joystick_axis_changed", getStickPosition()); #emit a signal when moved
			else:
				lastScreenTouch = temp; #the circlepad will simply move to the vector if it's in bounds
				get_tree().set_input_as_handled(); #stops the input from being sent to other nodes
				self.emit_signal("_joystick_axis_changed", getStickPosition()); #emit a signal when moved

	elif (event.is_class("InputEventScreenTouch")):
		if (event.index == lastTouchIndex && !event.pressed): #if the tracked index is being released
			lastScreenTouch = Vector2(0,0); #reset touch position to the center when released
			lastTouchIndex = null; #reset touch index when released
			self.emit_signal("_joystick_released"); #emit a signal when released

func _on_Outer_Ring_input_event(viewport, event, shape_idx): #called when an input event happens inside outer ring
	if (event.is_class("InputEventScreenTouch")): #blocks undesired input
		if (event.pressed): #if the screen is being pressed
			lastScreenTouch = to_local(event.position); #log the previous screen touch relative to the joystick
			lastTouchIndex = event.index; #record the touch index so it can tracked outside of outer ring
			get_tree().set_input_as_handled(); #stops the input from being sent to other nodes
			self.emit_signal("_joystick_pressed"); #emit a signal when pressed