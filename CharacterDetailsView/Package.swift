// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CharacterDetailsView",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CharacterDetailsView",
            targets: ["CharacterDetailsView"]
        ),
    ],
    dependencies: [
        .package(path: "../UseCase"),
        .package(path: "../DependencyContainer"),
        .package(path: "../DevPreview")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CharacterDetailsView",
            dependencies: [
                .product(name: "UseCase", package: "UseCase"),
                .product(name: "DependencyContainer", package: "DependencyContainer"),
                .product(name: "DevPreview", package: "DevPreview")
            ]
        ),
        .testTarget(
            name: "CharacterDetailsViewTests",
            dependencies: ["CharacterDetailsView"]
        ),
    ]
)
