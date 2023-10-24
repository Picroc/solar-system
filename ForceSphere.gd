extends MeshInstance3D

@export var radius = 0.05
var current_vector: Vector3 = Vector3.ZERO
var line
var cone

# Called when the node enters the scene tree for the first time.
func _ready():
	var origin = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	var material = ORMMaterial3D.new()
	
	origin.mesh = sphere
	origin.cast_shadow = false
	
	sphere.radius = radius
	sphere.height = radius*2
	sphere.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.AQUA
	
	add_child(origin)

func clear_vector():
	if line != null:
		line.queue_free()
	if cone != null:
		cone.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_vector()
	
	if current_vector:
		var target = global_position + current_vector
		look_at(target)
		var vector = Vector3.FORWARD
		
		line = MeshInstance3D.new()
		var line_mesh = CylinderMesh.new()
		var material = ORMMaterial3D.new()
		
		line.mesh = line_mesh
		line.cast_shadow = false
		
		line_mesh.bottom_radius = 0.005
		line_mesh.top_radius = 0.005
		line_mesh.height = 0.1
		line_mesh.material = material
		
		line.position = vector * 0.1 / 2
		line.rotate_x(PI / 2)
		
		cone = MeshInstance3D.new()
		var cone_mesh = CylinderMesh.new()
		
		cone.cast_shadow = false
		cone.mesh = cone_mesh
		
		cone_mesh.top_radius = 0
		cone_mesh.bottom_radius = radius + 0.005
		cone_mesh.height = 0.02
		
		cone_mesh.material = material
		
		cone.position = vector.normalized() * 0.095
		cone.rotate_x(-PI / 2)
		
		
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.AQUAMARINE
		
		add_child(line)
		add_child(cone)
		
		
	
