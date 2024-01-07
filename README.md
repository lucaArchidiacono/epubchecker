# EpubChecker

EpubChecker is a Swift package that wraps the EpubCheck tool, providing validation for EPUB files. It offers both synchronous and asynchronous methods to validate EPUB files and retrieve detailed inspection results.

## Features

- Supports validation against various EPUB profiles.
- Output assessment results in XML, XMP, or JSON formats.

## Usage

### Installation

Add EpubChecker as a dependency in your Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/EpubChecker.git", from: "1.0.0")
]
```

### Example Usage
```swift
import Foundation

// Import EpubChecker module
import EpubChecker

// Create an instance of EpubCheck
let epubCheck = EpubCheck(fileURL: yourEPUBFileURL)

do {
    // Asynchronous validation with detailed inspection results
    let epubInspector = try await epubCheck.validate()

    // Asynchronous validation with JSON output
    let jsonResult = try await epubCheck.validate(output: .json)
    print("Validation Result (JSON): \(jsonResult)")

} catch {
    print("Error: \(error)")
}
```

## License

EpubChecker is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
