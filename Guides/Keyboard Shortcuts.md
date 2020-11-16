# Keyboard Shortcuts

The `onKeyboardShortcut(_:perform:)` modifier adds an action to perform when this view recognizes a keyboard shortcut.

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .onKeyboardShortcut(.return) {
                print("This will be printed when the return key is pressed.")
            }
    }
}
```

