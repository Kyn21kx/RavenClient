package OdinClient

import ClientUI "./application"
import "base:runtime"
import "core:fmt"
import clay "third_party/clay"
import Utils "utils"
import "vendor:raylib"

windowWidth: i32 = 1024
windowHeight: i32 = 768
fonts: [10]raylib.Font

ErrorHandler :: proc "c" (errorData: clay.ErrorData) {
	context = runtime.default_context()
	fmt.printfln("Error: %s", errorData.errorText.chars)
}

LoadResources :: proc() {
	fonts[0] = raylib.LoadFontEx("assets/fonts/Nova_Square/NovaSquare-Regular.ttf", 72, nil, 0)
	raylib.SetTextureFilter(fonts[0].texture, raylib.TextureFilter.POINT)
	append(&raylib_fonts, Raylib_Font{fontId = 0, font = fonts[0]})
}

Init :: proc() {
	minMemory: u32 = clay.MinMemorySize()
	memory := make([^]u8, minMemory)
	arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(cast(uint)minMemory, memory)

	clay.Initialize(
		arena,
		{cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()},
		{handler = ErrorHandler},
	)
	clay.SetMeasureTextFunction(measure_text, &fonts[0])

	raylib.SetTraceLogLevel(raylib.TraceLogLevel.ERROR)
	raylib.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	raylib.InitWindow(windowWidth, windowHeight, "Odin HTTP client")
	raylib.SetWindowMonitor(0)
	raylib.SetTargetFPS(raylib.GetMonitorRefreshRate(0))

	LoadResources()

	ClientUI.Init()
}

Update :: proc() {
	defer free_all(context.temp_allocator)

	windowWidth = raylib.GetScreenWidth()
	windowHeight = raylib.GetScreenHeight()
	clay.SetPointerState(
		transmute(clay.Vector2)raylib.GetMousePosition(),
		raylib.IsMouseButtonDown(raylib.MouseButton.LEFT),
	)
	mouseWheelMoveV := raylib.GetMouseWheelMoveV() * 5
	// fmt.println(mouseWheelMoveV)
	clay.UpdateScrollContainers(
		true,
		transmute(clay.Vector2)mouseWheelMoveV,
		raylib.GetFrameTime(),
	)
	clay.SetLayoutDimensions({cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()})

	clay.BeginLayout()
	raylib.BeginDrawing()

	raylib.ClearBackground(raylib.Color{15, 12, 18, 255})


	if clay.UI()(
	{
		layout = {
			layoutDirection = clay.LayoutDirection.TopToBottom,
			sizing = Utils.SIZE_AUTO_GROW_XY,
		},
	},
	) {
		ClientUI.Update()
	}
	renderCommands: clay.ClayArray(clay.RenderCommand) = clay.EndLayout()
	clay_raylib_render(&renderCommands)
	raylib.EndDrawing()
}

main :: proc() {
	Init()
	for !raylib.WindowShouldClose() {
		Update()
	}
}
