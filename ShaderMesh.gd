extends MeshInstance3D

const BALLS = 0
const MANDEL = 1

enum modes {BALLS,MANDEL}

@export var speed = 0.1

var power = 100.0
var paramA = 0.09
var paramB = 428.8

var darkness = 0.25
var grayscale = false

var currently_selected_shader = BALLS
	
func _physics_process(delta):
	var adjusted_speed = speed * delta
	if Input.is_action_pressed("increase_a"):
		if currently_selected_shader == MANDEL:
			power += 3.0 * delta
		else:
			paramA += adjusted_speed
	
	if Input.is_action_pressed("decrease_a"):
		if currently_selected_shader == MANDEL:
			power -= 3.0 * delta
		else:
			paramA -= adjusted_speed
			
	
	var paramBSpeed = 50.0
	if Input.is_action_pressed("increase_b"):
		paramB += paramBSpeed * delta
		
	if Input.is_action_pressed("decrease_b"):
		paramB -= paramBSpeed * delta
		
	if Input.is_action_pressed("increase_dark"):
		darkness += 0.5 * delta
		
	if Input.is_action_pressed("decrease_dark"):
		darkness -= 0.5 * delta
		
	if Input.is_action_just_pressed("change_mode"):
		if currently_selected_shader == BALLS:
			currently_selected_shader = MANDEL
			get_parent().JET_FORCE = 0.5
			get_parent().JET_FORCE_DELTA = 0.05
		else:
			currently_selected_shader = BALLS
			get_parent().JET_FORCE = 1.0
			get_parent().JET_FORCE_DELTA = 1.0
	
	if Input.is_action_just_pressed("enable_black"):
		grayscale = !grayscale
		
	var material = mesh.surface_get_material(0)
	
	material.set_shader_parameter("paramA", paramA)
	material.set_shader_parameter("power", power)
		
	material.set_shader_parameter("paramB", paramB)
	material.set_shader_parameter("darkness", darkness)
	
	var black
	if grayscale == true:
		black = 1.0
	else:
		black = 0.0
	material.set_shader_parameter("blackAndWhite", black)
	
	material.set_shader_parameter("mode", currently_selected_shader)
		
	
