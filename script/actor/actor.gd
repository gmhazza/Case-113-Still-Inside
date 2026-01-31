extends CharacterBody3D



enum states {
	fall,
	crouch,
	aim,
	run,
	walk,
	idle,
	
}

var currentSpeed: float
var movementSpeed: float
var target: Node3D

var walkSpeed: float = 2.0
var runSpeed: float = 5.0
var crouchSpeed: float = 1.0
var movement_blend: Vector2 = Vector2.ZERO
var walk2run_blend: float = 0.0
var walk2crouch_blend: float = 0.0
var aimed_blend: float = 0.0
var blend_speed: float = 15.0
var crouched: bool = false
var aimed: bool = false

@export var currentState: states

@export_category("Components")
@export var cameraPivot: SpringArm3D
@export var visuals: Node3D
@export var animationTree: AnimationTree
@export var upperCollision: CollisionShape3D
@export var ui: CanvasLayer
@export var hand: BoneAttachment3D




func _ready() -> void:
	currentState = states.idle
	movementSpeed = walkSpeed
	currentSpeed = movementSpeed
	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * Manager.sensitivity))
		if currentState != states.aim: visuals.rotate_y(deg_to_rad(event.relative.x * Manager.sensitivity))
		cameraPivot.rotate_x(deg_to_rad(-event.relative.y * Manager.sensitivity))
		cameraPivot.rotation_degrees.x = clampf(cameraPivot.rotation_degrees.x, -65, 65)
	
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("interact"):
		if target:
			var new_object: Node3D = target.duplicate()
			new_object.global_position = Vector3.ZERO
			new_object.make_it_handy()
			target.queue_free()
			hand.add_child(new_object)

	if Input.is_action_just_pressed("crouch"):
		crouched = !crouched
		if crouched:
			currentSpeed = crouchSpeed
			upperCollision.disabled = true
		else:
			currentSpeed = movementSpeed
			upperCollision.disabled = false

func _process(_delta: float) -> void:
	if Input.is_action_pressed("run"):
		movementSpeed = runSpeed
	else:
		movementSpeed = walkSpeed

func _physics_process(delta: float) -> void:

	handleAnimation(delta)
	

	if Input.is_action_pressed("aim"):
		if currentState > states.aim:
			currentState = states.aim
		currentSpeed = crouchSpeed
		cameraPivot.spring_length = lerpf(cameraPivot.spring_length, 0.5, blend_speed * get_physics_process_delta_time())
	else:
		currentState = states.idle
		if not crouched: currentSpeed = movementSpeed
		cameraPivot.spring_length = lerpf(cameraPivot.spring_length, 1.5, blend_speed * get_physics_process_delta_time())


	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		currentState = states.fall
	else:
		if currentState != states.aim:
			currentState = states.idle
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	movement_blend = lerp(movement_blend, input_dir, blend_speed * delta)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		visuals.rotation_degrees = Vector3(0, 180, 0)
		if currentState != states.aim:
			if currentSpeed == runSpeed:
				currentState = states.run
			else:
				currentState = states.walk
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
		if currentState != states.aim: currentState = states.idle


	move_and_slide()


# handle Animations
func handleAnimation(delta: float) -> void:
	animationTree.set("parameters/walk/blend_position", movement_blend)
	animationTree.set("parameters/run/blend_position", movement_blend)
	animationTree.set("parameters/crouch/blend_position", movement_blend)
	animationTree.set("parameters/switch4r/blend_amount", walk2run_blend)
	animationTree.set("parameters/switch4c/blend_amount", walk2crouch_blend)
	animationTree.set("parameters/aim/blend_amount", aimed_blend)

	match currentState:
		states.walk:
			walk2run_blend = lerpf(walk2run_blend, 0.0, blend_speed * delta)
			aimed_blend = lerpf(aimed_blend, 0.0, blend_speed * delta)
		states.run:
			walk2run_blend = lerpf(walk2run_blend, 1.0, blend_speed * delta)
			aimed_blend = lerpf(aimed_blend, 0.0, blend_speed * delta)
		states.crouch:
			walk2crouch_blend = lerpf(walk2crouch_blend, 1.0, blend_speed * delta)
			aimed_blend = lerpf(aimed_blend, 0.0, blend_speed * delta)
		states.aim:
			aimed_blend = lerpf(aimed_blend, 1.0, blend_speed * delta)
		_:
			walk2run_blend = lerpf(walk2run_blend, 0.0, blend_speed * delta)
			walk2crouch_blend = lerpf(walk2crouch_blend, 0.0, blend_speed * delta)
			aimed_blend = lerpf(aimed_blend, 0.0, blend_speed * delta)

	

func onObjectEnteredDetectionArea(object: Node3D) -> void:
	if object.is_in_group("pickup"):
		object.performInteraction(true)
		target = object

func onObjectExitedDetectionArea(object: Node3D) -> void:
	if object.is_in_group("pickup"):
		object.performInteraction(false)
		target = null
