# libjpegturbo

A SwiftPM package that builds [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)
from source as C targets. It does not provide a Swift API; it exposes
libjpeg-turbo's C interfaces directly to Swift, in the same spirit as the
[libpng](https://github.com/the-swift-collective/libpng) Swift package.

The libjpeg-turbo sources are tracked as a git submodule in `libjpeg-turbo/`.

## Products

- `JPEGTurbo`: A Swift target that re-exports both `jpeg` and `turbojpeg`. Use this unless you have a good reason.
- `jpeg`: The classic libjpeg C API.
- `turbojpeg`: The TurboJPEG C API.

`turbojpeg` links to `jpeg`.

`JPEGTurbo` may house some thin Swift bindings eventually, but for now it just re-exports the `jpeg` and `turbojpeg` C modules.

## Usage

```swift
// Package.swift
dependencies: [
  .package(url: "https://github.com/the-swift-collective/libjpegturbo.git", from: "3.2.2"),
],
targets: [
  .target(
    name: "MyLibrary",
    dependencies: [
      .product(name: "jpeg", package: "libjpegturbo"),
      // Or, for the TurboJPEG API:
      // .product(name: "turbojpeg", package: "libjpegturbo"),
    ]
  ),
]
```

```swift
import jpeg
// or:
import turbojpeg
```

## Build configuration

The configuration headers that libjpeg-turbo's CMake build normally generates
(`jconfig.h`, `jconfigint.h`, `jversion.h`, and the Arm `neon-compat.h`) are
checked into `Sources/jpeg/include/`, because SwiftPM does not run CMake before
compiling a C target.

### SIMD

On 64-bit Arm, libjpeg-turbo's Neon SIMD implementation is compiled and enabled.
`Sources/jpegsimd/` contains thin wrappers that include the upstream SIMD
sources only on that architecture; on other architectures those translation
units are empty and the scalar C implementation is used.

The x86/x86-64 SIMD implementations are written in NASM, which SwiftPM cannot
assemble, so those architectures currently build without SIMD.

### TurboJPEG image I/O

TurboJPEG's `tj3LoadImage*` and `tj3SaveImage*` functions can read and write
BMP, PNG, and PPM files. The package builds libjpeg-turbo's bundled libspng and
zlib sources to support PNG, matching libjpeg-turbo's own CMake build.

## Updating libjpeg-turbo

1. Update the `libjpeg-turbo` submodule.
2. Update the version macros and build number in
   `Sources/jpeg/include/jconfig.h` and `Sources/jpeg/include/jconfigint.h`. If
   you end up entirely regenerating the config files, remember to wrap the value
   of `LIBJPEG_TURBO_VERSION` in double quotes to avoid #1.
3. If the source lists in libjpeg-turbo's `CMakeLists.txt` changed, update the
   `sources` lists in `Package.swift`.
4. Run `swift test`.

## License

libjpeg-turbo is distributed under its own licenses. See
`libjpeg-turbo/LICENSE.md` and the per-file notices in the submodule.
