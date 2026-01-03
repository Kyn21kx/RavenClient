package ClientUI

import clay "../third_party/clay"
import http "../third_party/odin-http"
import Utils "../utils"
import "core:strings"
import "core:time"

// 5 MB may be way too low, but it's for testing
BODY_CAPACITY :: 1024 * 1024 * 5

UIFocus :: enum {
	URLBox,
	BodyBox,
}

AppState :: struct {
	responseStatusColor:     clay.Color,
	statusCode:              http.Status,
	bodyBuffer:              strings.Builder,
	lastResponseElapsedTime: time.Duration,
	currentMethod:           http.Method,
	currentBody:             [BODY_CAPACITY]byte,
	responseBodySize:        i32,
	uiFocusState:            UIFocus,
	headerKVFocusIdx:        u32,
	isRequestInProgress:     bool,
	headers:                 http.Headers,
}

InitResponseState :: proc(responseState: ^AppState) {
	responseState.responseStatusColor = Utils.COLOR_BLACK()
	strings.builder_init_len_cap(&responseState.bodyBuffer, 0, BODY_CAPACITY)
}
