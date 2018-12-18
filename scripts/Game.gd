extends Node

#Node Dependencies
onready var PlayerCar = get_node("Hover Car");
onready var Track = get_node("Track");

#HUD Elements
onready var SpeedLabel = get_node("Hud/Speed");
onready var FallLabel = get_node("Hud/Fall Speed");
onready var TouchJoystick = get_node("Hud/Touch Joystick");
onready var LapLabel = get_node("Hud/Current Lap");
onready var TimeLabel = get_node("Hud/Time");
onready var VictoryLabel = get_node("Hud/Victory");

#Misc Vars
var startTime = OS.get_ticks_msec(); #record time when the scene is loaded
var joystickPressed = false; #bool used to record joystick presses
var raceOver = false; #bool becomes true when someone completes the track

func timeElapsed(time): #take execution time and 
	var currentTime = OS.get_ticks_msec() #record current time
	var elapsedTime = currentTime - time;
	var minutes = "00"
	var seconds = "00"
	var mSeconds = "000"
	
	if (elapsedTime >= 60000): #60000 ms = 1 minute
		minutes = (elapsedTime - (elapsedTime % 60000)) / 60000;
		elapsedTime -= minutes * 60000;
		
		if (minutes < 10): #concat a 0 to the start if below 10
			minutes = "0" + str(minutes);
			
	if (elapsedTime >= 1000): #1000 ms = 1 second
		seconds = (elapsedTime - (elapsedTime % 1000)) / 1000
		elapsedTime -= seconds * 1000;
		
		if (seconds < 10): #concat a 0 to the start if below 10
			seconds = "0" + str(seconds);
		
	mSeconds = elapsedTime; # 1 ms = 1 ms
	return (str(minutes) + ":" + str(seconds) + ":" + str(mSeconds)); #provides a formatted string with the time

func _process(delta):
	SpeedLabel.text = "Speed: " +  str(PlayerCar.current_speed); #%d is replaced by the cars speed
	FallLabel.text = "Fall Speed: " + str(PlayerCar.current_fall_speed); #display falling speed
	LapLabel.text = "Lap: " + str(PlayerCar.lapsCompleted);
	TimeLabel.text = "Time: " + timeElapsed(startTime);

func _physics_process(delta):
	if (PlayerCar.current_fall_speed == PlayerCar.max_fall_speed): #player is respawned at the start if they fall off the track
		PlayerCar.translation = Vector3(0,1,0);
		PlayerCar.rotation.y = 0; #reset rotation

func _on_Touch_Joystick__joystick_pressed():
	joystickPressed = true;

func _on_Touch_Joystick__joystick_released(): #stop both turn actions when the user releases the joystick
	Input.action_release("turn_left");
	Input.action_release("turn_right");
	joystickPressed = false;

func _on_Touch_Joystick__joystick_axis_changed(value):
	if (value.x > 0): #turn right when dragged right
		Input.action_press("turn_right");
		Input.action_release("turn_left"); #left_turn is released to prevent interference
		
	if (value.x < 0): #turn left when dragged left
		Input.action_press("turn_left");
		Input.action_release("turn_right"); #right_turn is released to prevent interference
		
	if (value.x == 0 && joystickPressed): #release both actions if the user moves circle pad into deadzone
		Input.action_release("turn_right");
		Input.action_release("turn_left");

func _on_Track_lap_completed(vehichle):
	vehichle.lapsCompleted += 1;
	
	if (vehichle.player_controlled && vehichle.lapsCompleted >= Track.Lap_Count && !raceOver): #user wins if they are the first to complete the track
		VictoryLabel.text = "VICTORY!"; #display victory message
		raceOver = true;
		
	elif (vehichle.lapsCompleted >= Track.Lap_Count && !raceOver): #user loses if a cpu beats them
		VictoryLabel.add_color_override("font_color",Color("#ff0000")); #change text color to red
		VictoryLabel.text = "GAME OVER"; #display game over message
		raceOver = true;