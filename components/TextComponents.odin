package Components

import clay "../third_party/clay"
import Utils "../utils"
import "core:fmt"
import "core:math"
import "core:strings"
import "vendor:raylib"

MID_TEXT_SIZE :: 24

TextBoxInfo :: struct {
	placeholderText:  string,
	placeholderColor: clay.Color,
	sizing:           clay.Sizing,
	textBuilder:      strings.Builder,
	outIsPlaceholder: bool,
	isFocused:        bool,
	outWasClicked:    bool,
	fontSize:         u16,
	textColor:        clay.Color,
	borderWidth:      u16,
	borderColor:      clay.Color,
	cursorColor:      clay.Color,
	indentOnNewLine:  bool,
}

DefaultTextBoxInfo :: proc(capacity: int, placeholder: string) -> TextBoxInfo {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, capacity)
	return {
		placeholderColor = Utils.COLOR_WHITE(100),
		fontSize = MID_TEXT_SIZE,
		textColor = Utils.COLOR_WHITE(),
		cursorColor = Utils.COLOR_WHITE(),
		textBuilder = builder,
		placeholderText = placeholder,
	}
}

DefaultTextBoxInfoWithBuffer :: proc(backing: []byte, placeholder: string) -> TextBoxInfo {
	return {
		placeholderColor = Utils.COLOR_WHITE(100),
		fontSize = MID_TEXT_SIZE,
		textColor = Utils.COLOR_WHITE(),
		cursorColor = Utils.COLOR_WHITE(),
		textBuilder = strings.builder_from_bytes(backing),
		placeholderText = placeholder,
	}
}


TextHandleInput :: proc(builder: ^strings.Builder, indentOnNewLine: bool) {
	c: rune = raylib.GetCharPressed()
	if (c > 0) {
		strings.write_rune(builder, c)
	}
	if (raylib.IsKeyPressed(raylib.KeyboardKey.ENTER)) {
		strings.write_rune(builder, '\n')
		if (indentOnNewLine) {
			strings.write_rune(builder, '\t')
		}
	}

	if (raylib.IsKeyPressed(raylib.KeyboardKey.TAB)) {
		strings.write_rune(builder, '\t')
	}

	isCtrlPressed: bool =
		(raylib.IsKeyDown(raylib.KeyboardKey.LEFT_CONTROL) ||
			raylib.IsKeyDown(raylib.KeyboardKey.RIGHT_CONTROL))

	pasted: bool = isCtrlPressed && raylib.IsKeyPressed(raylib.KeyboardKey.V)

	if (pasted) {
		// Attempt to read the clipboard
		clipboardCStr := raylib.GetClipboardText()
		if (clipboardCStr == nil) {
			return
		}
		strings.write_string(builder, string(clipboardCStr))
	}

	if (raylib.IsKeyPressed(raylib.KeyboardKey.BACKSPACE) ||
		   raylib.IsKeyPressedRepeat(raylib.KeyboardKey.BACKSPACE)) {
		strings.pop_rune(builder)
	}
}

DrawCursorTextBox :: proc(elementData: clay.ElementData, info: ^TextBoxInfo) {
	if (!elementData.found || math.mod_f64(raylib.GetTime(), 1.0) < 0.5) {
		return
	}
	textCStr: cstring = strings.to_cstring(&info.textBuilder)
	textScale := raylib.MeasureTextEx(Utils.g_fonts[0], textCStr, cast(f32)info.fontSize, 0)
	factor: f32 = len(textCStr) > 0 ? 1.0 : 0.0
	raylib.DrawRectangle(
		cast(i32)(elementData.boundingBox.x + textScale.x),
		cast(i32)(elementData.boundingBox.y + textScale.y - (cast(f32)info.fontSize * factor)),
		10,
		cast(i32)info.fontSize,
		{
			u8(info.cursorColor.r),
			u8(info.cursorColor.g),
			u8(info.cursorColor.b),
			u8(info.cursorColor.a),
		},
	)
}

