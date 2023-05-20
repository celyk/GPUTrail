@tool
class_name GPUTrail3D extends GPUParticles3D

## [br]A node for creating a ribbon trail effect.[br]


# PUBLIC

@export var length = 100 : set = _set_length
@export var texture : Texture : set = _set_texture
@export var color_ramp : GradientTexture1D : set = _set_color_ramp
@export var curve : CurveTexture : set = _set_curve
@export var vertical_texture := false : set = _set_vertical_texture
@export var use_red_as_alpha := false : set = _set_use_red_as_alpha
@export var billboard := false : set = _set_billboard
@export var dewiggle := false : set = _set_dewiggle
@export var snap_to_transform := false : set = _set_snap_to_transform


# PRIVATE

const _DEFAULT_TEXTURE = "defaults/texture.tres"
const _DEFAULT_CURVE = "defaults/curve.tres"

var _defaults_have_been_set = false
func _get_property_list():
	return [{"name": "_defaults_have_been_set","type": TYPE_BOOL,"usage": PROPERTY_USAGE_NO_EDITOR}]

func _ready():
	if not _defaults_have_been_set:
		_defaults_have_been_set = true

		amount = length
		lifetime = length
		explosiveness = 1 # emits all particles at once
		fixed_fps = 0 # the main fps is default

		process_material = ShaderMaterial.new()
		process_material.shader = preload("shaders/trail.gdshader")

		draw_pass_1 = QuadMesh.new()
		draw_pass_1.material = ShaderMaterial.new()
		draw_pass_1.material.shader = preload("shaders/trail_draw_pass.gdshader")

		draw_pass_1.material.set_shader_parameter("tex", preload(_DEFAULT_TEXTURE))
		draw_pass_1.material.set_shader_parameter("curve", preload(_DEFAULT_CURVE))

		draw_pass_1.material.resource_local_to_scene = true

func _set_length(value):
	length = value
	
	if _defaults_have_been_set:
		amount = value
		lifetime = value
	
	restart()
func _set_texture(value):
	texture = value
	if value: 
		draw_pass_1.material.set_shader_parameter("tex", texture)
	else:
		draw_pass_1.material.set_shader_parameter("tex", preload(_DEFAULT_TEXTURE))
func _set_color_ramp(value):
	color_ramp = value
	draw_pass_1.material.set_shader_parameter("color_ramp", color_ramp)
func _set_curve(value):
	curve = value
	if value: 
		draw_pass_1.material.set_shader_parameter("curve", curve)
	else:
		draw_pass_1.material.set_shader_parameter("curve", preload(_DEFAULT_CURVE))
func _set_vertical_texture(value):
	vertical_texture = value
	flags = _set_flag(flags,0,value)
	draw_pass_1.material.set_shader_parameter("flags", flags)
func _set_use_red_as_alpha(value):
	use_red_as_alpha = value
	flags = _set_flag(flags,1,value)
	draw_pass_1.material.set_shader_parameter("flags", flags)
func _set_billboard(value):
	billboard = value
	flags = _set_flag(flags,2,value)
	draw_pass_1.material.set_shader_parameter("flags", flags)
func _set_dewiggle(value):
	dewiggle = value
	flags = _set_flag(flags,3,value)
	draw_pass_1.material.set_shader_parameter("flags", flags)
func _set_snap_to_transform(value):
	snap_to_transform = value
	flags = _set_flag(flags,4,value)
	draw_pass_1.material.set_shader_parameter("flags", flags)

func _process(dt):
	if(snap_to_transform):
		draw_pass_1.material.set_shader_parameter("emmission_transform", global_transform)

var flags = 0
func _set_flag(i, idx : int, value : bool):
	return (i & ~(1 << idx)) | (int(value) << idx)
