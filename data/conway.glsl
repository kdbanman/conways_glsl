#ifdef GL_ES
precision lowp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform vec2 resolution;
uniform bool firstFrame;

uniform sampler2D seed;
uniform sampler2D ppixels;  // this is a special processing thing that gets read for rendering

vec4 liveColor = vec4(1.);
vec4 deadColor = vec4(1., vec3(0.));

float liveNeighbors(sampler2D environment, vec2 position, vec2 pixel) {
	float neighborhoodSum = 0.;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(-1., -1.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(-1., 0.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(-1., 1.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(1., -1.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(1., 0.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(1., 1.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(0., -1.)).g;
	neighborhoodSum += texture2D(environment, position + pixel * vec2(0., 1.)).g;

	return neighborhoodSum;
}

void main( void ) {
	vec2 position = (gl_FragCoord.xy / resolution.xy);
	vec2 pixel = 1. / resolution;

	float neighborhoodSum;
	vec4 self;
	if (firstFrame) {
		neighborhoodSum = liveNeighbors(seed, position, pixel);
		self = texture2D(seed, position);
	} else {
		neighborhoodSum = liveNeighbors(ppixels, position, pixel);
		self = texture2D(ppixels, position);
	}

	// low precision floating point comparison will look ugly below.
	if (self.g < 0.5) {
		if ((neighborhoodSum >= 2.9) && (neighborhoodSum <= 3.1)) {
			gl_FragColor = liveColor;
		} else {
			gl_FragColor = deadColor;
		}
	} else {
		if ((neighborhoodSum >= 1.9) && (neighborhoodSum <= 3.1)) {
			gl_FragColor = liveColor;
		} else {
			gl_FragColor = deadColor;
		}
	}
}