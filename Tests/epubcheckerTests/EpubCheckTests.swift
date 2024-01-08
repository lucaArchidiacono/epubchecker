import XCTest
@testable import epubchecker

final class epubcheckerTests: XCTestCase {

    func testValidationWithEncodingOfEpubInspectorUsingAsyncAwait() async {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				_ = try await epubCheck.validate()
			}
		} catch {
			XCTFail("\(error)")
		}
	}

	func testValidationWithJSONStringOutputUsingAsyncAwait() async {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				let output = try await epubCheck.validate(output: .json)
				XCTAssertTrue(!output.isEmpty)
			}
		} catch {
			XCTFail("\(error)")
		}
	}

    func testValidationWithEncodingOfEpubInspectorUsingAsyncAwait() {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				epubCheck.validate { result in
					switch result {
					case .success: break
					case .failure(let error):
						XCTFail("\(error)")
					}
				}
			}
		} catch {
			XCTFail("\(error)")
		}
	}

	func testValidationWithXMLStringOutputAsyncAwait() async {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				let output = try await epubCheck.validate(output: .xml)
				XCTAssertTrue(!output.isEmpty)

				let xmlData = Data(output.utf8)
				let xmlParser = XMLParser(data: xmlData)

				let parsedSuccessfully = xmlParser.parse()
				if parsedSuccessfully, let error = xmlParser.parserError {
					XCTFail("\(error)")
				}
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	func testValidationWithJSONStringOutputClosure() {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				epubCheck.validate(output: .json) { result in
					switch result {
					case .success(let output):
						XCTAssertTrue(!output.isEmpty)
					case .failure(let error):
						XCTFail("\(error)")
					}
				}
			}
		} catch {
			XCTFail("\(error)")
		}
	}
	
	func testValidationWithXMLStringOutputClosure() {
		do {
			for testBook in try getTestBooks() {
				let epubCheck = EpubCheck(testBook)
				epubCheck.validate(output: .xml) { result in
					switch result {
					case .success(let output):
						XCTAssertTrue(!output.isEmpty)

						let xmlData = Data(output.utf8)
						let xmlParser = XMLParser(data: xmlData)

						let parsedSuccessfully = xmlParser.parse()
						if parsedSuccessfully, let error = xmlParser.parserError {
							XCTFail("\(error)")
						}
					case .failure(let error):
						XCTFail("\(error)")
					}
				}
			}
		} catch {
			XCTFail("\(error)")
		}
	}

	private func getTestBooks() throws -> [URL] {
		let resourceURL = Bundle.module.resourceURL!
		return try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: [.isRegularFileKey])
	}
}
