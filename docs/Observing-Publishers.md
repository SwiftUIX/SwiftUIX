### `ObservedPublisher`

A property wrapper type that subscribes to an observable object and invalidates a view whenever the observable object changes.

**Usage**:

```swift
struct ContentView: View {
    @ObservedPublisher<AnyPublisher<Int, Never>> var value: Int
    
    init() {
        _value = .init(
            publisher: Publishers.Sequence(sequence: [1, 2, 3, 4, 5])
                .flatMap({ Just($0).delay(for: .seconds($0), scheduler: RunLoop.main) })
                .eraseToAnyPublisher(),
            initial: 0
        )
    }
    
    var body: some View {
        Text("\(value)")
            .font(.largeTitle)
            .foregroundColor(.primary)
    }
}
```