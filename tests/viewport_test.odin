package tests

import "core:math"
import "core:testing"
import game "../src"

@(test)
test_viewport_scale_wider_screen :: proc(t: ^testing.T) {
	scale := game.viewport_scale(2560, 720)
	testing.expectf(t, math.abs(scale - 1.0) < 0.001, "wider than design should scale by height, got %f", scale)
}

@(test)
test_viewport_scale_taller_screen :: proc(t: ^testing.T) {
	scale := game.viewport_scale(1280, 1440)
	testing.expectf(t, math.abs(scale - 1.0) < 0.001, "taller than design should scale by width, got %f", scale)
}

@(test)
test_viewport_scale_smaller_screen :: proc(t: ^testing.T) {
	scale := game.viewport_scale(640, 360)
	testing.expectf(t, math.abs(scale - 0.5) < 0.001, "half-size screen should scale to 0.5, got %f", scale)
}

@(test)
test_viewport_scale_preserves_aspect :: proc(t: ^testing.T) {
	scale := game.viewport_scale(1920, 1080)
	testing.expectf(t, math.abs(scale - 1.5) < 0.001, "1080p should scale to 1.5, got %f", scale)
}
