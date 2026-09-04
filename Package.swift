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
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-signature-derivation.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-operation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-compositions/swift-client.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-compositions/swift-http.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-9110.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-3986.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-coder.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-optic.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-optic-coder.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-prism-derivation.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "HTTP Coder",
            dependencies: [
                .product(name: "Operation", package: "swift-operation"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Cursor Standard Library Integration", package: "swift-cursor"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Optic", package: "swift-optic"),
                .product(name: "Optic Coder", package: "swift-optic-coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
            ]
        ),
        .testTarget(
            name: "HTTP Coder Tests",
            dependencies: [
                "HTTP Coder",
                .product(name: "Operation", package: "swift-operation"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "RFC 9110", package: "swift-rfc-9110"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Cursor Standard Library Integration", package: "swift-cursor"),
                .product(name: "Coder", package: "swift-coder"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Optic", package: "swift-optic"),
                .product(name: "Optic Coder", package: "swift-optic-coder"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Skip", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Prism Derivation", package: "swift-prism-derivation"),
                .product(name: "Signature Derivation", package: "swift-signature-derivation"),
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
