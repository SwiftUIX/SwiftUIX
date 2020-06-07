### `OptionalEnvironmentObject` 

An `@EnvironmentObject` wrapper that affords `Optional`-ity to environment objects. Use just like `@EnvironmentObject`, but declare your variable as optional.

**Usage:**

```swift

class Foo: ObservableObject {
    
}

struct ContentView: View {
    @OptionalEnvironmentObject var foo: Foo?
    
    var body: some View {
        Text("Hello World")
    }
}

```