package Components

import clay "../third_party/clay"
import Utils "../utils"

TextBoxInfo :: struct {
	placeholderText:  string,
	placeholderColor: clay.Color,
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
