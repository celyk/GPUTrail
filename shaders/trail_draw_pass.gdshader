shader_type spatial;

render_mode unshaded,world_vertex_coords,cull_disabled;

uniform sampler2D tex : repeat_disable, hint_default_white;
uniform sampler2D curve : repeat_disable, hint_default_white;
uniform mat4 emmission_transform = mat4(1);
uniform int flags = 0;
/*uniform bool vertical_texture = false;
uniform bool use_red_as_alpha = false;
uniform bool billboard = false;
uniform bool dewiggle = false;
uniform bool snap_to_transform = false;*/

#define vertical_texture  bool(flags & 1)
#define use_red_as_alpha  bool(flags & 2)
#define billboard		  bool(flags & 4)
#define dewiggle 		  bool(flags & 8)
#define snap_to_transform bool(flags & 16)

varying float scale_interp;
void vertex(){
	mat4 my_model_matrix = MODEL_MATRIX;
	if(snap_to_transform && INSTANCE_CUSTOM.w==2.0){
		my_model_matrix[1] = emmission_transform * vec4(0,1,0,1);
		my_model_matrix[2] = emmission_transform * vec4(0,-1,0,1);
	}
	
	if(billboard){
	
		my_model_matrix[1] = (my_model_matrix[1]+my_model_matrix[2])/2.0;
		my_model_matrix[2] = my_model_matrix[1];
		my_model_matrix[0] = (my_model_matrix[0]+my_model_matrix[3])/2.0;
		my_model_matrix[3] = my_model_matrix[0];
		
		vec3 up0 = normalize(cross(my_model_matrix[1].xyz-my_model_matrix[0].xyz,INV_VIEW_MATRIX[3].xyz));
		vec3 up1 = up0;
		
		my_model_matrix[1].xyz += up0;
		my_model_matrix[2].xyz -= up0;
		my_model_matrix[0].xyz += up1;
		my_model_matrix[3].xyz -= up1;
	}
	
	vec3 a = mix(my_model_matrix[1].xyz,my_model_matrix[0].xyz,UV.x);
	vec3 b = mix(my_model_matrix[2].xyz,my_model_matrix[3].xyz,UV.x);

	UV.x = (UV.x + INSTANCE_CUSTOM.w-1.0 - 2.0)/(INSTANCE_CUSTOM.z-1.0);

	
	float h = textureLod(curve, vec2(UV.x), 0.0).x;//h=1.0;
	
	VERTEX = mix(a,b,(UV.y-0.5)*h + 0.5);
	
	if(vertical_texture){
		UV = UV.yx;
		//UV.x = 1.0 - UV.x;
	}
	
	if(dewiggle){
		scale_interp = h;
		UV *= scale_interp;
	}
}

void fragment(){
	vec2 base_uv = UV;
	
	if(dewiggle){
		base_uv /= scale_interp;
	}
	
	vec4 T = texture(tex, base_uv);
	ALBEDO = T.xyz;
	ALPHA = T.w;
	
	if(use_red_as_alpha){
		ALBEDO = vec3(1);
		ALPHA = T.x;
	}
	
	//ALBEDO = vec3(UV,0);
	
	if((base_uv.x < .01) || (.99 < base_uv.x)){
		//ALBEDO = vec3(1,0,1);
	}
}