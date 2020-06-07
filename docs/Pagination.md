### `PaginationView`

SwiftUIX offers a port of `UIPageViewController` via `PaginationView`.

```swift
/// A view that paginates its children along a given axis.
public struct PaginationView<Content: View>: View {
    public init(
        axis: Axis = .horizontal,
        pageIndicatorAlignment: Alignment? = nil,
        @ArrayBuilder<Page> content: () -> [Page]
    )

    /// Declares the content and behavior of this view.
    public var body: some View { get }
}
```

One notable feature of the port offered by SwiftUIX is that it offers page indicators for both horizontal _and_ vertical pagination. 

#### Usage:

```swift
struct ContentView: View {    
    var body: some View {
        PaginationView(axis: .horizontal) {
            Text("One")
            Text("Two")
            Text("Three")
        }
    }
}
```

Note that the views must be homogeneous. If you wish to mix multiple view types, ensure that they are erased to `AnyView` via `View.eraseToAnyView()` provided by SwiftUIX:

```swift
struct ContentView: View {    
    var body: some View {
        PaginationView(axis: .horizontal) {
            ViewTypeOne().eraseToAnyView()
            ViewTypeTwo().eraseToAnyView()
            ViewTypeThree().eraseToAnyView()
        }
    }
}
```