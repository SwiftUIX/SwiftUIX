### `TimerState`

Working with timers in SwiftUI can often require a fair amount of boilerplate, and a simpler API is desirable. This is where `@TimerState` comes in.

**Usage:**

```swift
struct ContentView: View {
    @TimerState(interval: 2) var timeElapsed: Int
    
    var body: some View {
        Text("\(timeElapsed) second(s) have elapsed")
    }
}
```