# OdinClient

A native HTTP client built with Odin and Raylib. Created out of frustration with non-native HTTP clients that are bloated and slow.

## Features

- Native GUI built with Clay UI and Raylib
- Support for GET, POST, DELETE, PATCH, and PUT requests
- Response viewing with status code highlighting
- Simple and fast

## Dependencies

- [Odin](https://odin-lang.org/) compiler
- [Raylib](https://www.raylib.com/) (via Odin vendor)
- [Clay UI](https://github.com/nicbarker/clay) (included in `third_party/clay`)
- [odin-http](https://github.com/laytan/odin-http) (included in `third_party/odin-http`)

## Building

```bash
odin build .
```

Run the executable:

```bash
./OdinClient.exe
```
