shader_type spatial;

#define GPU_TRAIL
#include "res://addons/GPUTrail/shaders/gputrail_lib.gdshaderinc"

varying vec2 trail_uv;
void vertex(){
	PREPARE_TRAIL();
	
}

void fragment(){
	PREPARE_TRAIL_TEXTURES();
	
}