import turbojpeg
import XCTest

final class TurboJPEGTests: XCTestCase {
  func testCompressAndDecompressRoundTrip() throws {
    let width = 16
    let height = 16
    let components = 3

    var pixels = [UInt8](repeating: 0, count: width * height * components)
    for y in 0..<height {
      for x in 0..<width {
        let offset = (y * width + x) * components
        pixels[offset] = UInt8(x * 16)
        pixels[offset + 1] = UInt8(y * 16)
        pixels[offset + 2] = UInt8((x + y) * 8)
      }
    }

    guard let compressor = tj3InitVersion(Int32(TJINIT_COMPRESS.rawValue), TURBOJPEG_VERSION_NUMBER) else {
      return XCTFail("Could not create TurboJPEG compressor")
    }
    defer { tj3Destroy(compressor) }

    XCTAssertEqual(tj3Set(compressor, Int32(TJPARAM_QUALITY.rawValue), 90), 0)
    XCTAssertEqual(
      tj3Set(compressor, Int32(TJPARAM_SUBSAMP.rawValue), Int32(TJSAMP_420.rawValue)),
      0
    )

    var jpegBuffer: UnsafeMutablePointer<UInt8>?
    var jpegSize = 0
    let compressionResult = pixels.withUnsafeBufferPointer { buffer in
      tj3Compress8(
        compressor,
        buffer.baseAddress,
        Int32(width),
        Int32(width * components),
        Int32(height),
        Int32(TJPF_RGB.rawValue),
        &jpegBuffer,
        &jpegSize
      )
    }
    XCTAssertEqual(compressionResult, 0)

    guard let jpegBuffer else {
      return XCTFail("TurboJPEG did not produce an output buffer")
    }
    defer { tj3Free(jpegBuffer) }

    guard let decompressor = tj3InitVersion(Int32(TJINIT_DECOMPRESS.rawValue), TURBOJPEG_VERSION_NUMBER) else {
      return XCTFail("Could not create TurboJPEG decompressor")
    }
    defer { tj3Destroy(decompressor) }

    var decoded = [UInt8](repeating: 0, count: width * height * components)
    let decompressionResult = decoded.withUnsafeMutableBufferPointer { buffer in
      tj3Decompress8(
        decompressor,
        jpegBuffer,
        jpegSize,
        buffer.baseAddress,
        Int32(width * components),
        Int32(TJPF_RGB.rawValue)
      )
    }
    XCTAssertEqual(decompressionResult, 0)
  }
}
