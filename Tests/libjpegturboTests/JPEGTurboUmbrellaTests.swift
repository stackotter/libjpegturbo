import JPEGTurbo
import XCTest

final class JPEGTurboUmbrellaTests: XCTestCase {
  func testReexportsBothCModules() throws {
    let cinfo = jpeg_decompress_struct()
    XCTAssertEqual(
      MemoryLayout.size(ofValue: cinfo),
      MemoryLayout<jpeg_decompress_struct>.size
    )

    XCTAssertEqual(JPEG_LIB_VERSION, 62)
    XCTAssertEqual(TURBOJPEG_VERSION_NUMBER, 3002000)

    let pixelFormat: TJPF = TJPF_RGB
    XCTAssertEqual(pixelFormat.rawValue, TJPF_RGB.rawValue)
  }
}
