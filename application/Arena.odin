package ClientUI

Arena :: struct {
	capacity: u64,
	position: u64,
	memory:   []byte,
}

ARENA_ALIGN :: size_of(^byte)

ArenaFromBuffer :: proc(backing: []byte) -> Arena {
	result: Arena
	result.capacity = cast(u64)len(backing)
	result.memory = backing
	result.position = 0
	return result
}

ArenaPush :: proc(arena: ^Arena, size: u64) -> ^byte {
	posAligned: u64 = ArenaAlignToPow2(arena.position, ARENA_ALIGN)
	arena.position = posAligned + size
	if (arena.position > arena.capacity) {
		panic("Arena allocation request size exceeded defined arena buffer size!")
	}
	return cast(^byte)&arena.memory[arena.position]
}

ArenaPushArray :: proc(arena: ^Arena, size: u64, outArray: ^[]$T) {
	rawAlloc := cast([^]T)ArenaPush(arena, size)
	outArray^ = rawAlloc[0:size]
}

ArenaPop :: proc(arena: ^Arena, size: u64) {
	size: u64 = min(size, arena.position)
	arena.position -= size
}

ArenaClear :: proc(arena: ^Arena) {
	arena.position = 0
}

ArenaFree :: proc(arena: ^Arena) {
	delete(arena.memory)
}

ArenaAlignToPow2 :: proc(position: u64, power: u64) -> u64 {
	return ((position) + ((power) - 1)) & (~((power) - 1))
}
