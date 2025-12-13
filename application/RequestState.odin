package ClientUI

import clay "../third_party/clay"
import http "../third_party/odin-http"
import Utils "../utils"
import "core:strings"

// 5 MB may be way too low, but it's for testing
BODY_CAPACITY :: 1024 * 1024 * 5

ResponseState :: struct {
	responseStatusColor: clay.Color,
	statusCode:          http.Status,
	bodyBuffer:          strings.Builder,
	currentMethod:       http.Method,
}

InitResponseState :: proc(responseState: ^ResponseState) {
	responseState.responseStatusColor = Utils.COLOR_BLACK()
	strings.builder_init_len_cap(&responseState.bodyBuffer, 0, BODY_CAPACITY)
}
