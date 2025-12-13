package Components

import clay "../third_party/clay"
import Utils "../utils"
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
	fontSize:         u16,
	textColor:        clay.Color,
}

DefaultTextBoxInfo :: proc(capacity: int, placeholder: string) -> TextBoxInfo {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, capacity)
	return {
		placeholderColor = Utils.COLOR_WHITE(100),
		fontSize = MID_TEXT_SIZE,
		textColor = Utils.COLOR_WHITE(),
		textBuilder = builder,
		placeholderText = placeholder,
	}
}


TextHandleInput :: proc(builder: ^strings.Builder) {
	c: rune = raylib.GetCharPressed()
	if (c > 0) {
		strings.write_rune(builder, c)
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

TextBox :: proc(id: clay.ElementId, info: ^TextBoxInfo) {
	if (info.isFocused) {
		TextHandleInput(&info.textBuilder)
	}

	textBoxLayout := clay.LayoutConfig {
		layoutDirection = clay.LayoutDirection.LeftToRight,
		sizing          = info.sizing,
	}
	text: string = strings.to_string(info.textBuilder)
	if clay.UI(id)({layout = textBoxLayout}) {
		count := len(text)
		info.outIsPlaceholder = count <= 0
		// sendReqButton.disable = count <= 0
		currentUriText: string = !info.outIsPlaceholder ? text : info.placeholderText
		textColor := count > 0 ? Utils.COLOR_WHITE() : Utils.COLOR_WHITE(100)
		clay.TextDynamic(
			currentUriText,
			clay.TextConfig(Utils.TextDefault(info.fontSize, textColor)),
		)
	}

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
