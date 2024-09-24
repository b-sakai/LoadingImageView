# LoadingImageView
swift package of loading image view for SwiftUI

[![CI](https://github.com/b-sakai/LoadingImageView/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/b-sakai/LoadingImageView/actions/workflows/main.yml)
[![Release](https://img.shields.io/github/v/release/b-sakai/LoadingImageView)](https://github.com/b-sakai/LoadingImageView/releases/latest)
[![Twitter](https://img.shields.io/twitter/follow/serotoninapp?style=social)](https://twitter.com/serotoninapp)

Transform strings easily in Swift.

## Table of Contents

- [Installation](#installation)
- [How to use](#how-to-use)
- [Contribution](#contribution)
- [Stats](#stats)

## Installation

### Swift Package Manager (Recommended)

#### Package

You can add this package to `Package.swift`, include it in your target dependencies.


```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/b-sakai/LoadingImageView", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "<your-target-name>",
            dependencies: ["LoadingImageView"]),
    ]
)
```

#### Xcode

You can add this package on Xcode.
See [documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).


## How to use

You can just import `LoadingImageView` to use it.

```swift
import LoadingImageView

struct HogeView: View {
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Color.white
        }
        .overlay {
            if isLoading {
                LoadingImageView(image: Image("appIcon", bundle: .module))
            }
        }
        .onAppear {
            isLoading = true
        }
    }
}
```

## Contribution

I would be happy if you contribute :)

- [New issue](https://github.com/b-sakai/LoadingImageView/issues/new)
- [New pull request](https://github.com/b-sakai/LoadingImageView/compare)

## Stats

[![Stats](https://repobeats.axiom.co/api/embed/3b9229c64d59197051a610e702ffb2cc822db648.svg "Repobeats analytics image")](https://github.com/b-sakai/LoadingImageView)
