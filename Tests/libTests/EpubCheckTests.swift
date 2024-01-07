import XCTest
@testable import lib

final class epubcheckerTests: XCTestCase {

    func testExample() async throws {
		let testBook = try getTestBooks()[2]
		print(testBook)

		let epubCheck = EpubCheck(testBook)
		let result = try await epubCheck.validate(output: .json)
		print(result)
	}

	private func getTestBooks() throws -> [URL] {
		let resourceURL = Bundle.module.resourceURL!
		return try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.isRegularFileKey])
	}
}
