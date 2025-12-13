package ClientUI

import Components "../components"
import clay "../third_party/clay"
import http "../third_party/odin-http"
import httpclient "../third_party/odin-http/client"
import Utils "../utils"
import "base:runtime"
import "core:bytes"
import "core:fmt"
import "core:strings"
import "core:time"
import "vendor:raylib"

SIZE_KB :: 1024
SIZE_MB :: 1024 * SIZE_KB
URL_MAX_LEN :: SIZE_KB
DEFAULT_PADDING :: 16
TITLE_CONFIG: clay.TextElementConfig
SIZE_AUTO_GROW_XY: clay.Sizing
EXAMPLE_URI :: "https://example.com/api/endpoint"

builder: strings.Builder
globalCtx: runtime.Context
responseState: ResponseState
showOtherMethods: bool = false
scrollOffset: clay.Vector2 = {0, 0}
urlTextBoxInfo: Components.TextBoxInfo
requestBodyTextBoxInfo: Components.TextBoxInfo

buttonColors: [5]clay.Color

buttonNames: []string = {"GET", "POST", "DELETE", "PATCH", "PUT"}

ButtonType :: enum {
	SendRequest,
	ChangeRequestMethod,
}

Init :: proc() {
	TITLE_CONFIG = {
		fontSize  = 24,
		textColor = Utils.COLOR_WHITE(),
	}
	buttonColors = {
		Utils.COLOR_PURPLE(),
		Utils.COLOR_LIGHT_GREEN(),
		Utils.COLOR_RED(),
		Utils.COLOR_YELLOW(),
		Utils.COLOR_BRONZE(),
	}
	InitResponseState(&responseState)
	urlTextBoxInfo = Components.DefaultTextBoxInfo(URL_MAX_LEN, EXAMPLE_URI)
	urlTextBoxInfo.sizing = {
		width = clay.SizingGrow(),
		height = {type = clay.SizingType.Fit},
	}
	// URL textbox focused by default
	urlTextBoxInfo.isFocused = true
	globalCtx = runtime.default_context()
}

OnSendRequestButtonClick :: proc "c" (
	elementId: clay.ElementId,
	pointerData: clay.PointerData,
	userData: rawptr,
) {
	if (pointerData.state != clay.PointerDataInteractionState.PressedThisFrame) {
		return
	}
	context = globalCtx
	clear(&responseState.bodyBuffer.buf)

	request := httpclient.Request {
		method  = responseState.currentMethod,
		headers = {},
	}

	if responseState.currentMethod == http.Method.Post {
		buff: bytes.Buffer
		bytes.buffer_init(&buff, responseState.currentBody[:])
		request.body = buff
	}

	defer httpclient.request_destroy(&request)
	startTime: time.Time = time.now()
	res, err := httpclient.request(&request, strings.to_string(urlTextBoxInfo.textBuilder))
	responseState.lastResponseElapsedTime = time.since(startTime)
	defer httpclient.response_destroy(&res)

	if (err != nil) {
		// Communicate the error to the user
		fmt.printfln("Error when sending the request %d", err)
		return
	}

	// Update the Response box
	statusColorOpacity :: 100.0
	if (res.status >= http.Status.OK && res.status < http.Status.Multiple_Choices) {
		responseState.responseStatusColor = Utils.COLOR_GREEN(statusColorOpacity)
	} else if (res.status >= http.Status.Bad_Request) {
		responseState.responseStatusColor = Utils.COLOR_RED(statusColorOpacity)
	}

	responseState.statusCode = res.status
	body, alloc, bodyErr := httpclient.response_body(&res)
	defer httpclient.body_destroy(body, alloc)
	if (bodyErr != nil) {
		return
	}

	responseState.responseBodySize = cast(i32)len(body.(httpclient.Body_Plain))
	strings.write_string(&responseState.bodyBuffer, body.(httpclient.Body_Plain))

}

