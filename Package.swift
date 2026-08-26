// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-http-coder",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "HTTP Coder",
            targets: ["HTTP Coder"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-foundations/swift-http.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-coder-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-input-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-optic-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-parser-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-serializer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-3986.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "HTTP Coder",
            dependencies: [
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "Byte Primitive", package: "swift-byte-primitives"),
                .product(name: "Coder Parser Primitives", package: "swift-coder-primitives"),
                .product(name: "Coder Primitive", package: "swift-coder-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Optic Primitives", package: "swift-optic-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(
                    name: "Parser Conversion Primitives",
                    package: "swift-parser-primitives"
                ),
                .product(name: "Parser Error Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Take Primitives", package: "swift-parser-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(
                    name: "Serializer Primitive",
                    package: "swift-serializer-primitives"
                ),
            ]
        ),
        .testTarget(
            name: "HTTP Coder Tests",
            dependencies: [
                "HTTP Coder",
                .product(name: "Byte Primitive", package: "swift-byte-primitives"),
                .product(name: "Coder Parser Primitives", package: "swift-coder-primitives"),
                .product(name: "Coder Primitive", package: "swift-coder-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "Input Buffer Primitives", package: "swift-input-primitives"),
                .product(name: "Optic Primitives", package: "swift-optic-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(
                    name: "Parser Conversion Primitives",
                    package: "swift-parser-primitives"
                ),
                .product(name: "Parser OneOf Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Skip Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Take Primitives", package: "swift-parser-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(
                    name: "Serializer Primitive",
                    package: "swift-serializer-primitives"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
