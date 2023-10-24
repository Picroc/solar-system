extends CharacterBody3D

@onready var camera = $Camera3D

const SPEED = 5.0
@export var JET_FORCE = 5
const ANGLE_KILLER = 0.5
var JET_FORCE_DELTA = 1.0

var acceleration = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate(transform.basis.y, -event.relative.x * 0.005)
		rotate(transform.basis.x, -event.relative.y * 0.005)
		#rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		JET_FORCE += JET_FORCE_DELTA
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		JET_FORCE = max(JET_FORCE - JET_FORCE_DELTA, 0.0)
		
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func apply_gravity():
	var gravity_vector = Vector3.ZERO
	var allBodies = Universe.get_all_bodies()
	
	for otherBody in allBodies:
		var sqrDist := position.distance_squared_to(otherBody.position)
		var forceDir := position.direction_to(otherBody.position)
		var force = forceDir * Universe.gravitationalConstant * otherBody.mass / sqrDist
		gravity_vector += force
	
	return gravity_vector


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var current_force = Vector3.ZERO
	
	if Input.is_action_pressed("roll_left"):
		rotate(transform.basis.z, 0.5 * delta)
		
	if Input.is_action_pressed("roll_right"):
		rotate(transform.basis.z, -0.5 * delta)
	
	if Input.is_action_pressed("jump"):
		current_force += global_transform.basis.y.normalized() * JET_FORCE
	
	if Input.is_action_pressed("crouch"):
		current_force += -global_transform.basis.y.normalized() * JET_FORCE
		
	if Input.is_action_just_pressed("reset_pos"):
		position = Vector3.ZERO
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#current_force.x += direction.x * JET_FORCE
		#current_force.z += direction.z * JET_FORCE
		
	if input_dir.x:
		current_force += sign(input_dir.x) * global_transform.basis.x.normalized() * JET_FORCE
		
	if input_dir.y:
		current_force += sign(input_dir.y) * global_transform.basis.z.normalized() * JET_FORCE
		
	if Input.is_action_pressed("stabilize"):
		current_force.x = -min(velocity.x, velocity.x)
		current_force.y = -min(velocity.y, velocity.y)
		current_force.z = -min(velocity.z, velocity.z)
		
	current_force += apply_gravity()
		
	velocity = current_force
	%ForceSphere.current_vector = current_force
	
	move_and_slide()
