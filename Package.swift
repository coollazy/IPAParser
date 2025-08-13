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
        .package(url: "https://github.com/coollazy/ZIPFoundation.git", from: "0.9.20"),
    ],
    targets: [
        .target(
            name: "IPAParser",
            dependencies: [
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .target(name: "PlistParser"),
            ]
        ),
        .target(
            name: "PlistParser",
            dependencies: [
            ]
        ),
    ]
)
