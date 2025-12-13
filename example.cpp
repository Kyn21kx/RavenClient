#include "ColorUtils.h"
#include "TextUtils.h"
#include "clay.h"
#include <cstdint>

namespace Buttons {
	
	using OnClickFunc_t = void(*)(Clay_ElementId elementId, Clay_PointerData pointerData, intptr_t userData);
	
	struct ButtonArgs {
		uint16_t fontSize = 24;
		bool active = false;
		OnClickFunc_t onClick = {};
		intptr_t callbackArgs = 0;
		Clay_Color bgIdleColor = ColorUtils::Transparent();
		Clay_Color bgHoverColor = ColorUtils::Transparent();
		Clay_Color fgIdleColor = ColorUtils::LightGray();
		Clay_Color fgHoverColor = ColorUtils::White();
		
	};
	
	inline void RawButton(Clay_String buttonText, const ButtonArgs& args) {
		CLAY({ .layout = { .padding = CLAY_PADDING_ALL(8) }, .backgroundColor = Clay_Hovered() || args.active ?  args.bgIdleColor : args.bgHoverColor}) {
	        CLAY_TEXT(buttonText, CLAY_TEXT_CONFIG(TextUtils::Default(args.fontSize, Clay_Hovered() || args.active ? ColorUtils::White() : ColorUtils::LightGray())));
	        Clay_OnHover(args.onClick, args.callbackArgs);
	    }
		
	}
	
	// TODO: Make into a struct and just pass that
	inline void HeaderButton(Clay_String buttonText, const ButtonArgs& args = {}) {
	    // Red box button with 8px of padding
	    RawButton(buttonText, args);
	}
}
