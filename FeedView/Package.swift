// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedView",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
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
        .package(path: "../DevPreview"),
        .package(path: "../RickMortyUI"),
        .package(path: "../DependencyContainer"),
        .package(path: "../CharacterDetailsView"),
        .package(url: "https://github.com/obadasemary/SUIRouting.git", .upToNextMajor(from: "1.0.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FeedView",
            dependencies: [
                .product(name: "UseCase", package: "UseCase"),
                .product(name: "DevPreview", package: "DevPreview"),
                .product(name: "SUIRouting", package: "SUIRouting"),
                .product(name: "RickMortyUI", package: "RickMortyUI"),
                .product(name: "DependencyContainer", package: "DependencyContainer"),
                .product(name: "CharacterDetailsView", package: "CharacterDetailsView")
            ]
        ),
        .testTarget(
            name: "FeedViewTests",
            dependencies: [
                "FeedView",
                .product(name: "UseCase", package: "UseCase")
            ]
        ),
    ]
)
