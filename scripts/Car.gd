extends KinematicBody

export var max_speed = 200; #vehichle top speed
export var reverse_speed = -10; #speed while moving backwards
export var player_controlled = false; #determine whether or not the vehichle will be player controlled
export var turn_rate = .02; #turning rate of the vehichle (measured in radians)
export var max_hover_distance = 1; #max distance from ground to not be considered falling
export var max_fall_speed = 50; #maximum fall speed

var lapAuthorizationScore = 0; #scoring system used to determine if a lap has been completed 
var lapsCompleted = 0; #number of laps completed 
var previousZone = 0; #previous lap zone vehichle was in refrain from sending these over a network to prevent cheating

var velocity = Vector3(); #speed and direction the vehichle will move towards
var current_speed = 1; #vehichle current speed
var current_fall_speed = 0; #vehichles descending speed if it falls off the track

var vehichleControls = { #dictionary (struct in disguise) used to hold vehichle input operations
	accelerate = false,
	reverse = false,
	turn_left = false, #turning might be changed to a floating point system
	turn_right = false #but will use fixed turn rates for now
	};

func autoDrive(): #controls vehichle if the player is not operating it
	var position = Vector3();
	var scoutPoint = Vector3(position.x, -1, position.z + 40000).rotated(Vector3(0,1,0), rotation.y);
	if (!test_move(self.transform, scoutPoint)):
		vehichleControls.turn_left = true; #turn if approaching a ledge
	else:
		vehichleControls.turn_left = false;

func determineDirection(): #calculate direction to move based on user input
	if (player_controlled): #if vehichle is player controlled assign vehichle control using user input
		vehichleControls.accelerate = Input.is_action_pressed("accelerate");
		vehichleControls.reverse = Input.is_action_pressed("brake");
		vehichleControls.turn_right = Input.is_action_pressed("turn_right");
		vehichleControls.turn_left = Input.is_action_pressed("turn_left");
		
	velocity = Vector3(); #update position vector
	velocity.z += 1; # z vector cannot be 0 otherwise movement will stop completeley

	if (vehichleControls.accelerate): #move forward
		if (current_speed < max_speed): #increase speed overtime
			current_speed +=1;

	elif (current_speed > 0):
		current_speed -= 1; #speed will decline when the user is not accelerating

	if (vehichleControls.turn_left): #rotate vehichle to the left
		rotate_y(turn_rate);

	if (vehichleControls.turn_right): #rotate vehichle to the right
		rotate_y(-turn_rate);

	if (vehichleControls.reverse): #reverse/brake the vehichle
		if (current_speed > reverse_speed): #subtracting speed to into the negatives allows the vehichle to brake or reverse
			current_speed -= 1;

	elif (current_speed < 0): #if the user is not braking and was moving backwards the vehichle will slow down by adding speed
		current_speed += 1;

	if (!test_move(self.transform, Vector3(velocity.x, velocity.y-max_hover_distance, velocity.z))): #vehichle falls if nothing is below it
		if (abs(current_fall_speed) < max_fall_speed):
			current_fall_speed += 1;
	else:
		current_fall_speed = 0;
	velocity = velocity.rotated(Vector3(0,1,0), rotation.y); #rotate the vector around the y axis so it moves in the direction it's facing
	velocity.z *= current_speed; #scale x and z to the current speed
	velocity.x *= current_speed;
	velocity.y -= current_fall_speed;

func _physics_process(delta): #engine function to handle physics code delta is the time between frames
	if (!player_controlled): #automated drive code for npc vehichles
		vehichleControls.accelerate = true;
		autoDrive();
	determineDirection();
	move_and_slide(velocity); #skipped for some reason