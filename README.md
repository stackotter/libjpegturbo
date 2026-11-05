# libjpegturbo

A SwiftPM package that builds [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)
from source as C targets. It does not provide a Swift API; it exposes
libjpeg-turbo's C interfaces directly to Swift, in the same spirit as the
[libpng](https://github.com/the-swift-collective/libpng) Swift package.

The libjpeg-turbo sources are tracked as a git submodule in `libjpeg-turbo/`.

## Products

| Product | Module | Description |
| --- | --- | --- |
| `libjpegturbo` / `jpeg` | `jpeg` | The classic libjpeg C API (`jpeglib.h`, `jerror.h`). |
| `turbojpeg` | `turbojpeg` | The TurboJPEG C API (`turbojpeg.h`). |

`turbojpeg` links against the `jpeg` target, so both APIs can be used from the
same executable.

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
compiling a C target. They use compiler predefined macros so that the package
works across Apple and non-Apple platforms.

All three data precisions supported by libjpeg-turbo (8-, 12-, and 16-bit) are
built.

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
   `Sources/jpeg/include/jconfig.h` and `Sources/jpeg/include/jconfigint.h`.
3. If the source lists in libjpeg-turbo's `CMakeLists.txt` changed, update the
   `sources` lists in `Package.swift`.
4. Run `swift test`.

## License

libjpeg-turbo is distributed under its own licenses. See
`libjpeg-turbo/LICENSE.md` and the per-file notices in the submodule.
