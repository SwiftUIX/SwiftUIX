# ``SwiftUIX``

SwiftUIX is an exhaustive expansion of the standard SwiftUI library.

![Logo](https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png)

SwiftUIX attempts to fill the gaps of SwiftUI, providing an extensive suite of components, extensions and utilities to complement the standard library.

This project is **by far** the most complete port of missing UIKit/AppKit functionality, striving to deliver it in the most Apple-like fashion possible.


## Why

The goal of this project is to **complement** the SwiftUI standard library, offering hundreds of extensions and views that empower you, the developer, to build applications with the ease promised by the revolution that is SwiftUI.


## Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).

```
https://github.com/SwiftUIX/SwiftUIX.git
```

### Adding SwiftUIX to an app

Follow these steps to add SwiftUIX to an app:

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/SwiftUIX/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Up to Next Major Version**.
4. Click **Finish**.
5. Open the Project settings, add **SwiftUI.framework** to the **Linked Frameworks and Libraries**, set **Status** to **Optional**.

### Adding SwiftUIX to a package

Follow these steps to add SwiftUIX to another Swift package:

1. In Xcode, open your `Package.swift` file.
2. Add a `.package` dependency to `dependencies`, like this:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
]
```

3. Add `SwiftUIX` to the list of dependencies for your target(s):

```swift
myTarget(
    ...
    dependencies: ["SwiftUIX"]
)
```


## Requirements

Swift 5.10 is the minimum Swift version required to build SwiftUIX. Swift 5.9 is no longer supported.

- Deployment targets: iOS 13, macOS 10.15, tvOS 13, watchOS 6 and visionOS 1
- Xcode 15.4+

> Note: Deployment targets may be bumped without major version bumps before 1.0.



## Documentation

While this documentation is being worked on, all documentstion is available via the [repository wiki](https://github.com/SwiftUIX/SwiftUIX/wiki).

While the project itself is stable and heavily being used in production, its documentation is **work-in-progress**.



## Contents

Aiming to be the definitive source of information, code examples, etc. for this repository, this documentation will put less things on this page, and instead split things up in articles, namespaces, etc. 



## Topics

### UIKit → SwiftUI

- TBD

### SwiftUI

- TBD
