@tool
extends EditorNode3DGizmoPlugin

var editor_plugin : EditorPlugin

func _init(_editor_plugin:EditorPlugin):
	editor_plugin = _editor_plugin
	create_material("main", Color(1,1,1), false, true, true)

func _has_gizmo(node):
	return node is GPUTrail3D

# show gizmo name in visibility list
func _get_gizmo_name():
	return "GPUTrail3DGizmo"

func _redraw(gizmo):
	gizmo.clear()
	
	var node3d : Node3D = gizmo.get_node_3d()
		
	var lines = PackedVector3Array()
	
	lines.push_back(Vector3(0,1,0))
	lines.push_back(Vector3(0,-1,0))
	
	gizmo.add_lines(lines, get_material("main", gizmo), false, Color(1,1,1,1))
