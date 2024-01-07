//
//  EpubCheck.swift
//
//
//  Created by Luca Archidiacono on 06.01.2024.
//

import Foundation
import OSLog

struct EpubCheck {
	/// Validation profiles supported
	enum Profile: String {
		/// The default validation profile
		case `default`
		/// Validates against the EPUB Dictionaries and Glossaries specification
		case dict
		/// Validates against the EDUPUB Profile
		case edupub
		/// Validates against the EPUB Indexes specification
		case idx
		/// Validates against the EPUB Previews specification
		case preview
	}

	/// Output profiles supported
	enum Output: String {
		/// Output an assessment XML document file
		case out
		/// Output an assessment XMP document file
		case xmp
		/// Output an assessment JSON document file
		case json

		var ext: String {
			switch self {
			case .out: return "xml"
			case .xmp: return "xmp"
			case .json: return "json"
			}
		}
	}

	private var profile: Profile
	private var fileURL: URL

	private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EpubCheck")

	private var libraryURL: URL {
		return Bundle.module.resourceURL!
			.appending(path: "epubcheck", directoryHint: .isDirectory)
			.appending(path: "epubcheck.jar", directoryHint: .notDirectory)
	}

	init(_ fileURL: URL, profile: Profile = .default) {
		self.fileURL = fileURL
		self.profile = profile
	}

	func validate() async throws -> EpubInspector {
		let destFileURL = setupDestFile(output: .json)
		let (process, stdout, stderr) = setupProcess(sourceFileURL: fileURL, destFileURL: destFileURL, output: .json)

		try? process.run()

		for try await line in stdout.fileHandleForReading.bytes.lines {
			logger.log(level: .info, "\(line)")
		}

		var error: String = ""
		for try await line in stderr.fileHandleForReading.bytes.lines {
			error += line
		}

		process.waitUntilExit()

		let data = try Data(contentsOf: destFileURL)
		let epubInspector = try JSONDecoder().decode(EpubInspector.self, from: data)
		try? FileManager.default.removeItem(at: destFileURL)
		return epubInspector
	}

	func validate(output: Output) async throws -> String {
		let destFileURL = setupDestFile(output: output)
		let (process, stdout, stderr) = setupProcess(sourceFileURL: fileURL, destFileURL: nil, output: output)

		try? process.run()

		var result: String = ""
		for try await line in stdout.fileHandleForReading.bytes.lines {
			result += line
		}

		var error: String = ""
		for try await line in stderr.fileHandleForReading.bytes.lines {
			error += line
		}

		process.waitUntilExit()

		if !error.isEmpty {
			// TODO: Luca Archidiacono - Handle error appropriately.
			throw URLError(.badServerResponse)
		} else {
			return result
		}
	}

	func validate(completion: ((Result<EpubInspector, Error>) -> Void)) {
		let destFileURL = setupDestFile(output: .json)
		let (process, stdout, stderr) = setupProcess(sourceFileURL: fileURL, destFileURL: destFileURL, output: .json)

		try? process.run()

		stdout.fileHandleForReading.readabilityHandler = { fileHandle in
			let data = fileHandle.availableData
			guard !data.isEmpty else {
				stdout.fileHandleForReading.readabilityHandler = nil
				return
			}

			if let outputString = String(data: data, encoding: .utf8) {
				logger.log(level: .info, "\(outputString)")
			}
		}

		var error: String = ""
		stderr.fileHandleForReading.readabilityHandler = { fileHandle in
			let data = fileHandle.availableData
			guard !data.isEmpty else {
				stdout.fileHandleForReading.readabilityHandler = nil
				return
			}

			if let outputString = String(data: data, encoding: .utf8) {
				logger.log(level: .error, "\(outputString)")
				error += outputString
			}
		}

		process.waitUntilExit()

		if !error.isEmpty {
			// TODO: Luca Archidiacono - Handle error appropriately.
		} else {
			do {
				let data = try Data(contentsOf: destFileURL)
				let epubInspector = try JSONDecoder().decode(EpubInspector.self, from: data)
				try? FileManager.default.removeItem(at: destFileURL)
				completion(.success(epubInspector))
			} catch {
				completion(.failure(error))
			}
		}
	}

	func validate(output: Output, completion: ((Result<String, Error>) -> Void)) {
		let (process, stdout, stderr) = setupProcess(sourceFileURL: fileURL, destFileURL: nil, output: output)

		try? process.run()

		var result: String = ""
		stdout.fileHandleForReading.readabilityHandler = { fileHandle in
			let data = fileHandle.availableData
			guard !data.isEmpty else {
				stdout.fileHandleForReading.readabilityHandler = nil
				return
			}

			if let outputString = String(data: data, encoding: .utf8) {
				result += outputString
			}
		}

		var error: String = ""
		stderr.fileHandleForReading.readabilityHandler = { fileHandle in
			let data = fileHandle.availableData
			guard !data.isEmpty else {
				stdout.fileHandleForReading.readabilityHandler = nil
				return
			}

			if let outputString = String(data: data, encoding: .utf8) {
				logger.log(level: .error, "\(outputString)")
				error += outputString
			}
		}

		process.waitUntilExit()

		if !error.isEmpty {
			// TODO: Luca Archidiacono - Handle error appropriately.
		} else {
			completion(.success(result))
		}
	}

	private func setupDestFile(output: Output) -> URL {
		return FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("\(output.ext)")
	}

	private func setupProcess(sourceFileURL: URL, destFileURL: URL?, output: Output) -> (Process, Pipe, Pipe) {
		let process = Process()
		let stdout = Pipe()
		let stderr = Pipe()

		process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
		process.arguments = [
			"java",
			"-jar",
			libraryURL.path,
			sourceFileURL.path,
			"-q", // no message on console, except errors, only in the output
			"-f",
			"--profile",
			profile.rawValue,
			"--\(output)",
			destFileURL?.path ?? "-"
		]
		process.standardOutput = stdout
		process.standardError = stderr

		return (process, stdout, stderr)
	}
}
