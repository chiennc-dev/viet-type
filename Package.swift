// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VietType",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "VietTypeCore", targets: ["VietTypeCore"]),
        .executable(name: "VietType", targets: ["VietTypeIME"]),
        .executable(name: "VietTypeInstaller", targets: ["VietTypeInstaller"])
    ],
    targets: [
        .target(name: "VietTypeCore"),
        .executableTarget(name: "VietTypeIME", dependencies: ["VietTypeCore"],
                          linkerSettings: [.linkedFramework("AppKit"), .linkedFramework("InputMethodKit")]),
        .target(name: "VietTypeInstallerCore"),
        .executableTarget(name: "VietTypeInstaller", dependencies: ["VietTypeInstallerCore"],
                          linkerSettings: [.linkedFramework("AppKit"), .linkedFramework("Carbon")]),
        .testTarget(name: "VietTypeCoreTests", dependencies: ["VietTypeCore"]),
        .testTarget(name: "VietTypeInstallerCoreTests", dependencies: ["VietTypeInstallerCore"])
    ]
)
