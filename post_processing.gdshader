shader_type spatial;
uniform sampler2D skybox;

uniform float power;
uniform float darkness;
uniform float blackAndWhite;
uniform vec3 colourAMix;
uniform vec3 colourBMix;
uniform vec3 lightDir;

uniform float paramA;
uniform float paramB;

uniform int mode;

varying mat4 CAMERA;

const float epsilon = 0.001f;
const float maxDst = 300.0;
const int maxStepCount = 250;

struct Ray {
	vec3 origin;
	vec3 direction;
};

struct RayHit {
	vec3 position;
	float dinstance;
	vec3 normal;
};

RayHit createRayHit() {
	RayHit hit;
	hit.position = vec3(0.0, 0.0, 0.0);
	hit.dinstance = 1.0/0.0;
	hit.normal = vec3(0.0, 0.0, 0.0);
	return hit;
}

Ray createRay(vec3 origin, vec3 direction) {
	Ray ray;
	ray.origin = origin;
	ray.direction = direction;
	return ray;
}

Ray createCameraRay(vec2 uv, mat4 cameraToWorld, mat4 cameraInverseProjection, vec3 camPos) {
	vec3 origin = (cameraToWorld * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 direction = (cameraInverseProjection * vec4(uv, 0.0, 1.0)).xyz;
	direction = (cameraToWorld * vec4(direction, 0.0)).xyz;
	direction = normalize(direction);
	
	return createRay(origin, direction);
}

void IntersectSomething(Ray ray, inout RayHit bestHit) {
	float distA = dot(sin(ray.origin * 2.0), vec3(1));
	float distB = dot(ray.origin / 3.0, vec3(1));
	float t = mix(distA, distB, 13.0);
	
	if (t > 0.0 && t < bestHit.dinstance) {
		bestHit.dinstance = t;
		bestHit.position = ray.origin + t * ray.direction;
		bestHit.normal = normalize(-bestHit.position);
	}
}

void IntersectGroundPlane(Ray ray, inout RayHit bestHit) {
	float t = -ray.origin.y / ray.direction.y;
	if (t > 0.0 && t < bestHit.dinstance) {
		bestHit.dinstance = t;
		bestHit.position = ray.origin + t * ray.direction;
		bestHit.normal = vec3(0.0, 1.0, 0.0);
	}
}

void IntersectSphere(Ray ray, inout RayHit bestHit, vec4 sphere) {
	vec3 d = ray.origin - sphere.xyz;
	float p1 = -dot(ray.direction, d);
	float p2sqr = p1 * p1 - dot(d,d) + sphere.w * sphere.w;
	if (p2sqr < 0.0) {
		return;
	}
	float p2 = sqrt(p2sqr);
	float t = p1 - p2 > 0.0 ? p1 - p2 : p1 + p2;
	if (t > 0.0 && t < bestHit.dinstance) {
		bestHit.dinstance = t;
		bestHit.position = ray.origin + t * ray.direction;
		bestHit.normal = normalize(bestHit.position - sphere.xyz);
	}
}

RayHit trace(Ray ray) {
	RayHit bestHit = createRayHit();
	IntersectSomething(ray, bestHit);
	IntersectSphere(ray, bestHit, vec4(0, 3.0f, 0, 1.0f));
	return bestHit;
}

vec3 Shade(inout Ray ray, RayHit hit) {
	if (!isinf(hit.dinstance)) {
		return hit.normal * 0.5 + 0.5;
	} else {
		float theta = acos(ray.direction.y) / PI;
		float phi = atan(ray.direction.x, -ray.direction.z) / PI * 0.5;
		return texture(skybox, vec2(phi, theta)).xyz;
	}
}

vec2 SceneInfo(vec3 position) {
    vec3 z = position;
	float dr = 1.0;
	float r = 0.0;
    int iterations = 0;

	float distA = dot(sin(position * paramA * 0.2), vec3(1));
	float distB = dot(position / paramB, vec3(1));
	float t = mix(distA, distB, 3.0);
	
	return vec2(float(iterations),t*1.0);
}

vec2 SceneInfo2(vec3 position) {
    vec3 z = position;
	float dr = 1.0;
	float r = 0.0;
    int iterations = 0;

	for (int i = 0; i < 15 ; i++) {
        iterations = i;
		r = length(z);

		if (r>2.0) {
            break;
        }
        
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, power-1.0)*power*dr + 1.0;

		// scale and rotate the point
		float zr = pow( r,power);
		theta = theta*power;
		phi = phi*power;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=position;
	}
    float dst = 0.5*log(r)*r/dr;
	return vec2(float(iterations),dst*1.0);
}

vec3 EstimateNormal(vec3 p) {
    float x = SceneInfo(vec3(p.x+epsilon,p.y,p.z)).y - SceneInfo(vec3(p.x-epsilon,p.y,p.z)).y;
    float y = SceneInfo(vec3(p.x,p.y+epsilon,p.z)).y - SceneInfo(vec3(p.x,p.y-epsilon,p.z)).y;
    float z = SceneInfo(vec3(p.x,p.y,p.z+epsilon)).y - SceneInfo(vec3(p.x,p.y,p.z-epsilon)).y;
    return normalize(vec3(x,y,z));
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = INV_VIEW_MATRIX;
}

float saturate(float value) {
	return clamp(value, 0.0, 1.0);
}

void fragment() {
	vec2 uv = vec2(SCREEN_UV * 2.0 - 1.0);
	Ray ray = createCameraRay(uv, CAMERA, INV_PROJECTION_MATRIX, CAMERA_POSITION_WORLD);
	
	RayHit hit = trace(ray);
	
	vec4 result = mix(vec4(51,3,20,1),vec4(16,6,28,1),uv.y)/255.0;
	
	float rayDst = 0.0;
    int marchSteps = 0;

    while (rayDst < maxDst && marchSteps < maxStepCount) {
        marchSteps ++;
        vec2 sceneInfo = mode == 0 ? SceneInfo(ray.origin) : SceneInfo2(ray.origin);
        float dst = sceneInfo.y;
        
        // Ray has hit a surface
        if (dst <= epsilon) {
            float escapeIterations = sceneInfo.x;
            vec3 normal = EstimateNormal(ray.origin - ray.direction * epsilon * 5.0);

            float colourA = clamp(dot(normal*0.5+0.5,-lightDir), 0.0, 1.0);
            float colourB = saturate(escapeIterations/32.0);
            vec3 colourMix = clamp(colourA * colourAMix + colourB * colourBMix, 0.0, 1.0);

            result = vec4(colourMix.xyz,1);
            break;
        }
        ray.origin += ray.direction * dst;
        rayDst += dst;
    }

    float rim = float(marchSteps)/darkness;
	
	ALBEDO = mix(result, vec4(1), blackAndWhite).xyz * rim;;
}
