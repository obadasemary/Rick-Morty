// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickMortyRepository",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RickMortyRepository",
            targets: ["RickMortyRepository"]
        ),
    ],
    dependencies: [
        .package(path: "../RickMortyNetworkLayer"),
        .package(path: "../CoreAPI"),
        .package(path: "../UseCase")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RickMortyRepository",
            dependencies: [
                .product(name: "RickMortyNetworkLayer", package: "RickMortyNetworkLayer"),
                .product(name: "CoreAPI", package: "CoreAPI"),
                .product(name: "UseCase", package: "UseCase")
            ]
        ),
        .testTarget(
            name: "RickMortyRepositoryTests",
            dependencies: ["RickMortyRepository"]
        ),
    ]
)
