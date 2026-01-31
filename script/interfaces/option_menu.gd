extends CanvasLayer



@export var tta: CheckBox
@export var resolution: OptionButton
@export var sensitivity: HSlider
@export var sensitivity_value: Label

func _ready() -> void:
	sensitivity.value = Manager.sensitivity
	sensitivity_value.text = str(sensitivity.value)
	tta.button_pressed = (ProjectSettings.get_setting("rendering/anti_aliasing/quality/use_taa"))
	var width: String = str(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var height: String = str(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var res: String = width + " x " + height
	if resolution.get_item_text(0) == res:
		resolution.selected = 0
	elif resolution.get_item_text(1) == res:
		resolution.selected = 1
	elif resolution.get_item_text(2) == res:
		resolution.selected = 2
	else:
		ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
		ProjectSettings.set_setting("display/window/size/viewport_height", 720)
		resolution.selected = 0
	
	
	print(res)


func onQuitPressed() -> void:
	queue_free()
