@tool
@icon("bounce.svg")
class_name GPUTrail3D extends GPUParticles3D

## [br]A node for creating a ribbon trail effect.
## [br][color=purple]Made by celyk[/color]
##
## This node serves as an alternative to CPU based trails.[br]


# TODO:
# Add categories for parameters
# Add flipbook support
# Hide the actual GPUParticles3D node
# Restructure code, use enums for flags
# Add more polygons, make trail smoother
# Add an acceleration parameter
# Add a gizmo/visual indicator of the emmission  line
# Design an icon.svg
# Port to Godot 3.5
# Port to 2D
# Allow custom material

# PUBLIC

## Length is the number of steps in the trail
@export var length = 100 : set = _set_length

## The main texture of the trail.[br]
## [br]Set [member vertical_texture] to adjust for orientation[br]
##
## [br]Enable [member use_red_as_alpha] to use the red color channel as alpha
@export var texture : Texture : set = _set_texture

## A color ramp for modulating the color along the length of the trail
@export var color_ramp : GradientTexture1D : set = _set_color_ramp

## A curve for modulating the width along the length of the trail
@export var curve : CurveTexture : set = _set_curve

## Set [member vertical_texture] to adjust for orientation
@export var vertical_texture := false : set = _set_vertical_texture

## Enable [member use_red_as_alpha] to use the red color channel of [member texture] as alpha
@export var use_red_as_alpha := false : set = _set_use_red_as_alpha

## Makes trail face camera. I haven't finished this yet
@export var billboard := false : set = _set_billboard

## Enable to improve the mapping of [member texture] to the trail
@export var dewiggle := true : set = _set_dewiggle

## Enable to improve the mapping of [member texture] to the trail
@export var clip_overlaps := true : set = _set_clip_overlaps

## Enable [member snap_to_transform] to snap the start of the trail to the nodes position. This may not be noticeable unless you
## have changed [member fixed_fps], which you can use to optimize the trail
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

		color_ramp = preload(_DEFAULT_TEXTURE)
		curve = preload(_DEFAULT_CURVE)
		
		draw_pass_1.material.resource_local_to_scene = true
	
	length = length
	vertical_texture = vertical_texture
	use_red_as_alpha = use_red_as_alpha
	billboard = billboard
	dewiggle = dewiggle
	clip_overlaps = clip_overlaps
	snap_to_transform = snap_to_transform

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
	_flags = _set_flag(_flags,0,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)
func _set_use_red_as_alpha(value):
	use_red_as_alpha = value
	_flags = _set_flag(_flags,1,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)
func _set_billboard(value):
	billboard = value
	_flags = _set_flag(_flags,2,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)
	if value && _defaults_have_been_set:
		_update_billboard_transform( global_transform.basis[0] )
	
	restart()
func _set_dewiggle(value):
	dewiggle = value
	_flags = _set_flag(_flags,3,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)
func _set_snap_to_transform(value):
	snap_to_transform = value
	_flags = _set_flag(_flags,4,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)
func _set_clip_overlaps(value):
	clip_overlaps = value
	_flags = _set_flag(_flags,5,value)
	draw_pass_1.material.set_shader_parameter("flags", _flags)


@onready var _old_pos : Vector3 = global_position
@onready var _billboard_transform : Transform3D = global_transform
func _process(delta):
	if(snap_to_transform):
		draw_pass_1.material.set_shader_parameter("emmission_transform", global_transform)
	
	
	await RenderingServer.frame_pre_draw
	
	if(billboard):
		var delta_position = global_position - _old_pos
		
		if delta_position:
			var tangent = global_transform.basis[1].length() * (delta_position).normalized()
			_update_billboard_transform(tangent)

		RenderingServer.instance_set_transform(get_instance(), _billboard_transform)
	
	_old_pos = global_position

func _update_billboard_transform(tangent):
	_billboard_transform = global_transform
	var p = _billboard_transform.basis[1]
	var x = tangent
	var angle = p.angle_to(x)
	var rotation_axis = p.cross(x).normalized()
	if rotation_axis: 
		_billboard_transform.basis = _billboard_transform.basis.rotated(rotation_axis,angle)
		_billboard_transform.basis = _billboard_transform.basis.scaled(Vector3(0.5,0.5,0.5))
		_billboard_transform.origin += _billboard_transform.basis[1]

var _flags = 0
func _set_flag(i, idx : int, value : bool):
	return (i & ~(1 << idx)) | (int(value) << idx)