OnMethodButtonClick :: proc "c" (
	elementId: clay.ElementId,
	pointerData: clay.PointerData,
	userData: rawptr,
) {
	if (pointerData.state != clay.PointerDataInteractionState.PressedThisFrame) {
		return
	}
	context = globalCtx
	showOtherMethods = !showOtherMethods
}

ShowMethodButtons :: proc() {
	// Keep this order so we can cast the index to an actual method lol
	buttonArgs := Components.DefaultButtonArgs()
	buttonArgs.cornerRadius = 5
	for item, index in buttonColors {
		isHovered := false
		buttonArgs.bgIdleColor = buttonColors[index]
		buttonArgs.bgHoverColor = buttonColors[index]
		buttonArgs.bgHoverColor[3] = 100
		if (index == cast(int)responseState.currentMethod) {
			continue
		}
		Components.RawButton(buttonNames[index], buttonArgs, &isHovered)
		if (isHovered && raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT)) {
			responseState.currentMethod = cast(http.Method)index
			showOtherMethods = !showOtherMethods
			return
		}
	}
}

DrawTopHeader :: proc() {
	topHeaderLayout := clay.LayoutConfig {
		sizing          = Utils.SizeFlexHorizontalMax(1, cast(f32)raylib.GetScreenWidth()),
		padding         = clay.PaddingAll(DEFAULT_PADDING),
		childGap        = 48,
		childAlignment  = Utils.LAYOUT_CHILD_ALIGN_CENTER_ALL,
		layoutDirection = clay.LayoutDirection.LeftToRight,
	}

	urlBoxLayout := clay.LayoutConfig {
		layoutDirection = clay.LayoutDirection.LeftToRight,
		sizing = {width = clay.SizingGrow(), height = {type = clay.SizingType.Fit}},
	}

	sendReqButton := Components.ButtonArgs {
		fontSize     = 24,
		cornerRadius = 5,
		onHover      = OnSendRequestButtonClick,
		bgIdleColor  = Utils.COLOR_INDIGO(200),
		bgHoverColor = Utils.COLOR_INDIGO(100),
		fgIdleColor  = Utils.COLOR_LIGHT_GRAY(),
		fgHoverColor = Utils.COLOR_WHITE(),
		borderColor  = Utils.COLOR_INDIGO(200),
	}

	if clay.UI(clay.ID("TopHeader"))({layout = topHeaderLayout}) {
		changeMethodButton := sendReqButton
		changeMethodButton.bgIdleColor = buttonColors[responseState.currentMethod]
		changeMethodButton.bgHoverColor = buttonColors[responseState.currentMethod]
		changeMethodButton.borderColor = changeMethodButton.bgIdleColor
		changeMethodButton.bgHoverColor[3] = 100
		changeMethodButton.onHover = OnMethodButtonClick
		isHovered := false
		if clay.UI()({layout = {layoutDirection = clay.LayoutDirection.TopToBottom}}) {
			Components.RawButton(
				buttonNames[responseState.currentMethod],
				changeMethodButton,
				&isHovered,
			)
			if (showOtherMethods) {
				ShowMethodButtons()
			}

		}
		Components.TextBox(clay.ID("URLBox"), &urlTextBoxInfo)
		Components.HeaderButton("Send Request", &sendReqButton)
	}
}

