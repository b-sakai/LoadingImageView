# LoadingImageView
swift package of loading image view for SwiftUI

![output](https://github.com/user-attachments/assets/44ae97aa-8a85-4f1c-860e-866f8178b92a)

[![Release](https://img.shields.io/github/v/release/b-sakai/LoadingImageView)](https://github.com/b-sakai/LoadingImageView/releases/latest)
[![Twitter](https://img.shields.io/twitter/follow/serotoninapp?style=social)](https://twitter.com/serotoninapp)

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
        .package(url: "https://github.com/b-sakai/LoadingImageView", .upToNextMajor(from: "0.1.5")),
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
                LoadingImageView(
                    image: Image("appIcon", bundle: .module),
                    size: CGSize(width: 100, height: 100)
                )
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
