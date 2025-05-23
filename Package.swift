// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "RIBs",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(name: "RIBs", targets: ["RIBs"]),
    .library(name: "Example", targets: ["Example"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMinor(from: "6.5.0")),
    .package(url: "https://github.com/iDmitriyy/SwiftyKit.git", branch: "main"),
    .package(url: "https://github.com/iDmitriyy/ErrorsSuite.git", branch: "main"),
    .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMinor(from: "2.2.2")), // for testTarget only
  ],
  targets: [
    .target(name: "Example", dependencies: ["RIBs"], path: "Example"),
    .target(name: "RIBs",
            dependencies: [.product(name: "RxRelay", package: "rxswift"),
                           .product(name: "RxSwift", package: "rxswift"),
                           .product(name: "RxCocoa", package: "rxswift"),
                           .product(name: "SwiftyKit", package: "SwiftyKit"),
                           .product(name: "CommonErrorsPack", package: "ErrorsSuite")],
            path: "RIBs"),
    .testTarget(name: "RIBsTests", dependencies: ["RIBs", "CwlPreconditionTesting"], path: "RIBsTests"),
  ],
  swiftLanguageModes: [.v6]
)

for target: PackageDescription.Target in package.targets {
  {
    var settings: [PackageDescription.SwiftSetting] = $0 ?? []
    settings.append(.enableUpcomingFeature("ExistentialAny"))
    settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
    settings.append(.enableUpcomingFeature("MemberImportVisibility"))
//    settings.append(.enableExperimentalFeature("IsolatedDeinit")) // enableExperimentalFeature
    $0 = settings
  }(&target.swiftSettings)
}
