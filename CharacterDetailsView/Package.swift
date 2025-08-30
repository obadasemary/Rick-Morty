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
        .package(path: "../DevPreview"),
        .package(path: "../RickMortyUI"),
        .package(path: "../DependencyContainer")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CharacterDetailsView",
            dependencies: [
                .product(name: "UseCase", package: "UseCase"),
                .product(name: "DevPreview", package: "DevPreview"),
                .product(name: "RickMortyUI", package: "RickMortyUI"),
                .product(name: "DependencyContainer", package: "DependencyContainer")
            ]
        ),
        .testTarget(
            name: "CharacterDetailsViewTests",
            dependencies: ["CharacterDetailsView"]
        ),
    ]
)
