# <img align=top src="https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png" width="36" height="36"> SwiftUIX

![CI](https://github.com/SwiftUIX/SwiftUIX/workflows/CI/badge.svg)

SwiftUIX attempts to fill the gaps of SwiftUI, providing an extensive suite of components, extensions and utilities to complement the standard library. This project is **by far** the most complete port of missing UIKit/AppKit functionality, striving to deliver it in the most Apple-like fashion possible.

- [Why](#why)
- [Requirements](#requirements)
- [Installation](#installation)
- [Contents](#contents)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Credits](#credits)


# Why

The goal of this project is to **complement** the SwiftUI standard library, offering hundreds of extensions and views that empower you, the developer, to build applications with the ease promised by the revolution that is SwiftUI.


# Requirements

> [!Note]
> Swift 5.10 is the minimum Swift version required to build SwiftUIX, Swift 5.9 is no longer supported.

- Deployment targets: iOS 13, macOS 10.15, tvOS 13, watchOS 6 and visionOS 1
- Xcode 15.4+ 


# Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).

```swift
/// Package.swift
/// ...
dependencies: [
    .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
]
/// ...
```

> Xcode 15 integrates with libSwiftPM to provide support for iOS, watchOS, macOS and tvOS platforms.

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/SwiftUIX/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.
5. Open the Project settings, add **SwiftUIX.framework** to the **Linked Frameworks and Libraries**, set **Status** to **Optional**.


# Documentation

The SwiftUIX documentation can be found at:

https://swiftuix.github.io/SwiftUIX/documentation/swiftuix/

All documentation that hasn't been migrated here is available via the [repository wiki](https://github.com/SwiftUIX/SwiftUIX/wiki).


# Contents

While the project itself is stable and heavily being used in production, its documentation is **work-in-progress**. Contributions are encouraged and welcomed.

### UIKit → SwiftUI

| UIKit                                   | SwiftUI      | SwiftUIX                                   |
| --------------------------------------- | ------------ | ------------------------------------------ |
| `LPLinkView`                            | -            | `LinkPresentationView`                     |
| `UIActivityIndicatorView`               | -            | `ActivityIndicator`                        |
| `UIActivityViewController`              | -            | `AppActivityView`                          |
| `UIBlurEffect`                          | -            | `BlurEffectView`                           |
| `UICollectionView`                      | -            | `CollectionView`                           |
| `UIDeviceOrientation`                   | -            | `DeviceLayoutOrientation`                  |
| `UIImagePickerController`               | -            | `ImagePicker`                              |
| `UIPageViewController`                  | -            | `PaginationView`                           |
| `UIScreen`                              | -            | `Screen`                                   |
| `UISearchBar`                           | -            | `SearchBar`                                |
| `UIScrollView`                          | `ScrollView` | `CocoaScrollView`                          |
| `UISwipeGestureRecognizer`              | -            | `SwipeGestureOverlay`                      |
| `UITableView`                           | `List`       | `CocoaList`                                |
| `UITextField`                           | `TextField`  | `CocoaTextField`                           |
| `UIModalPresentationStyle`              | -            | `ModalPresentationStyle`                   |
| `UIViewControllerTransitioningDelegate` | -            | `UIHostingControllerTransitioningDelegate` |
| `UIVisualEffectView`                    | -            | `VisualEffectView`                         |
| `UIWindow`                              | -            | `WindowOverlay`                            |

### **Activity**

- `ActivityIndicator`

  ```
  ActivityIndicator()
      .animated(true)
      .style(.large)
  ```

- `AppActivityView` - a SwiftUI port for `UIActivityViewController`.

  ```swift
  AppActivityView(activityItems: [...])
      .excludeActivityTypes([...])
      .onCancel { }
      .onComplete { result in
          foo(result)
      }
  ```

### Appearance

- `View/visible(_:)` - Sets a view's visibility.

### CollectionView

Use `CollectionView` within your SwiftUI view, providing it with a data source and a way to build cells.

```swift
import SwiftUIX

struct MyCollectionView: View {
    let data: [MyModel] // Your data source

    var body: some View {
        CollectionView(data, id: \.self) { item in
            // Build your cell view
            Text(item.title)
        }
    }
}
```

### Error Handling

- `TryButton` - A button capable of performing throwing functions.

### Geometry

- `flip3D(_:axis:reverse:)` - Flips this view.
- `RectangleCorner` - A corner of a Rectangle.
- `ZeroSizeView` - A zero-size view for when `EmptyView` just doesn't work.

### Keyboard

- `Keyboard` - An object representing the keyboard.
- `View/padding(.keyboard) `- Pads this view with the active system height of the keyboard.

### Link Presentation:

Use `LinkPresentationView` to display a link preview for a given URL.

```swift
LinkPresentationView(url: url)
    .frame(height: 192)
```

### Navigation Bar

- `View/navigationBarColor(_:)` - Configures the color of the navigation bar for this view.
- `View/navigationBarTranslucent(_:)` - Configures the translucency of the navigation bar for this view.
- `View/navigationBarTransparent(_:)` - Configures the transparency of the navigation bar for this view.
- `View/navigationBarLargeTitle(_:)` - Set a custom view for the navigation bar's large view mode.

### Pagination

- `PaginationView`

  ```swift
  PaginationView(axis: .horizontal) {
      ForEach(0..<10, id: \.hashValue) { index in
          Text(String(index))
      }
  }
  .currentPageIndex($...)
  .pageIndicatorAlignment(...)
  .pageIndicatorTintColor(...)
  .currentPageIndicatorTintColor(...)
  ```

### Scrolling

- `View/isScrollEnabled(_:)` - Adds a condition that controls whether users can scroll within this view. Works with:

  - `CocoaList`
  - `CocoaScrollView`
  - `CollectionView`
  - `TextView`

  Does not work with SwiftUI's `ScrollView`.

### Search

- `SearchBar` - A SwiftUI port for `UISearchBar`.

  ```swift
  struct ContentView: View {
      @State var isEditing: Bool = false
      @State var searchText: String = ""

      var body: some View {
          SearchBar("Search...", text: $searchText, isEditing: $isEditing)
              .showsCancelButton(isEditing)
              .onCancel { print("Canceled!") }
      }
  }
  ```

- `View/navigationSearchBar(_:)` - Sets the navigation search bar for this view.

  ```swift
  Text("Hello, world!")
      .navigationSearchBar {
          SearchBar("Placeholder", text: $text)
      }
  ```

- `View/navigationSearchBarHiddenWhenScrolling(_:)` - Hides the integrated search bar when scrolling any underlying content.

### Screen

- `Screen` - A representation of the device's screen.
- `UserInterfaceIdiom` - A SwiftUI port for `UIUserInterfaceIdiom`.
- `UserInterfaceOrientation` - A SwiftUI port for `UserInterfaceOrientation`.

### Scroll

- `ScrollIndicatorStyle` - A type that specifies the appearance and interaction of all scroll indicators within a view hierarchy
  - `HiddenScrollViewIndicatorStyle` - A scroll indicator style that hides all scroll view indicators within a view hierarchy.

### Status Bar

- `View/statusItem(id:image:`) - Adds a status bar item configured to present a popover when clicked

  ```swift
  Text("Hello, world!")
      .statusItem(id: "foo", image: .system(.exclamationmark)) {
          Text("Popover!")
              .padding()
      }
  ```

### Text

- `TextView`

  ```swift
  TextView("placeholder text", text: $text, onEditingChanged: { editing in
      print(editing)
  })
  ```

### Visual Effects

- `VisualEffectBlurView` - A blur effect view that expands to fill.

  ```swift
  VisualEffectBlurView(blurStyle: .dark)
      .edgesIgnoringSafeArea(.all)
  ```

### Window

- `View/windowOverlay(isKeyAndVisible:content:)` - Makes a window key and visible when a given condition is true.

### Edit Menu

- `View/editMenu(isVisible:content:)` - Adds an edit menu to the view.

  ```swift
  Text("Hello, world!")
      .editMenu(isVisible: $isEditMenuVisible) {
          EditMenuItem("Copy") {
              // Perform copy action
          }
          EditMenuItem("Paste") {
              // Perform paste action
          }
      }
  ```


# Contributing

SwiftUIX welcomes contributions in the form of GitHub issues and pull-requests. Please refer the [projects](https://github.com/SwiftUIX/SwiftUIX/projects) section before raising a bug or feature request, as it may already be under progress.

To create an Xcode project for SwiftUIX run `bundle install; bundle exec fastlane generate_xcodeproj`.
To check the automated builds for SwiftUIX run `bundle install; bundle exec fastlane build`.


# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).


# Support

SwiftUIX is and will always remain free and open-source.

Maintaining SwiftUIX is a massively time-consuming endeavour. If you're reliant on SwiftUIX for your app/project and would like to see it grow, consider either:

- [Contributing](#contributing)
- [Donating via Patreon](http://patreon.com/vmanot)


# Credits

SwiftUIX is led and maintained by [@vatsal_manot](http://twitter.com/vatsal_manot).

Special thanks to [Brett Best](https://github.com/Brett-Best), [Nathan Tanner](https://github.com/nathantannar4), [Kabir Oberai](https://github.com/kabiroberai) and many more.


[Documentation]: https://swiftuix.github.io/SwiftUIX
