### `ModelView`

```swift
/// A view backed by some model type.
public protocol ModelView: View {
    associatedtype Model

    init(model: Model)
}
```

Useful for creating generic wrappers over `View`s backed by some model.