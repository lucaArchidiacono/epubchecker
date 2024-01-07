// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "epubchecker",
	platforms: [
		.macOS(.v13),
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
//		.executable(
//			name: "epubcheckerCLI",
//			targets: ["cli"]),
		.library(
			name: "epubchecker",
			targets: ["lib"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
//		.executableTarget(
//			name: "cli",
//			dependencies: ["lib"],
//			resources: [
//				.copy("../Resources")
//			]
//		),
		.target(
			name: "lib",
			dependencies: [],
			resources: [
				.copy("Resources/epubcheck"),
			]
		),
        .testTarget(
            name: "libTests",
            dependencies: ["lib"],
			resources: [
				.process("Resources")
			]
		),
    ]
)
