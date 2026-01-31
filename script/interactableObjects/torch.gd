extends StaticBody3D



@export var collision: CollisionShape3D
@export var label3d: Label3D

func _ready() -> void:
	label3d.visible = false

func performInteraction(vis: bool) -> void:
	label3d.visible = vis
	return

func make_it_handy() -> void:
	label3d.visible = false
	collision.disabled = true
