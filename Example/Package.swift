// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "App", targets: ["App"]),
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "IPAParser", package: "IPAParser"),
            ]
        ),
    ]
)
