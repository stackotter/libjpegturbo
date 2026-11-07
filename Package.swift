// swift-tools-version: 5.9
//
// This package builds libjpeg-turbo as SwiftPM C targets.  It intentionally
// does not provide any Swift API of its own; consumers import the C module and
// use libjpeg's normal C interface.

import PackageDescription

let package = Package(
  name: "libjpegturbo",
  products: [
    .library(
      name: "JPEGTurbo",
      targets: ["JPEGTurbo"]
    ),
    .library(
      name: "jpeg",
      targets: ["jpeg"]
    ),
    .library(
      name: "turbojpeg",
      targets: ["turbojpeg"]
    ),
  ],
  targets: [
    // A combined C module exposing both libjpeg and TurboJPEG.  Swift 6.1's
    // symbol graph generation crashes when a Swift module re-exports two
    // separate Clang modules, so the convenience `JPEGTurbo` module re-exports
    // this single combined module instead.
    .target(
      name: "JPEGTurboC",
      dependencies: [
        "jpeg",
        "turbojpeg",
      ],
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("../../Sources/jpeg/include")
      ]
    ),
    .target(
      name: "JPEGTurbo",
      dependencies: [
        "JPEGTurboC"
      ]
    ),
    // The 64-bit Arm Neon implementation of libjpeg-turbo's SIMD extensions.
    // The wrapper sources in Sources/jpegsimd are empty on other
    // architectures, where the scalar C implementation is used instead.
    .target(
      name: "jpegsimd",
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("../../Sources/jpeg/include"),
        .headerSearchPath("../../libjpeg-turbo/src"),
        .headerSearchPath("../../libjpeg-turbo/simd"),
        .headerSearchPath("../../libjpeg-turbo/simd/arm"),
      ]
    ),
    // The libjpeg C API.  An explicit source list is used because
    // src/wrapper contains the supported entry points for files that are
    // compiled once per data precision.
    .target(
      name: "jpeg",
      dependencies: [
        .target(name: "jpegsimd")
      ],
      path: ".",
      sources: [
        "libjpeg-turbo/src/jaricom.c",
        "libjpeg-turbo/src/jcapimin.c",
        "libjpeg-turbo/src/jcarith.c",
        "libjpeg-turbo/src/jchuff.c",
        "libjpeg-turbo/src/jcicc.c",
        "libjpeg-turbo/src/jcinit.c",
        "libjpeg-turbo/src/jclhuff.c",
        "libjpeg-turbo/src/jcmarker.c",
        "libjpeg-turbo/src/jcmaster.c",
        "libjpeg-turbo/src/jcomapi.c",
        "libjpeg-turbo/src/jcparam.c",
        "libjpeg-turbo/src/jcphuff.c",
        "libjpeg-turbo/src/jctrans.c",
        "libjpeg-turbo/src/jdapimin.c",
        "libjpeg-turbo/src/jdarith.c",
        "libjpeg-turbo/src/jdatadst.c",
        "libjpeg-turbo/src/jdatasrc.c",
        "libjpeg-turbo/src/jdhuff.c",
        "libjpeg-turbo/src/jdicc.c",
        "libjpeg-turbo/src/jdinput.c",
        "libjpeg-turbo/src/jdlhuff.c",
        "libjpeg-turbo/src/jdmarker.c",
        "libjpeg-turbo/src/jdmaster.c",
        "libjpeg-turbo/src/jdphuff.c",
        "libjpeg-turbo/src/jdtrans.c",
        "libjpeg-turbo/src/jerror.c",
        "libjpeg-turbo/src/jfdctflt.c",
        "libjpeg-turbo/src/jmemmgr.c",
        "libjpeg-turbo/src/jmemnobs.c",
        "libjpeg-turbo/src/jpeg_nbits.c",
        "libjpeg-turbo/src/wrapper/jcapistd-8.c",
        "libjpeg-turbo/src/wrapper/jcapistd-12.c",
        "libjpeg-turbo/src/wrapper/jcapistd-16.c",
        "libjpeg-turbo/src/wrapper/jccoefct-8.c",
        "libjpeg-turbo/src/wrapper/jccoefct-12.c",
        "libjpeg-turbo/src/wrapper/jccolor-8.c",
        "libjpeg-turbo/src/wrapper/jccolor-12.c",
        "libjpeg-turbo/src/wrapper/jccolor-16.c",
        "libjpeg-turbo/src/wrapper/jcdctmgr-8.c",
        "libjpeg-turbo/src/wrapper/jcdctmgr-12.c",
        "libjpeg-turbo/src/wrapper/jcdiffct-8.c",
        "libjpeg-turbo/src/wrapper/jcdiffct-12.c",
        "libjpeg-turbo/src/wrapper/jcdiffct-16.c",
        "libjpeg-turbo/src/wrapper/jclossls-8.c",
        "libjpeg-turbo/src/wrapper/jclossls-12.c",
        "libjpeg-turbo/src/wrapper/jclossls-16.c",
        "libjpeg-turbo/src/wrapper/jcmainct-8.c",
        "libjpeg-turbo/src/wrapper/jcmainct-12.c",
        "libjpeg-turbo/src/wrapper/jcmainct-16.c",
        "libjpeg-turbo/src/wrapper/jcprepct-8.c",
        "libjpeg-turbo/src/wrapper/jcprepct-12.c",
        "libjpeg-turbo/src/wrapper/jcprepct-16.c",
        "libjpeg-turbo/src/wrapper/jcsample-8.c",
        "libjpeg-turbo/src/wrapper/jcsample-12.c",
        "libjpeg-turbo/src/wrapper/jcsample-16.c",
        "libjpeg-turbo/src/wrapper/jdapistd-8.c",
        "libjpeg-turbo/src/wrapper/jdapistd-12.c",
        "libjpeg-turbo/src/wrapper/jdapistd-16.c",
        "libjpeg-turbo/src/wrapper/jdcoefct-8.c",
        "libjpeg-turbo/src/wrapper/jdcoefct-12.c",
        "libjpeg-turbo/src/wrapper/jdcolor-8.c",
        "libjpeg-turbo/src/wrapper/jdcolor-12.c",
        "libjpeg-turbo/src/wrapper/jdcolor-16.c",
        "libjpeg-turbo/src/wrapper/jddctmgr-8.c",
        "libjpeg-turbo/src/wrapper/jddctmgr-12.c",
        "libjpeg-turbo/src/wrapper/jddiffct-8.c",
        "libjpeg-turbo/src/wrapper/jddiffct-12.c",
        "libjpeg-turbo/src/wrapper/jddiffct-16.c",
        "libjpeg-turbo/src/wrapper/jdlossls-8.c",
        "libjpeg-turbo/src/wrapper/jdlossls-12.c",
        "libjpeg-turbo/src/wrapper/jdlossls-16.c",
        "libjpeg-turbo/src/wrapper/jdmainct-8.c",
        "libjpeg-turbo/src/wrapper/jdmainct-12.c",
        "libjpeg-turbo/src/wrapper/jdmainct-16.c",
        "libjpeg-turbo/src/wrapper/jdmerge-8.c",
        "libjpeg-turbo/src/wrapper/jdmerge-12.c",
        "libjpeg-turbo/src/wrapper/jdpostct-8.c",
        "libjpeg-turbo/src/wrapper/jdpostct-12.c",
        "libjpeg-turbo/src/wrapper/jdpostct-16.c",
        "libjpeg-turbo/src/wrapper/jdsample-8.c",
        "libjpeg-turbo/src/wrapper/jdsample-12.c",
        "libjpeg-turbo/src/wrapper/jdsample-16.c",
        "libjpeg-turbo/src/wrapper/jfdctfst-8.c",
        "libjpeg-turbo/src/wrapper/jfdctfst-12.c",
        "libjpeg-turbo/src/wrapper/jfdctint-8.c",
        "libjpeg-turbo/src/wrapper/jfdctint-12.c",
        "libjpeg-turbo/src/wrapper/jidctflt-8.c",
        "libjpeg-turbo/src/wrapper/jidctflt-12.c",
        "libjpeg-turbo/src/wrapper/jidctfst-8.c",
        "libjpeg-turbo/src/wrapper/jidctfst-12.c",
        "libjpeg-turbo/src/wrapper/jidctint-8.c",
        "libjpeg-turbo/src/wrapper/jidctint-12.c",
        "libjpeg-turbo/src/wrapper/jidctred-8.c",
        "libjpeg-turbo/src/wrapper/jidctred-12.c",
        "libjpeg-turbo/src/wrapper/jquant1-8.c",
        "libjpeg-turbo/src/wrapper/jquant1-12.c",
        "libjpeg-turbo/src/wrapper/jquant2-8.c",
        "libjpeg-turbo/src/wrapper/jquant2-12.c",
        "libjpeg-turbo/src/wrapper/jutils-8.c",
        "libjpeg-turbo/src/wrapper/jutils-12.c",
        "libjpeg-turbo/src/wrapper/jutils-16.c",
      ],
      publicHeadersPath: "Sources/jpeg/include",
      cSettings: [
        .headerSearchPath("Sources/jpeg/include")
      ]
    ),
    // The TurboJPEG C API.  It is a separate library in libjpeg-turbo and
    // links against the core libjpeg target above.
    .target(
      name: "turbojpeg",
      dependencies: [
        .target(name: "jpeg")
      ],
      path: ".",
      sources: [
        "libjpeg-turbo/src/jdatadst-tj.c",
        "libjpeg-turbo/src/jdatasrc-tj.c",
        "libjpeg-turbo/src/rdbmp.c",
        "libjpeg-turbo/src/transupp.c",
        "libjpeg-turbo/src/turbojpeg.c",
        "libjpeg-turbo/src/wrbmp.c",
        "libjpeg-turbo/src/wrapper/rdpng-8.c",
        "libjpeg-turbo/src/wrapper/rdpng-12.c",
        "libjpeg-turbo/src/wrapper/rdpng-16.c",
        "libjpeg-turbo/src/wrapper/rdppm-8.c",
        "libjpeg-turbo/src/wrapper/rdppm-12.c",
        "libjpeg-turbo/src/wrapper/rdppm-16.c",
        "libjpeg-turbo/src/wrapper/wrpng-8.c",
        "libjpeg-turbo/src/wrapper/wrpng-12.c",
        "libjpeg-turbo/src/wrapper/wrpng-16.c",
        "libjpeg-turbo/src/wrapper/wrppm-8.c",
        "libjpeg-turbo/src/wrapper/wrppm-12.c",
        "libjpeg-turbo/src/wrapper/wrppm-16.c",
        // libjpeg-turbo's bundled libspng and zlib, used by TurboJPEG's
        // image loading and saving API.
        "libjpeg-turbo/src/spng/spng.c",
        "libjpeg-turbo/src/spng/zlib/adler32.c",
        "libjpeg-turbo/src/spng/zlib/compress.c",
        "libjpeg-turbo/src/spng/zlib/crc32.c",
        "libjpeg-turbo/src/spng/zlib/deflate.c",
        "libjpeg-turbo/src/spng/zlib/inffast.c",
        "libjpeg-turbo/src/spng/zlib/inflate.c",
        "libjpeg-turbo/src/spng/zlib/inftrees.c",
        "libjpeg-turbo/src/spng/zlib/trees.c",
        "libjpeg-turbo/src/spng/zlib/zutil.c",
      ],
      publicHeadersPath: "Sources/turbojpeg/include",
      cSettings: [
        .define("BMP_SUPPORTED", to: "1"),
        .define("PNG_SUPPORTED", to: "1"),
        .define("PPM_SUPPORTED", to: "1"),
        .define("SPNG_STATIC", to: "1"),
        .define("Z_PREFIX", to: "1"),
        .headerSearchPath("Sources/jpeg/include"),
        .headerSearchPath("Sources/turbojpeg/include"),
        .headerSearchPath("libjpeg-turbo/src"),
        .headerSearchPath("libjpeg-turbo/src/spng"),
        .headerSearchPath("libjpeg-turbo/src/spng/zlib"),
      ]
    ),
    .testTarget(
      name: "libjpegturboTests",
      dependencies: [
        .target(name: "jpeg"),
        .target(name: "turbojpeg"),
        .target(name: "JPEGTurbo"),
      ]
    ),
  ]
)
