// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IPABuilder",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "IPABuilder",
            targets: ["IPABuilder"]
        ),
        .library(
            name: "PlistBuilder",
            targets: [
                "PlistBuilder"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(url: "https://github.com/coollazy/ZIPFoundation.git", from: "0.9.20"),
        .package(url: "https://github.com/coollazy/MD5.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "IPABuilder",
            dependencies: [
                .product(name: "SwiftCLI", package: "SwiftCLI"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "MD5", package: "MD5"),
            ]
        ),
        .target(
            name: "PlistBuilder",
            dependencies: [
            ]
        ),
    ]
)
