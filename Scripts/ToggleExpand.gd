extends Control

onready var Animator=$"../../ExpandAnimation"
onready var Box=$ColorRect
var IsExpand=false

func _ready():
	pass

func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.get_button_index()==1 :
			if !IsExpand:
				Animator.play("SideBarExpandAnimation")
			else:
				Animator.play_backwards("SideBarExpandAnimation")
			IsExpand=!IsExpand

func _on_ColorRect_mouse_entered():
	Box.color="3a4474"

func _on_ColorRect_mouse_exited():
	Box.color="2a3153"
