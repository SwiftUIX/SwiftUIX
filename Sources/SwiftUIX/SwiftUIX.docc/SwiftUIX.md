# ``SwiftUIX``

SwiftUIX attempts to fill the gaps of SwiftUI, providing an extensive suite of components, extensions and utilities to complement the standard library. This project is **by far** the most complete port of missing UIKit/AppKit functionality, striving to deliver it in the most Apple-like fashion possible.

## Overview

### UIKit → SwiftUI

| UIKit                                     | SwiftUI        | SwiftUIX                                     |
| ----------------------------------------- | -------------- | -------------------------------------------- |
| ``LPLinkView``                            | -              | ``LinkPresentationView``                     |
| ``UIActivityIndicatorView``               | -              | ``ActivityIndicator``                        |
| ``UIActivityViewController``              | -              | ``AppActivityView``                          |
| ``UIBlurEffect``                          | -              | ``BlurEffectView``                           |
| ``UICollectionView``                      | -              | ``CollectionView``                           |
| ``UIDeviceOrientation``                   | -              | ``DeviceLayoutOrientation``                  |
| ``UIImagePickerController``               | -              | ``ImagePicker``                              |
| ``UIPageViewController``                  | -              | ``PaginationView``                           |
| ``UIScreen``                              | -              | ``Screen``                                   |
| ``UISearchBar``                           | -              | ``SearchBar``                                |
| ``UIScrollView``                          | ``ScrollView`` | ``CocoaScrollView``                          |
| ``UISwipeGestureRecognizer``              | -              | ``SwipeGestureOverlay``                      |
| ``UITableView``                           | ``List``       | ``CocoaList``                                |
| ``UITextField``                           | ``TextField``  | ``CocoaTextField``                           |
| ``UIModalPresentationStyle``              | -              | ``ModalPresentationStyle``                   |
| ``UIViewControllerTransitioningDelegate`` | -              | ``UIHostingControllerTransitioningDelegate`` |
| ``UIVisualEffectView``                    | -              | ``VisualEffectView``                         |
| ``UIWindow``                              | -              | ``WindowOverlay``                            |

### **Activity**

- ``ActivityIndicator``

  ```
  ActivityIndicator()
      .animated(true)
      .style(.large)
  ```

- ``AppActivityView`` - a SwiftUI port for ``UIActivityViewController``.

  ```swift
  AppActivityView(activityItems: [...])
      .excludeActivityTypes([...])
      .onCancel { }
      .onComplete { result in
          foo(result)
      }
  ```

### Appearance

- ``View/visible(_:)`` - Sets a view's visibility.

### CollectionView

Use ``CollectionView`` within your SwiftUI view, providing it with a data source and a way to build cells.

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

- ``TryButton`` - A button capable of performing throwing functions.

### Geometry

- ``flip3D(_:axis:reverse:)`` - Flips this view.
- ``RectangleCorner`` - A corner of a Rectangle.
- ``ZeroSizeView`` - A zero-size view for when ``EmptyView`` just doesn't work.

### Keyboard

- ``Keyboard`` - An object representing the keyboard.
- ``View/padding(.keyboard) ``- Pads this view with the active system height of the keyboard.

### Link Presentation:

Use ``LinkPresentationView`` to display a link preview for a given URL.

```swift
LinkPresentationView(url: url)
    .frame(height: 192)
```

### Navigation Bar

- ``View/navigationBarColor(_:)`` - Configures the color of the navigation bar for this view.
- ``View/navigationBarTranslucent(_:)`` - Configures the translucency of the navigation bar for this view.
- ``View/navigationBarTransparent(_:)`` - Configures the transparency of the navigation bar for this view.
- ``View/navigationBarLargeTitle(_:)`` - Set a custom view for the navigation bar's large view mode.

### Pagination

- ``PaginationView``

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

- ``View/isScrollEnabled(_:)`` - Adds a condition that controls whether users can scroll within this view. Works with:

  - ``CocoaList``
  - ``CocoaScrollView``
  - ``CollectionView``
  - ``TextView``

  Does not work with SwiftUI's ``ScrollView``.

### Search

- ``SearchBar`` - A SwiftUI port for ``UISearchBar``.

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

- ``View/navigationSearchBar(_:)`` - Sets the navigation search bar for this view.

  ```swift
  Text("Hello, world!")
      .navigationSearchBar {
          SearchBar("Placeholder", text: $text)
      }
  ```

- ``View/navigationSearchBarHiddenWhenScrolling(_:)`` - Hides the integrated search bar when scrolling any underlying content.

### Screen

- ``Screen`` - A representation of the device's screen.
- ``UserInterfaceIdiom`` - A SwiftUI port for ``UIUserInterfaceIdiom``.
- ``UserInterfaceOrientation`` - A SwiftUI port for ``UserInterfaceOrientation``.

### Scroll

- ``ScrollIndicatorStyle`` - A type that specifies the appearance and interaction of all scroll indicators within a view hierarchy
- ``HiddenScrollViewIndicatorStyle`` - A scroll indicator style that hides all scroll view indicators within a view hierarchy.

### Status Bar

- ``View/statusItem(id:image:)`` - Adds a status bar item configured to present a popover when clicked

  ```swift
  Text("Hello, world!")
      .statusItem(id: "foo", image: .system(.exclamationmark)) {
          Text("Popover!")
              .padding()
      }
  ```

### Text

- ``TextView``

  ```swift
  TextView("placeholder text", text: $text, onEditingChanged: { editing in
      print(editing)
  })
  ```

### Visual Effects

- ``VisualEffectBlurView`` - A blur effect view that expands to fill.

  ```swift
  VisualEffectBlurView(blurStyle: .dark)
      .edgesIgnoringSafeArea(.all)
  ```

### Window

- ``View/windowOverlay(isKeyAndVisible:content:)`` - Makes a window key and visible when a given condition is true.

## Topics

### Guides

- ``<doc:ViewStorage>``
- ``<doc:Image-Picker>``
- ``<doc:Keyboard-Shortcuts>``
