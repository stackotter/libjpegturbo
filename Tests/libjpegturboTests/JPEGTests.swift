import jpeg
import XCTest

final class JPEGTests: XCTestCase {
  func testVersionMacroIsSwiftFriendly() throws {
    let version: String = LIBJPEG_TURBO_VERSION
    XCTAssertEqual(version, "3.2.2")
  }

  func testCanCreateAndDestroyDecompressor() throws {
    var errorManager = jpeg_error_mgr()
    var cinfo = jpeg_decompress_struct()

    cinfo.err = withUnsafeMutablePointer(to: &errorManager) { errorManager in
      jpeg_std_error(errorManager)
    }

    jpeg_CreateDecompress(
      &cinfo,
      JPEG_LIB_VERSION,
      MemoryLayout<jpeg_decompress_struct>.size
    )
    jpeg_destroy_decompress(&cinfo)
  }

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

    var jpegBuffer: UnsafeMutablePointer<UInt8>?
    var jpegSize: CUnsignedLong = 0

    var compressErrorManager = jpeg_error_mgr()
    var compressor = jpeg_compress_struct()
    compressor.err = withUnsafeMutablePointer(to: &compressErrorManager) {
      jpeg_std_error($0)
    }

    jpeg_CreateCompress(
      &compressor,
      JPEG_LIB_VERSION,
      MemoryLayout<jpeg_compress_struct>.size
    )
    jpeg_mem_dest(&compressor, &jpegBuffer, &jpegSize)

    compressor.image_width = UInt32(width)
    compressor.image_height = UInt32(height)
    compressor.input_components = Int32(components)
    compressor.in_color_space = JCS_RGB

    jpeg_set_defaults(&compressor)
    jpeg_set_quality(&compressor, 90, 1)
    jpeg_start_compress(&compressor, 1)

    while compressor.next_scanline < compressor.image_height {
      let offset = Int(compressor.next_scanline) * width * components
      pixels.withUnsafeMutableBufferPointer { buffer in
        var row: UnsafeMutablePointer<UInt8>? = buffer.baseAddress!.advanced(by: offset)
        _ = jpeg_write_scanlines(&compressor, &row, 1)
      }
    }

    jpeg_finish_compress(&compressor)
    jpeg_destroy_compress(&compressor)

    guard let jpegBuffer else {
      return XCTFail("libjpeg did not produce an output buffer")
    }
    defer { free(jpegBuffer) }

    var decompressErrorManager = jpeg_error_mgr()
    var decompressor = jpeg_decompress_struct()
    decompressor.err = withUnsafeMutablePointer(to: &decompressErrorManager) {
      jpeg_std_error($0)
    }

    jpeg_CreateDecompress(
      &decompressor,
      JPEG_LIB_VERSION,
      MemoryLayout<jpeg_decompress_struct>.size
    )
    jpeg_mem_src(&decompressor, jpegBuffer, jpegSize)
    XCTAssertEqual(jpeg_read_header(&decompressor, 1), JPEG_HEADER_OK)
    XCTAssertEqual(decompressor.image_width, UInt32(width))
    XCTAssertEqual(decompressor.image_height, UInt32(height))

    decompressor.out_color_space = JCS_RGB
    jpeg_start_decompress(&decompressor)

    var decoded = [UInt8](
      repeating: 0,
      count: width * height * Int(decompressor.output_components)
    )
    while decompressor.output_scanline < decompressor.output_height {
      let offset =
        Int(decompressor.output_scanline) * width * Int(decompressor.output_components)
      decoded.withUnsafeMutableBufferPointer { buffer in
        var row: UnsafeMutablePointer<UInt8>? = buffer.baseAddress!.advanced(by: offset)
        _ = jpeg_read_scanlines(&decompressor, &row, 1)
      }
    }

    jpeg_finish_decompress(&decompressor)
    jpeg_destroy_decompress(&decompressor)

    XCTAssertEqual(decoded.count, pixels.count)
  }
}
