extends Node3D

@export var Line: Array[String]
@export var VoiceoverAudio: Array[AudioStream]
var CurrentLine: int 
var ChangingLines: bool

func _ready() -> void:
	hide()
	$Animation.play_backwards("UI_Appear")
	CurrentLine = -1
	ChangingLines == false
	$Voiceover.stream = VoiceoverAudio[0]
	$Base/Line.text = Line[0]
	
func play_dialogue():
	if CurrentLine == -1:
		show()
		$Animation.play("UI_Appear")
	
func ui_initialized(anim_name: StringName) -> void:
	if anim_name == "UI_Appear" and visible and CurrentLine == -1:
		next_line()
	elif anim_name == "Line_End" and ChangingLines:
		next_line()
		ChangingLines = false
		$Animation.play_backwards("Line_End")
		
func next_line():
	CurrentLine += 1
	print("CURRENTLINE   " + str(CurrentLine))
	$Voiceover.stream = VoiceoverAudio[CurrentLine]
	$Voiceover.play()
	$Base/Line.text = Line[CurrentLine]

func voiceover_finished():
	print("VO FINISH   " + str(CurrentLine) + str(len(Line)-1))
	if CurrentLine < len(Line)-1:
		$Animation.play("Line_End")
		ChangingLines = true
	else:
		finish_dialogue()
		
func finish_dialogue() -> void:
	$Animation.play_backwards("UI_Appear")
