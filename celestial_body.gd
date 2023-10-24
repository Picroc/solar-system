@tool
extends RigidBody3D
class_name CelestialBody

signal radius_changed(value: float)
signal surface_material_changed(value)

@export var radius: float:
	get:
		return radius
	set(value):
		radius_changed.emit(value)
		radius = value
		

@export var surface_material: StandardMaterial3D:
	set(value):
		surface_material_changed.emit(value)
		surface_material = value

@export var initialVelocity: Vector3
@export var affectedBodiesArray: Array
var currentVelocity: Vector3

func awake():
	apply_central_impulse(initialVelocity)
	
func update_velocity(allBodies: Array[CelestialBody]):
	var gravity_vector = Vector3.ZERO
	for otherBody in allBodies:
		if otherBody != self:
			var sqrDist := position.distance_squared_to(otherBody.position)
			var forceDir := position.direction_to(otherBody.position)
			var force = forceDir * Universe.gravitationalConstant * otherBody.mass / sqrDist
			gravity_vector += force
	
	apply_central_force(gravity_vector)
			
func _physics_process(delta):
	if not Engine.is_editor_hint():
		update_velocity(Universe.get_all_bodies())
		
func _on_radius_changed(value):
	$CollisionShape3D.shape.radius = value
	$MeshInstance3D.mesh.radius = value
	$MeshInstance3D.mesh.height = value * 2

func _ready():
	if not Engine.is_editor_hint():
		Universe.add_universe_body(self)
		awake()


func _on_surface_material_changed(value):
	$MeshInstance3D.set_surface_override_material(0, value)
