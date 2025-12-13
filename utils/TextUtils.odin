package utils
import clay "../third_party/clay"

TextDefault :: proc(
	fontSize: u16,
	color: clay.Color = {255, 255, 255, 255},
	alignment: clay.TextAlignment = clay.TextAlignment.Left,
) -> clay.TextElementConfig {
	return {
		textColor = color,
		fontId = 0,
		fontSize = fontSize,
		textAlignment = alignment,
		wrapMode = clay.TextWrapMode.Words,
	}
}
