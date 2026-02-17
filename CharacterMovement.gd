extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
var speed = WALK_SPEED

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.05
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#interact variables
var can_move = true

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var ray_cast_3D = $RayCast3D
@onready var amount: Label = $HUD/XP/Amount
@onready var quest_tracker: ColorRect = $HUD/QuestTracker
@onready var title: Label = $HUD/QuestTracker/Details/Title
@onready var objectives: VBoxContainer = $HUD/QuestTracker/Details/Objectives

func _ready():
	Global.player = self
	quest_tracker.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if not can_move:
		return

	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-40),
			deg_to_rad(60)
		)
	
func _physics_process(delta: float) -> void:
	if can_move:
		get_input(delta)
		move_and_slide()
		update_animation(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func get_input(delta: float):
# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED	
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.y = lerp(velocity.y, direction.y * speed, delta * 3.0)
			
func update_animation(delta: float):
	if ray_cast_3D:
		var camera_forward: Vector3 = -head.global_transform.basis.z
		ray_cast_3D.target_position = camera_forward * 2
	# Head bob movement
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV change when running
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
func _headbob(time) -> 	Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func _input(event):
	#Interact with NPC/Quest Item
	if can_move:
		if event.is_action_pressed("interact"):
			var target = ray_cast_3D.get_collider()
			if target != null:
				if target.is_in_group("NPC"):
					print("I'm talking to an NPC!")
					can_move = false
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					target.start_dialog()
				elif target.is_in_group("Item"):
					print("I'm interacting with an item.")
					#todo check if item is needed for quest
					#todo remove item
					target.start_interact()
