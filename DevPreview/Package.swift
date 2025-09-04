// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevPreview",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DevPreview",
            targets: ["DevPreview"]
        ),
    ],
    dependencies: [
        .package(path: "../DependencyContainer"),
        .package(path: "../RickMortyNetworkLayer"),
        .package(path: "../RickMortyRepository"),
        .package(path: "../CoreAPI"),
        .package(path: "../UseCase")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DevPreview",
            dependencies: [
                .product(name: "DependencyContainer", package: "DependencyContainer"),
                .product(name: "RickMortyRepository", package: "RickMortyRepository"),
                .product(name: "RickMortyNetworkLayer", package: "RickMortyNetworkLayer"),
                .product(name: "CoreAPI", package: "CoreAPI"),
                .product(name: "UseCase", package: "UseCase")
            ]
        ),
        .testTarget(
            name: "DevPreviewTests",
            dependencies: ["DevPreview"]
        ),
    ]
)
