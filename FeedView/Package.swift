// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedView",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FeedView",
            targets: ["FeedView"]
        ),
    ],
    dependencies: [
        .package(path: "../UseCase"),
        .package(path: "../CharacterDetailsView"),
        .package(path: "../DependencyContainer"),
        .package(path: "../DevPreview")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FeedView",
            dependencies: [
                .product(name: "UseCase", package: "UseCase"),
                .product(name: "CharacterDetailsView", package: "CharacterDetailsView"),
                .product(name: "DependencyContainer", package: "DependencyContainer"),
                .product(name: "DevPreview", package: "DevPreview")
            ]
        ),
        .testTarget(
            name: "FeedViewTests",
            dependencies: ["FeedView"]
        ),
    ]
)
