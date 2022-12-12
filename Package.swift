// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IPABuilder",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "IPABuilder",
            targets: ["IPABuilder"]),
    ],
    dependencies: [
        .package(name: "SwiftCLI", url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(name: "Zip", url: "https://github.com/marmelroy/Zip.git", from: "2.0.0"),
        .package(name: "MD5", url: "https://github.com/coollazy/MD5.git", from: "1.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "IPABuilder",
            dependencies: [
                .product(name: "SwiftCLI", package: "SwiftCLI"),
                .product(name: "Zip", package: "Zip"),
                .product(name: "MD5", package: "MD5"),
            ]),
        .testTarget(
            name: "IPABuilderTests",
            dependencies: ["IPABuilder"]),
    ]
)