DrawRightPanel :: proc() {
	panelElement := clay.ElementDeclaration {
		layout = {
			sizing = {width = clay.SizingGrow({min = 1}), height = clay.SizingPercent(1)},
			layoutDirection = clay.LayoutDirection.TopToBottom,
			padding = clay.PaddingAll(DEFAULT_PADDING),
			childGap = 48,
		},
	}
	statusButton := clay.ElementDeclaration {
		layout = {childAlignment = Utils.LAYOUT_CHILD_ALIGN_CENTER_ALL},
		cornerRadius = clay.CornerRadiusAll(2),
		border = {width = clay.BorderAll(2), color = responseState.responseStatusColor},
		backgroundColor = responseState.responseStatusColor,
	}


	mouseScroll := clay.Vector2{raylib.GetMouseWheelMoveV().x, raylib.GetMouseWheelMoveV().y}
	// This one doesn't work, idk why

	bodyViewLayout := clay.LayoutConfig {
		sizing = {width = clay.SizingGrow({}), height = clay.SizingPercent(1)},
	}
	bodyViewBorder := clay.BorderElementConfig {
		width = clay.BorderAll(2),
		color = Utils.COLOR_BLACK(),
	}

	// TODO: provide contextual allocator for stack memory
	str := fmt.aprintf("Response: %d", responseState.statusCode)
	elapsedStr := fmt.aprintf("Roundtrip: %v", responseState.lastResponseElapsedTime)
	sizeStr: string
	// We can probably do this in a smarter way, but I've been coding for a while now lol
	if (responseState.responseBodySize < SIZE_KB) {
		sizeStr = fmt.aprintf("Content Size: %vB", responseState.responseBodySize)
	} else if (responseState.responseBodySize < SIZE_MB) {
		sizeStr = fmt.aprintf(
			"Content Size: %vkB",
			cast(f32)responseState.responseBodySize / SIZE_KB,
		)
	} else {
		sizeStr = fmt.aprintf("Content Size: %MB", responseState.responseBodySize / SIZE_MB)

	}
	defer delete_string(elapsedStr)
	defer delete_string(str)
	defer delete_string(sizeStr)

	if clay.UI(clay.ID("RightCenterPanel"))(panelElement) {
		if clay.UI()(
		{layout = {layoutDirection = clay.LayoutDirection.LeftToRight, childGap = 12}},
		) {
			if clay.UI()(statusButton) {
				clay.TextDynamic(
					str,
					clay.TextConfig(
						Utils.TextDefault(24, Utils.COLOR_WHITE(), clay.TextAlignment.Center),
					),
				)
			}
			statusButton.backgroundColor = Utils.COLOR_GRAY()
			statusButton.border.color = Utils.COLOR_GRAY()
			if clay.UI()(statusButton) {
				clay.TextDynamic(
					elapsedStr,
					clay.TextConfig(
						Utils.TextDefault(24, Utils.COLOR_WHITE(), clay.TextAlignment.Center),
					),
				)
			}
			if clay.UI()(statusButton) {
				clay.TextDynamic(
					sizeStr,
					clay.TextConfig(
						Utils.TextDefault(24, Utils.COLOR_WHITE(), clay.TextAlignment.Center),
					),
				)
			}

		}
		if clay.UI()(
		{
			layout = bodyViewLayout,
			border = bodyViewBorder,
			clip = {vertical = true, childOffset = clay.GetScrollOffset()},
		},
		) {
			clay.TextDynamic(
				strings.to_string(responseState.bodyBuffer),
				clay.TextConfig(Utils.TextDefault(24)),
			)
		}
		// clay.Text("Yooo, from right", clay.TextConfig(TITLE_CONFIG))
	}
}

DrawLeftPanel :: proc() {
	leftPanelLayout := clay.LayoutConfig {
		layoutDirection = clay.LayoutDirection.TopToBottom,
		sizing = {width = clay.SizingFit()},
	}

	if clay.UI(clay.ID("LeftCenterPanel"))({layout = leftPanelLayout}) {
		clay.Text("Request Headers", clay.TextConfig(TITLE_CONFIG))
		clay.Text("Request Body", clay.TextConfig(TITLE_CONFIG))
	}
}

DrawUI :: proc() {
	centerPanelLayout := clay.LayoutConfig {
		padding = clay.PaddingAll(DEFAULT_PADDING),
		sizing = {width = clay.SizingPercent(1), height = clay.SizingPercent(0.7)},
		layoutDirection = clay.LayoutDirection.LeftToRight,
	}

	centerPanelElement := clay.ElementDeclaration {
		layout = centerPanelLayout,
		border = {width = clay.BorderAll(2), color = Utils.COLOR_BLACK()},
	}

	DrawTopHeader()

	if clay.UI(clay.ID("CenterPanel"))(centerPanelElement) {
		DrawLeftPanel()
		DrawRightPanel()
	}
}

Update :: proc() {
	// HandleInput()
	DrawUI()
}
