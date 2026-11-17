// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-http-router",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "HTTP",
            targets: ["HTTP"]
        ),
        .library(
            name: "HTTP Router",
            targets: ["HTTP Router"]
        ),
        .library(
            name: "HTTP Reply",
            targets: ["HTTP Reply"]
        ),
        .library(
            name: "HTTP Router Foundation Integration",
            targets: ["HTTP Router Foundation Integration"]
        ),
    ],
    traits: [
        .trait(name: "Foundation", description: "Codable JSON bodies through swift-json's Foundation integration")
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-checkpoint.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Checkpoint", "Optic", "Skip", "Byte", "Operation", "Map"]),
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-operation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-interface.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6265.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6750.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-9110.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-json.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "HTTP",
            dependencies: [
                .product(name: "RFC 9110", package: "swift-rfc-9110")
            ]
        ),
        .target(
            name: "HTTP Router",
            dependencies: [
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Coder", package: "swift-coder"),
                .target(name: "HTTP"),
                .product(name: "Operation", package: "swift-operation"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 6265", package: "swift-rfc-6265"),
                .product(name: "RFC 6750", package: "swift-rfc-6750"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "Serializer", package: "swift-serializer"),
            ]
        ),
        .target(
            name: "HTTP Router Foundation Integration",
            dependencies: [
                .target(name: "HTTP Router"),
                .target(name: "HTTP"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "JSON", package: "swift-json", condition: .when(traits: ["Foundation"])),
                .product(
                    name: "JSON Foundation Integration",
                    package: "swift-json",
                    condition: .when(traits: ["Foundation"])
                ),
            ]
        ),
        .target(
            name: "HTTP Reply",
            dependencies: [
                .target(name: "HTTP Router"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "HTTP"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "Serializer", package: "swift-serializer"),
            ]
        ),
        .testTarget(
            name: "HTTP Router Tests",
            dependencies: [
                .product(name: "Parser", package: "swift-parser"),
                .target(name: "HTTP Router"),
                .target(name: "HTTP Router Foundation Integration", condition: .when(traits: ["Foundation"])),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "HTTP"),
                .product(name: "Operation", package: "swift-operation"),
                .product(name: "Optic", package: "swift-optic"),
                .product(name: "Prism Macro", package: "swift-optic"),
                .product(name: "Case Macro", package: "swift-optic"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "RFC 6265", package: "swift-rfc-6265"),
                .product(name: "RFC 6750", package: "swift-rfc-6750"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Interface Macro", package: "swift-interface"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "HTTP Reply Tests",
            dependencies: [
                .target(name: "HTTP Reply"),
                .target(name: "HTTP Router"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "HTTP"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
