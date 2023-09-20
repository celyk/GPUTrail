shader_type particles;

render_mode keep_data,disable_force,disable_velocity;

uniform vec3 acceleration = vec3(0,1,0);

const float fixed_dt = 1.0/60.0;
void simulate(inout vec3 pos0, inout vec3 vel0, inout vec3 pos1, inout vec3 vel1, float dt) {
	vel0 += acceleration * dt;
	vel1 += acceleration * dt;
	
	pos0 += vel0 * dt;
	pos1 += vel1 * dt;
}

void process() {
	// CUSTOM.w tracks the particles place in the trail, in range (0..LIFETIME]
	// requires that LIFETIME = number of particles
	const float amount = LIFETIME;
	
	vec4 a = EMISSION_TRANSFORM * vec4(0,1,0,1);
	vec4 b = EMISSION_TRANSFORM * vec4(0,-1,0,1);
	
	// start
	if(CUSTOM.w == 0.0){
		CUSTOM.w = float(INDEX)+1.0;
		
		// needed to pass to draw pass
		CUSTOM.z = amount;
		
		// needed to initialize in case of CUSTOM.w == 2.0
		TRANSFORM = mat4(a,a,b,b);
		VELOCITY = vec3(0);
		COLOR.xyz = vec3(0);
	}
	
	vec3 pos0 = (TRANSFORM[0] + TRANSFORM[3]).xyz/2.0;
	vec3 pos1 = (TRANSFORM[1] + TRANSFORM[2]).xyz/2.0;
	vec3 d0 = pos0;
	vec3 d1 = pos1;
	simulate(pos0,VELOCITY,pos1,COLOR.xyz,DELTA);
	TRANSFORM[0].xyz += pos0 - d0;
	TRANSFORM[3].xyz += pos0 - d0;
	TRANSFORM[1].xyz += pos1 - d1;
	TRANSFORM[2].xyz += pos1 - d1;
	
	// restart
	if(CUSTOM.w == amount+1.0){
		CUSTOM.w = 1.0;
	}

	if(CUSTOM.w == 1.0){
		// sets the quad to the line to cache this frame, it is not yet visible
		TRANSFORM = mat4(a,a,b,b);
		VELOCITY = vec3(0);
		COLOR.xyz = vec3(0);
	}
	
	if(CUSTOM.w == 2.0){
		// sets the right edge of the quad
		TRANSFORM[1] = a;
		TRANSFORM[2] = b;
		
		COLOR.xyz = vec3(0);
	}

	CUSTOM.w++;
}