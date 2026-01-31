extends Node




@export var model: Node3D

@export_group("Transition Settings")
@export var transition_type: AsyncScene.TransitionType = AsyncScene.TransitionType.WipeLeft
@export var transition_duration: float = 1.0
@export var transition_color: Color = Color.BLACK
@export var transition_pause_duration: float = 1.0


func _ready() -> void:
	var animplayer: AnimationPlayer = model.get_node("AnimationPlayer") as AnimationPlayer
	animplayer.play("Idle_Talking")


func onStartButtonPressed() -> void:
	$ui/ColorRect/VBoxOutter/VBoxInner/start.disabled = true
	$ui/ColorRect/VBoxOutter/VBoxInner/option.disabled = true
	$ui/ColorRect/VBoxOutter/VBoxInner/quit.disabled = true
	var loader: AsyncScene = AsyncScene.new(
		"res://x64/world/prototype_world.tscn",
		AsyncScene.LoadingOperation.Replace,
		get_tree().root
	)
	loader.with_transition(transition_type, transition_duration, transition_color)
	loader.with_pause(transition_pause_duration)
	loader.loading_completed.connect(on_load_complete)
	loader.loading_error.connect(on_load_error)
	loader.start()

func onOptionButtonPressed() -> void:
	add_child(preload("res://x64/interfaces/option_menu.tscn").instantiate())

func onQuitButtonPressed() -> void:
	get_tree().quit(0)


func on_load_complete(loader: AsyncScene) -> void:
	loader.change_scene()
	await get_tree().create_timer(1).timeout
	self.queue_free()

func on_load_error(err_code: AsyncScene.ErrorCode, err_msg: String) -> void:
	# Handle the error, e.g., show an error message to the user
	print("Failed to load scene. Error %s: %s" % [err_code, err_msg])