<img align=top src="https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png" width="36" height="36"> SwiftUIX: An extension to the standard SwiftUI library.
======================================

SwiftUIX attempts to fill the gaps of the still nascent SwiftUI framework, providing an extensive suite of components, extensions and utilities to complement the standard library.

Documentation is a currently a work-in-progress!

# Why

The goal of this project is to **complement** the SwiftUI standard library, offering hundreds of extensions and views that empower you, the developer, to build applications with the ease promised by the revolution that is SwiftUI. 

This project is also **by far** the most complete port of missing UIKit/AppKit functionality, striving it to deliver in most Apple-like fashion possible.

| UIKit                      | SwiftUI      | SwiftUIX                     |
| -------------------------- | ------------ | ---------------------------- |
| `UIActivityIndicatorView`  | -            | `ActivityIndicator`          |
| `UIPageViewController`     | -            | `PaginationView`             |
| `UISearchBar`              | -            | `SearchBar`                  |
| `UIScrollView`             | `ScrollView` | `CocoaScrollView`            |
| `UITableView`              | `List`       | `CocoaList`                  |
| `UITextField`              | `TextField`  | `CocoaTextField`             |
| `UIModalPresentationStyle` | -            | `ModalViewPresentationStyle` |

# Requirements 

- iOS 13, macOS 10.15, tvOS 13, or watchOS 6 
- Swift 5.1
- Xcode 11

# Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).

>Xcode 11 integrates with libSwiftPM to provide support for iOS, watchOS, and tvOS platforms.

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/SwiftUIX/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.

# Usage

SwiftUIX's documentation is available via the [repository wiki](https://github.com/SwiftUIX/SwiftUIX/wiki). 

# Contributing

SwiftUIX welcomes contributions in the form of GitHub issues and pull-requests. Please refer the [projects](https://github.com/SwiftUIX/SwiftUIX/projects) section before raising a bug or feature request, as it may already be under progress.

# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).

# Credits

SwiftUIX is a project of [@vmanot](https://github.com/vmanot).

# Support 

SwiftUIX is and will always be free and open. Maintaining SwiftUIX, however, is a time-consuming endeavour. If you're reliant on SwiftUIX for your app/project and would like to see it grow, consider contributing/donating as way to help.
