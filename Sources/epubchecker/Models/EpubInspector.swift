import Foundation

enum DateConversionError: Error {
	case invalidDateFormat(expected: [String], received: String)
}

// MARK: - EpubInspector
struct EpubInspector: Codable {
	let messages: [Message]
	let customMessageFileName: String?
	let checker: Checker
	let publication: Publication
	let items: [Item]
}

// MARK: - Message
struct Message: Codable {
	let id: String
	let severity: Severity
	let message: String
	let additionalLocations: Int
	let locations: [Location]
	let suggestion: String?

	enum CodingKeys: String, CodingKey {
		case id = "ID"
		case severity, message, suggestion, additionalLocations, locations
	}
}

// MARK: - Severity
enum Severity: String, Codable {
	case SUPPRESSED
	case USAGE
	case INFO
	case WARNING
	case ERROR
	case FATAL
}

// MARK: - Location
struct Location: Codable {
	let path: String
	let line: Int
	let column: Int
	let context: String?
}

// MARK: - Checker
struct Checker: Codable {
	let path, filename, checkerVersion, checkDate: String
	let elapsedTime: Int
	let nFatal, nError, nWarning, nUsage: Int
}

// MARK: - Item
struct Item: Codable {
	let id, fileName: String
	let mediaType: String?
	let compressedSize, uncompressedSize: Int
	let compressionMethod: CompressionMethod
	let checkSum: String
	let isSpineItem: Bool
	let spineIndex: Int?
	let isLinear: Bool
	let isFixedFormat: Bool?
	let isScripted: Bool
	let renditionLayout, renditionOrientation, renditionSpread: String?
	let referencedItems: [String]

	enum CodingKeys: String, CodingKey {
		case id, fileName
		case mediaType = "media_type"
		case compressedSize, uncompressedSize, compressionMethod, checkSum, isSpineItem, spineIndex, isLinear, isFixedFormat, isScripted, renditionLayout, renditionOrientation, renditionSpread, referencedItems
	}
}

enum CompressionMethod: String, Codable {
	case deflated = "Deflated"
	case stored = "Stored"
}

// MARK: - Publication
struct Publication: Codable {
	let publisher: String?
	let title: String
	let creator: [String]
	let date: Date
	let subject: [String]
	let description: String
	let rights: String?
	let identifier, language: String
	let nSpines, checkSum: Int
	let renditionLayout, renditionOrientation, renditionSpread, ePubVersion: String
	let isScripted, hasFixedFormat, isBackwardCompatible, hasAudio: Bool
	let hasVideo: Bool
	let charsCount: Int
	let embeddedFonts, refFonts: [String]
	let hasEncryption, hasSignatures: Bool
	let contributors: [String]

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
		self.title = try container.decode(String.self, forKey: .title)
		self.creator = try container.decode([String].self, forKey: .creator)
		
		let dateString = try container.decode(String.self, forKey: .date)
		let dateFormatter = DateFormatter()
		let dateFormats = [
			"yyyy-dd-MM'T'HH:mm:ssZ",
			"yyyy-MM-dd'T'HH:mm:ssZ"
		]

		var validatedDate: Date? = nil
		for dateFormat in dateFormats {
			dateFormatter.dateFormat = dateFormat

			if let date = dateFormatter.date(from: dateString) {
				validatedDate = date
				break
			}
		}

		guard let validatedDate else {
			throw DateConversionError.invalidDateFormat(expected: dateFormats, received: dateString)
		}

		self.date = validatedDate

		self.subject = try container.decode([String].self, forKey: .subject)
		self.description = try container.decode(String.self, forKey: .description)
		self.rights = try container.decodeIfPresent(String.self, forKey: .rights)
		self.identifier = try container.decode(String.self, forKey: .identifier)
		self.language = try container.decode(String.self, forKey: .language)
		self.nSpines = try container.decode(Int.self, forKey: .nSpines)
		self.checkSum = try container.decode(Int.self, forKey: .checkSum)
		self.renditionLayout = try container.decode(String.self, forKey: .renditionLayout)
		self.renditionOrientation = try container.decode(String.self, forKey: .renditionOrientation)
		self.renditionSpread = try container.decode(String.self, forKey: .renditionSpread)
		self.ePubVersion = try container.decode(String.self, forKey: .ePubVersion)
		self.isScripted = try container.decode(Bool.self, forKey: .isScripted)
		self.hasFixedFormat = try container.decode(Bool.self, forKey: .hasFixedFormat)
		self.isBackwardCompatible = try container.decode(Bool.self, forKey: .isBackwardCompatible)
		self.hasAudio = try container.decode(Bool.self, forKey: .hasAudio)
		self.hasVideo = try container.decode(Bool.self, forKey: .hasVideo)
		self.charsCount = try container.decode(Int.self, forKey: .charsCount)
		self.embeddedFonts = try container.decode([String].self, forKey: .embeddedFonts)
		self.refFonts = try container.decode([String].self, forKey: .refFonts)
		self.hasEncryption = try container.decode(Bool.self, forKey: .hasEncryption)
		self.hasSignatures = try container.decode(Bool.self, forKey: .hasSignatures)
		self.contributors = try container.decode([String].self, forKey: .contributors)
	}
}
