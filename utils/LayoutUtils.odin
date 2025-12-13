package utils
import clay "../third_party/clay"


LAYOUT_CHILD_ALIGN_CENTER_ALL :: clay.ChildAlignment {
	x = clay.LayoutAlignmentX.Center,
	y = clay.LayoutAlignmentY.Center,
}

LAYOUT_CHILD_ALIGN_CENTER_X :: clay.ChildAlignment {
	x = clay.LayoutAlignmentX.Center,
	y = {},
}

LAYOUT_CHILD_ALIGN_RIGHT_X :: clay.ChildAlignment {
	x = clay.LayoutAlignmentX.Right,
	y = {},
}

LAYOUT_CHILD_ALIGN_CENTER_Y :: clay.ChildAlignment {
	x = {},
	y = clay.LayoutAlignmentY.Center,
}

SIZING_GROW_DEF :: clay.SizingAxis {
	type = clay.SizingType.Grow,
}

SIZE_AUTO_GROW_XY :: clay.Sizing {
	width  = SIZING_GROW_DEF,
	height = SIZING_GROW_DEF,
}

SizeFlexHorizontal :: proc(growFactor: f32) -> clay.Sizing {
	return {clay.SizingGrow({min = growFactor}), {}}
}

SizeFlexHorizontalMax :: proc(growFactor: f32, max: f32) -> clay.Sizing {
	return {clay.SizingGrow({min = growFactor, max = max}), {}}
}

SizeFlexVertical :: proc(growFactor: f32) -> clay.Sizing {
	return {{}, clay.SizingGrow({min = growFactor})}
}
