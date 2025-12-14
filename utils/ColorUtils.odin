package utils

import "../third_party/clay"


// Helper function to create clay colors with optional opacity
make_clay_color :: proc "contextless" (r, g, b: f32, a: f32 = 255) -> clay.Color {
	return clay.Color{r, g, b, a}
}

// Basic color constants (compile-time)
@(private)
RED_BASE :: clay.Color{255, 0, 0, 255}
@(private)
GREEN_BASE :: clay.Color{0, 255, 0, 255}
@(private)
BLUE_BASE :: clay.Color{0, 0, 255, 255}
@(private)
WHITE_BASE :: clay.Color{255, 255, 255, 255}
@(private)
BLACK_BASE :: clay.Color{0, 0, 0, 255}
@(private)
YELLOW_BASE :: clay.Color{255, 255, 0, 255}
@(private)
CYAN_BASE :: clay.Color{0, 255, 255, 255}
@(private)
MAGENTA_BASE :: clay.Color{255, 0, 255, 255}
@(private)
GRAY_BASE :: clay.Color{128, 128, 128, 255}
@(private)
ORANGE_BASE :: clay.Color{255, 165, 0, 255}
@(private)
PURPLE_BASE :: clay.Color{128, 0, 128, 255}
@(private)
PINK_BASE :: clay.Color{255, 192, 203, 255}

// Fancy color constants (compile-time)
@(private)
CORAL_BASE :: clay.Color{255, 127, 80, 255}
@(private)
TURQUOISE_BASE :: clay.Color{64, 224, 208, 255}
@(private)
GOLD_BASE :: clay.Color{255, 215, 0, 255}
@(private)
SILVER_BASE :: clay.Color{192, 192, 192, 255}
@(private)
BRONZE_BASE :: clay.Color{205, 127, 50, 255}
@(private)
LAVENDER_BASE :: clay.Color{230, 230, 250, 255}
@(private)
MINT_BASE :: clay.Color{152, 251, 152, 255}
@(private)
PEACH_BASE :: clay.Color{255, 218, 185, 255}
@(private)
SKY_BLUE_BASE :: clay.Color{135, 206, 235, 255}
@(private)
INDIGO_BASE :: clay.Color{75, 0, 130, 255}

// Public API functions with optional opacity parameter
COLOR_RED :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		0,
		0,
		opacity,
	)}
COLOR_GREEN :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		0,
		255,
		0,
		opacity,
	)}
COLOR_LIGHT_GREEN :: proc "contextless" (
	opacity: f32 = 255,
) -> clay.Color {return make_clay_color(136, 245, 100, opacity)}
COLOR_BLUE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		0,
		0,
		255,
		opacity,
	)}
COLOR_WHITE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		255,
		255,
		opacity,
	)}
COLOR_BLACK :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		0,
		0,
		0,
		opacity,
	)}
COLOR_YELLOW :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		255,
		0,
		opacity,
	)}
COLOR_CYAN :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		0,
		255,
		255,
		opacity,
	)}
COLOR_MAGENTA :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		0,
		255,
		opacity,
	)}
COLOR_GRAY :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		128,
		128,
		128,
		opacity,
	)}
COLOR_ORANGE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		165,
		0,
		opacity,
	)}
COLOR_PURPLE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		128,
		0,
		128,
		opacity,
	)}
COLOR_PINK :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		192,
		203,
		opacity,
	)}

COLOR_CORAL :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		127,
		80,
		opacity,
	)}
COLOR_TURQUOISE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		64,
		224,
		208,
		opacity,
	)}
COLOR_GOLD :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		215,
		0,
		opacity,
	)}
COLOR_SILVER :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		192,
		192,
		192,
		opacity,
	)}
COLOR_BRONZE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		205,
		127,
		50,
		opacity,
	)}
COLOR_LAVENDER :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		230,
		230,
		250,
		opacity,
	)}
COLOR_MINT :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		152,
		251,
		152,
		opacity,
	)}
COLOR_PEACH :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		255,
		218,
		185,
		opacity,
	)}
COLOR_SKY_BLUE :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		135,
		206,
		235,
		opacity,
	)}
COLOR_INDIGO :: proc "contextless" (opacity: f32 = 255) -> clay.Color {return make_clay_color(
		75,
		0,
		130,
		opacity,
	)}

COLOR_LIGHT_GRAY :: proc "contextless" (opacity: f32 = 255) -> clay.Color {
	return make_clay_color(194, 194, 194, opacity)
}

COLOR_TRANSPARENT :: clay.Color{0, 0, 0, 0}
