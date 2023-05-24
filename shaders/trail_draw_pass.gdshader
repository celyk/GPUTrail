shader_type spatial;

render_mode unshaded,world_vertex_coords,cull_disabled;

uniform sampler2D tex : repeat_disable, source_color, hint_default_white;
uniform sampler2D color_ramp : repeat_disable, source_color, hint_default_white;
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
#define clip_overlaps bool(flags & 32)


varying float scale_interp;
varying vec2 clip;
varying vec2 mesh_uv;
void vertex(){
	mesh_uv = UV;
	
	mat4 my_model_matrix = MODEL_MATRIX;
	if(snap_to_transform && INSTANCE_CUSTOM.w==2.0){
		my_model_matrix[1] = emmission_transform * vec4(0,1,0,1);
		my_model_matrix[2] = emmission_transform * vec4(0,-1,0,1);
	}
	
	if(billboard){
		vec3 t0 = my_model_matrix[0].xyz-my_model_matrix[3].xyz;
		vec3 t1 = my_model_matrix[1].xyz-my_model_matrix[2].xyz;
		
		//vec3 up1 = up0;
		vec3 up0 = length(t0)*normalize(
			cross(
				my_model_matrix[3].xyz-INV_VIEW_MATRIX[3].xyz,
				//-INV_VIEW_MATRIX[2].xyz,
				t0));
		vec3 up1 = length(t1)*normalize(
			cross(
				my_model_matrix[2].xyz-INV_VIEW_MATRIX[3].xyz,
				//-INV_VIEW_MATRIX[2].xyz,
				t1));
		
		my_model_matrix[0] = my_model_matrix[3];
		my_model_matrix[1] = my_model_matrix[2];
		
		my_model_matrix[0].xyz += up0;
		my_model_matrix[3].xyz -= up0;
		
		my_model_matrix[1].xyz += up1;
		my_model_matrix[2].xyz -= up1;
	}
	
	vec3 a = mix(my_model_matrix[1].xyz,my_model_matrix[0].xyz,UV.x);
	vec3 b = mix(my_model_matrix[2].xyz,my_model_matrix[3].xyz,UV.x);

	UV.x = (UV.x + INSTANCE_CUSTOM.w-1.0 - 2.0)/(INSTANCE_CUSTOM.z-1.0);

	
	float h = textureLod(curve, vec2(UV.x), 0.0).x;//h=1.0;
	
	VERTEX = mix(a,b,(UV.y-0.5)*h + 0.5);

	if(dewiggle){
		scale_interp = h;
		UV *= scale_interp;
	}
	
		
	clip.x = dot(VERTEX - INV_VIEW_MATRIX[3].xyz,cross(my_model_matrix[1].xyz - INV_VIEW_MATRIX[3].xyz,my_model_matrix[2].xyz - INV_VIEW_MATRIX[3].xyz));
	clip.y = dot(VERTEX - INV_VIEW_MATRIX[3].xyz,cross(my_model_matrix[3].xyz - INV_VIEW_MATRIX[3].xyz,my_model_matrix[0].xyz - INV_VIEW_MATRIX[3].xyz));
}

void fragment(){
	//if(billboard && !FRONT_FACING) discard;
	
	vec2 clip0 = clip;
	float ababab = clip0.x*clip0.y;
	//ababab += dFdx(ababab) + dFdy(ababab);
	//clip0 -= fwidth(clip0);
	if(clip_overlaps && ababab < 0.0) { 
		
		
		
		if(abs(mesh_uv.x-0.5)<0.5)
			discard;
	}
	
	vec2 base_uv = UV;

	if(dewiggle){
		base_uv /= scale_interp;
	}
	
	vec2 raw_uv = base_uv;

	if(vertical_texture){
		base_uv = base_uv.yx;
	}
	
	vec4 T = textureLod(tex, base_uv, 0.0);
	ALBEDO = T.rgb;
	ALPHA = T.a;
	
	if(use_red_as_alpha){
		ALBEDO = vec3(1);
		ALPHA = T.r;
	}
	
	T = textureLod(color_ramp, raw_uv, 0.0);
	ALBEDO *= T.rgb;
	ALPHA *= T.a;
	
	//ALBEDO = vec3(UV,0);
	
	if((base_uv.x < .01) || (.99 < base_uv.x)){
		//ALBEDO = vec3(1,0,1);
	}
}