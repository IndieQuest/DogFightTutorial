extends Spatial


#############################
# EXPORT PARAMS
#############################
# width
export var width: float = 0.5
export var width_curve: Curve
# length
export var max_points := 100
export var material: Material
# show or hide
export var render: bool = true


#############################
# PARAMS
#############################
onready var half_width = width * 0.5
var points := []


#############################
# OVERRIDE FUNCTIONS
#############################
func _process(delta: float) -> void:
	if render:
		# add new point and render
		add_point()
		_draw_trail()
	else:
		# slowly hide the trail
		if points.size() > 0:
			var last_point = points.pop_back()
			last_point.queue_free()


#############################
# API
#############################
func add_point() -> void:
	var new_point = Position3D.new()
	new_point.translation = self.global_transform.origin
	new_point.rotation = self.global_transform.basis.get_euler()
	points.insert(0, new_point)
	if points.size() > max_points:
		var last_point = points.pop_back()
		last_point.queue_free()


func _draw_trail() -> void:
	if points.size() < 2:
		return
	# create surface tool
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# draw triangles
	for i in range(points.size() - 1):
		_points_to_rect(st, points[i], points[i + 1], i)
	# commit
	st.generate_normals()
#	st.generate_tangents()
	$Node/Render.mesh = st.commit()
	$Node/Render.set_surface_material(0, material)


func _points_to_rect(st: SurfaceTool, p1: Position3D, p2: Position3D, idx: float) -> void:
	var num_points = points.size() - 1
	
	var offset1 = idx / num_points
	var mod1 = half_width * width_curve.interpolate(offset1)
	
	var v1 = p1.translation + p1.transform.basis.x * mod1
	var uv1 = Vector2(0, offset1)
	
	var v2 = p1.translation - p1.transform.basis.x * mod1
	var uv2 = Vector2(1, offset1)
	
	var offset2 = (idx + 1) / num_points
	var mod2 = half_width * width_curve.interpolate(offset2)
	
	var v3 = p2.translation + p2.transform.basis.x * mod2
	var uv3 = Vector2(0, offset2)
	
	var v4 = p2.translation - p2.transform.basis.x * mod2
	var uv4 = Vector2(1, offset2)
	
	st.add_uv(uv1)
	st.add_vertex(v1)
	st.add_uv(uv2)
	st.add_vertex(v2)
	st.add_uv(uv3)
	st.add_vertex(v3)
	
	st.add_uv(uv3)
	st.add_vertex(v3)
	st.add_uv(uv2)
	st.add_vertex(v2)
	st.add_uv(uv1)
	st.add_vertex(v1)
	
	st.add_uv(uv3)
	st.add_vertex(v3)
	st.add_uv(uv4)
	st.add_vertex(v4)
	st.add_uv(uv2)
	st.add_vertex(v2)
	
	st.add_uv(uv2)
	st.add_vertex(v2)
	st.add_uv(uv4)
	st.add_vertex(v4)
	st.add_uv(uv3)
	st.add_vertex(v3)





















