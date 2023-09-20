shader_type spatial;

#define GPU_TRAIL
#include "res://addons/GPUTrail/shaders/gputrail_lib.gdshaderinc"

varying vec2 trail_uv;
void vertex(){
	PREPARE_TRAIL();
	
	// Save the trail UV coordaintes for later
	trail_uv = UV;
	
	// Scroll textures slowly along the length of the trail
	UV.x -= fract(TIME*.4);
}

void fragment(){
	PREPARE_TRAIL_TEXTURES();
	
	// Alpha erosion
	ALPHA = max(ALPHA - trail_uv.x, 0.0);
}