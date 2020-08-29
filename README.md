<img align=top src="https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png" width="36" height="36"> SwiftUIX: An extension to the standard SwiftUI library.
======================================

![CI](https://github.com/SwiftUIX/SwiftUIX/workflows/CI/badge.svg)

SwiftUIX attempts to fill the gaps of the still nascent SwiftUI framework, providing an extensive suite of components, extensions and utilities to complement the standard library. This project is **by far** the most complete port of missing UIKit/AppKit functionality, striving it to deliver in most Apple-like fashion possible.

- [Why](#why) 
- [Documentation](#documentation) 
- [Requirements](#requirements) 
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Credits](#credits)

# Why

The goal of this project is to **complement** the SwiftUI standard library, offering hundreds of extensions and views that empower you, the developer, to build applications with the ease promised by the revolution that is SwiftUI. 

# Documentation

All documentation is available via the [repository wiki](https://github.com/SwiftUIX/SwiftUIX/wiki). 

- [**General**](https://github.com/SwiftUIX/SwiftUIX/wiki/General)
- [**Control Flow**](https://github.com/SwiftUIX/SwiftUIX/wiki/Control-Flow)
- [**Controls**](https://github.com/SwiftUIX/SwiftUIX/wiki/Controls) 
- [**Dynamic Presentation**](https://github.com/SwiftUIX/SwiftUIX/wiki/Dynamic-Presentation)
- [**Geometry**](https://github.com/SwiftUIX/SwiftUIX/wiki/Geometry)
- [**Keyboard**](https://github.com/SwiftUIX/SwiftUIX/wiki/Keyboard) 
- [**Pagination**](https://github.com/SwiftUIX/SwiftUIX/wiki/Pagination)
- [**Text**](https://github.com/SwiftUIX/SwiftUIX/wiki/Text) 
- [**Utilities**](https://github.com/SwiftUIX/SwiftUIX/wiki/Utilities) 

| UIKit                                   | SwiftUI      | SwiftUIX                                      |
| --------------------------------------- | ------------ | --------------------------------------------- |
| `UIActivityIndicatorView`               | -            | `ActivityIndicator`                           |
| `UIActivityViewController`              | -            | `AppActivityView`                             |
| `UIBlurEffect`                          | -            | `BlurEffectView`                              |
| `UICollectionView`                      | -            | `CollectionView`                              |
| `UIDeviceOrientation`                   | -            | `DeviceLayoutOrientation`                     |
| `UIImagePickerController`               | -            | `ImagePicker`                                 |
| `UIPageViewController`                  | -            | `PaginationView`                              |
| `UIScreen`                              | -            | `Screen`                                      |
| `UISearchBar`                           | -            | `SearchBar`                                   |
| `UIScrollView`                          | `ScrollView` | `CocoaScrollView`                             |
| `UISwipeGestureRecognizer`              | -            | `SwipeGestureOverlay`                         |
| `UITableView`                           | `List`       | `CocoaList`                                   |
| `UITextField`                           | `TextField`  | `CocoaTextField`                              |
| `UIModalPresentationStyle`              | -            | `ModalPresentationStyle`                  |
| `UIViewControllerTransitioningDelegate` | -            | `UIHostingControllerTransitioningDelegate` |
| `UIVisualEffectView`                    | -            | `VisualEffectView`                            |
| `UIWindow`                              | -            | `WindowOverlay`                               |

# Requirements 

- iOS 13, macOS 10.15, tvOS 13, or watchOS 6 
- Swift 5.2
- Xcode 11.6

# Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).

>Xcode 11 integrates with libSwiftPM to provide support for iOS, watchOS, and tvOS platforms.

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/SwiftUIX/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.
5. Open the Project settings, add **SwiftUI.framework** to the **Linked Frameworks and Libraries**, set **Status** to **Optional**.

# Contributing

SwiftUIX welcomes contributions in the form of GitHub issues and pull-requests. Please refer the [projects](https://github.com/SwiftUIX/SwiftUIX/projects) section before raising a bug or feature request, as it may already be under progress.

To create an Xcode project for SwiftUIX run `bundle install; bundle exec fastlane generate_xcodeproj`.
To check the automated builds for SwiftUIX run `bundle install; bundle exec fastlane build`. 

# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).

# Support 

SwiftUIX is and will always be free and open. Maintaining SwiftUIX, however, is a time-consuming endeavour. If you're reliant on SwiftUIX for your app/project and would like to see it grow, consider contributing/donating as way to help.

# Credits

SwiftUIX is a project of [@vmanot](https://github.com/vmanot).
