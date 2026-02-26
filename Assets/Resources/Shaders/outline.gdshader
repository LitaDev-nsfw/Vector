shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float outline_width : hint_range(0, 10) = 1.0;
uniform int outline_pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool outline_inside = false;
uniform bool outline_add_margins = true; // only useful when inside is false
uniform vec2 outline_number_of_images = vec2(1.0); // number of horizontal and vertical images in the sprite sheet

varying flat vec4 modulate;

void vertex() {
	modulate = COLOR;
	
	if (outline_add_margins) {
		if ((UV.x <= 0.0 || UV.x >= 1.0) && (UV.y <= 0.0 || UV.y >= 1.0)) {
			VERTEX += (UV * 2.0 - 1.0) * outline_width;
		} else {
			VERTEX += sign(VERTEX) * outline_width; // replace sign(VERTEX) by (sign(VERTEX) * 2.0 - 1.0) if your AnimatedSprite2D isn't Centered
		}
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
	for (float i = -ceil(outline_width); i <= ceil(outline_width); i++) {
		float x = abs(i) > outline_width ? outline_width * sign(i) : i;
		float offset;
		
		if (outline_pattern == 0) {
			offset = outline_width - abs(x);
		} else if (outline_pattern == 1) {
			offset = floor(sqrt(pow(outline_width + 0.5, 2) - x * x));
		} else if (outline_pattern == 2) {
			offset = outline_width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) == outline_inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	vec2 image_top_left = floor(uv * outline_number_of_images) / outline_number_of_images;
	vec2 image_bottom_right = image_top_left + vec2(1.0) / outline_number_of_images;
	
	if (outline_add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(outline_width * 2.0) * outline_number_of_images);
		
		uv = (uv - texture_pixel_size * outline_width - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;
		
		if (uv != clamp(uv, image_top_left, image_bottom_right)) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv) * modulate;
		}
	} else {
		COLOR = texture(TEXTURE, uv) * modulate;
	}
	
	if ((COLOR.a > 0.0) == outline_inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
		COLOR.rgb = outline_inside ? mix(COLOR.rgb, outline_color.rgb * modulate.rgb, outline_color.a * modulate.a) : outline_color.rgb * modulate.rgb;
		COLOR.a += (1.0 - COLOR.a) * outline_color.a * modulate.a;
	}
}
