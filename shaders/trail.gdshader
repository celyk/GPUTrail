shader_type particles;

render_mode keep_data,disable_force,disable_velocity;



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
	}
	
	// restart
	if(CUSTOM.w == amount+1.0){
		CUSTOM.w = 1.0;
	}
	
	if(CUSTOM.w == 1.0){
		// sets the quad to the line to cache this frame, it is not yet visible
		TRANSFORM = mat4(a,a,b,b);
	}
	
	if(CUSTOM.w == 2.0){
		// sets the right edge of the quad
		TRANSFORM[1] = a;
		TRANSFORM[2] = b;
	}

	CUSTOM.w++;
}