TextBox :: proc(id: clay.ElementId, info: ^TextBoxInfo) {
	if (info.isFocused) {
		TextHandleInput(&info.textBuilder, info.indentOnNewLine)
		currElementData: clay.ElementData = clay.GetElementData(id)
		DrawCursorTextBox(currElementData, info)
	}
	info.outWasClicked = false

	textBoxLayout := clay.LayoutConfig {
		layoutDirection = clay.LayoutDirection.LeftToRight,
		sizing          = info.sizing,
	}
	text: string = strings.to_string(info.textBuilder)
	textContainerId: clay.ElementId
	if clay.UI(id)(
	{
		layout = textBoxLayout,
		border = {width = clay.BorderAll(info.borderWidth), color = info.borderColor},
	},
	) {
		if (clay.Hovered() && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT)) {
			info.outWasClicked = true
		}
		count := len(text)
		info.outIsPlaceholder = count <= 0
		currentText: string = !info.outIsPlaceholder ? text : info.placeholderText
		textColor := count > 0 ? Utils.COLOR_WHITE() : Utils.COLOR_WHITE(100)
		textContainerId = clay.ID_LOCAL("_container")
		if (clay.UI(textContainerId)({layout = {sizing = {width = clay.SizingFit()}}})) {
			clay.TextDynamic(
				currentText,
				clay.TextConfig(Utils.TextDefault(info.fontSize, textColor)),
			)
		}
	}
	// fmt.println(currElementData.boundingBox)
	// currElementData.boundingBox

}

OnClickFunc_t :: proc "c" (
	element_id: clay.ElementId,
	pointer_data: clay.PointerData,
	user_data: rawptr,
)

ButtonArgs :: struct {
	fontSize:     u16,
	cornerRadius: f32,
	disable:      bool,
	active:       bool,
	onHover:      OnClickFunc_t, // can be nil
	callbackArgs: rawptr,
	bgIdleColor:  clay.Color,
	bgHoverColor: clay.Color,
	fgIdleColor:  clay.Color,
	fgHoverColor: clay.Color,
	borderColor:  clay.Color,
}


// Constructor that returns the defaults similar to the C++ initializer values.
DefaultButtonArgs :: proc() -> ButtonArgs {
	return ButtonArgs {
		fontSize = 24,
		active = false,
		disable = false,
		onHover = nil,
		callbackArgs = nil,
		bgIdleColor = Utils.COLOR_TRANSPARENT,
		bgHoverColor = Utils.COLOR_TRANSPARENT,
		fgIdleColor = Utils.COLOR_LIGHT_GRAY(),
		fgHoverColor = Utils.COLOR_WHITE(),
	}
}

RawButton :: proc(buttonText: string, args: ButtonArgs, outIsHovered: ^bool = nil) {
	hovered := clay.Hovered() // assumed existing helper returning bool
	active := args.active

	// decide colors based on hover/active (same choice as original)
	bg := args.bgIdleColor
	fg := args.fgIdleColor

	buttonLayout := clay.LayoutConfig {
		padding = clay.PaddingAll(args.fontSize),
		sizing = {width = {type = clay.SizingType.Grow}, height = {type = clay.SizingType.Fit}},
		childAlignment = Utils.LAYOUT_CHILD_ALIGN_CENTER_ALL,
	}

	buttonBorder := clay.BorderWidth {
		left            = 2,
		right           = 2,
		top             = 2,
		bottom          = 2,
		betweenChildren = 0,
	}

	if clay.UI(clay.ID(buttonText))(
	{
		border = {color = args.borderColor, width = buttonBorder},
		cornerRadius = clay.CornerRadiusAll(args.cornerRadius),
		layout = buttonLayout,
		// Awful double ternary
		backgroundColor = args.disable ? Utils.COLOR_GRAY() : clay.Hovered() || args.active ? args.bgHoverColor : args.bgIdleColor,
	},
	) {
		if (outIsHovered != nil) {
			outIsHovered^ = clay.Hovered()
		}
		buttonColor: clay.Color = Utils.COLOR_LIGHT_GRAY()
		if (!args.disable) {
			buttonColor = clay.Hovered() || active ? Utils.COLOR_WHITE() : Utils.COLOR_LIGHT_GRAY()
		}
		clay.TextDynamic(
			buttonText,
			clay.TextConfig(Utils.TextDefault(args.fontSize, buttonColor)),
		)
		if (args.disable) {
			return
		}
		clay.OnHover(args.onHover, args.callbackArgs)
	}
}

// HeaderButton: thin wrapper around RawButton, same defaults as in C++.
HeaderButton :: proc(buttonText: string, args: ^ButtonArgs = nil) {
	if args == nil {
		defaultButton := DefaultButtonArgs()
		RawButton(buttonText, defaultButton)
		return
	}
	RawButton(buttonText, args^)
}
