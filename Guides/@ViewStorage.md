# @ViewStorage

`@ViewStorage` is a property wrapper like `@State`, except that modifying a `@ViewStorage` wrapped value does not cause the view's body to update. It does however, tie the lifetime of the value to the view holding the `@ViewStorage`, just like `@State`. 

## Example Usage

### Optimizing Scrollable Content with `@ViewStorage`

Imagine that you have a scrollable view, `MyScrollView`, that allows the parent to observe its scroll content offset via a `Binding`. 

Your use case for observing the value is that you want to hide your app's navigation bar if the content is scrolled beyond a certain threshold. A simple implementation would be this:

```swift
struct MyView: View {
    @State private var scrollContentOffset: CGPoint

    var body: some View {
        MyScrollView(contentOffset: $scrollContentOffset)
            .navigationBarHidden(scrollContentOffset.y < 0)
    }
}
```

Now, while this implementation is functional, it is not the most performant. You only care about hiding the navigation bar if the scroll content offset's y-value is below a certain threshold, but because you are updating the scroll content offset in a `@State` variable, your entire view will refresh everytime the scroll content offset changes (including `MyScrollView` itself). Updating a scroll view, especially one that is moving, at a touch response rate of 120hz, is not performant, especially when that update is entirely redundant in the first place.

You could solve this by putting  `scrollContentOffset` in a model object:

```swift
struct MyOptimizedView: View {
    class ScrollContentOffsetTracker: ObservableObject {
        var scrollContentOffset: CGPoint = .zero  {
            didSet {
                isNavigationBarVisible = scrollContentOffset.y < 0
            }
        }

        @Published var isNavigationBarVisible: Bool = false

        init() {

        }
    }

    @State private var scrollContentOffsetTracker = ScrollContentOffsetTracker()

    var body: some View {
        MyScrollView(contentOffset: $scrollContentOffsetTracker.scrollContentOffset)
            .navigationBarHidden(scrollContentOffsetTracker.isNavigationBarVisible)
    }
}
```

While the implementation has now become more complex, your view now only updates when `isNavigationBarVisible` updates, which only happens when the scroll content offset's y-value goes below or above a certain threshold. Changing `scrollContentOffset` does not trigger an update because it is not marked as a `@Published` variable.

This is where `@ViewStorage`. Instead of having to implement a custom model class each time you encounter this scenario, `@ViewStorage` provides a stateful, but non-view-invalidating, means to store a value.

```swift
struct MyCleanOptimizedView: View {
    @ViewStorage private var scrollContentOffset: CGPoint

    @State private var isNavigationBarVisible: Bool = false

    var body: some View {
        MyScrollView(contentOffset: $scrollContentOffset.binding)
            .navigationBarHidden(isNavigationBarVisible)
            .onReceive($scrollContentOffset.publisher) { offset in
                isNavigationBarVisible = scrollContentOffset.y < 0
            }
    }
}
```

In this final case, the implementation is still concise yet functionally equivalent to the the one above it. `@ViewStorage` offers a `publisher` that allows you track changes to its wrapped value, which paired with SwiftUI's `View.onReceive(_:perform)` offers a convenient update block where you can perform your logic.  