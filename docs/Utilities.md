### `@ObservableState` 

A drop-in replacement for `@State` that allows for observing the state as a stream of events. It exposes two publishers, `willSet` and `didSet`. Example usage is as follows:

```swift
struct ContentView: View {
    @ObservableState var foo: Int = 0

    let observation: AnyCancellable

    init() {
        _foo.willChange.sink {
            print($0.oldValue, $0.newValue)
        }
    }

    var body: some View {
        Button(action: { self.foo += 1 }) {
            Text("Increment")
        }
    }
}
```

The example above demonstrates subscribing to your state's changes using the `sink` operator.