extends StaticBody

#Node Dependencies
onready var LapZone = get_node("Lap Zone");
onready var PreCheckZone = get_node("Lap Zone 2");

#Export Vars
export var Lap_Count = 3; #amount of laps the track has

#Lap Validation
var lapAuthorizationScore = 0; # set to -1 due to area exit being fired off when object is spawned
var previousZone = 0; # checks which area was last entered
signal lap_completed(vehichle); #executes when a vehichle finishes a lap

func _on_Lap_Zone_body_entered(body): #emit a signal with the vehichle that left the lap zone
	if (body.is_class("KinematicBody")):
		if (body.lapAuthorizationScore == 0 && previousZone != 1): #if the user attempts to cheat by going throught the finish at the start
			body.lapAuthorizationScore = -2; #reduce lap authorization to -2 forcing them to go throught the track again
		if (body.lapAuthorizationScore == 1):
			emit_signal("lap_completed", body); #a signal is emitted when a valid lap is completed
			body.lapAuthorizationScore = 0; #autorization score is reset after a valid lap
		body.previousZone = 2;

func _on_Lap_Zone_2_body_entered(body):
	if (body.is_class("KinematicBody")):
		if (body.lapAuthorizationScore < 0):
			body.lapAuthorizationScore += 1
		if (body.previousZone != 1):
			body.lapAuthorizationScore += 1 #lap authorization does not increase if the user was in the precheck previously
		body.previousZone = 1 #update previous zone