// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EvolutionSimCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "EvolutionSimCore",
            targets: ["EvolutionSimCore"]
        ),
    ],
    targets: [
        .target(
            name: "EvolutionSimCore"
        ),
        .testTarget(
            name: "EvolutionSimCoreTests",
            dependencies: ["EvolutionSimCore"]
        ),
    ]
)
