// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IPAParser",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "IPAParser",
            targets: [
                "IPAParser"
            ]
        ),
        .library(
            name: "PlistParser",
            targets: [
                "PlistParser"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coollazy/Image.git", from: "1.2.2"),
        .package(url: "https://github.com/coollazy/ZIPFoundation.git", from: "0.9.20"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
    ],
    targets: [
        .target(
            name: "IPAParser",
            dependencies: [
                .product(name: "Image", package: "Image"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "PlistParser"),
            ]
        ),
        .target(
            name: "PlistParser",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "PlistParserTests",
            dependencies: ["PlistParser"]
        ),
        .testTarget(
            name: "IPAParserTests",
            dependencies: ["IPAParser", "PlistParser"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
