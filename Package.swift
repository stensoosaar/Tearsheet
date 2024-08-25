// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tearsheet",
	platforms: [
		.macOS(.v14)
	],
    products: [
        .library(
            name: "Tearsheet",
            targets: ["Tearsheet"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/duckdb/duckdb-swift", branch: "main")
	],
    targets: [
        .target(
            name: "Tearsheet",
			dependencies: [
				.product(name: "DuckDB", package: "duckdb-swift")
			]
		),
        .testTarget(
            name: "TearsheetTests",
            dependencies: ["Tearsheet"]
        ),
    ]
)
