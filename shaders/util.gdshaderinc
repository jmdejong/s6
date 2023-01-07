


float transition(float t, float edge_min, float edge_max) {
	return clamp((t - edge_min) / (edge_max - edge_min), 0.0, 1.0);
}
