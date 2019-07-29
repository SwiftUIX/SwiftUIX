<img align=top src="https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png" width="36" height="36"> SwiftUIX: An extension to the standard SwiftUI library.
======================================

SwiftUIX attempts to fill the gaps of the still nascent SwiftUI framework, providing an extensive suite of components, extensions and utilities to complement the standard library.

# Installation

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/swiftuix/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Branch** with the branch set to `master`.
4. Click **Finish**.

# Usage

## Controls:

### `Checkbox`

A simple checkbox control. Its API mimics that of `Toggle`.

## Control Flow: 

### `SwitchOver`

This library offers affordances for emulating multiple types of control flow. Below is an example of a [`switch`](https://en.wikipedia.org/wiki/Control_flow#Case_and_switch_statements) control flow. 

The following, for example, will render a circle:


```
enum ShapeType {
    case capsule
    case circle
    case rectangle
    case squircle
}

struct ContentView: View {
    @State var shapeType: ShapeType = .circle

    var body: some View {
        SwitchOver(shapeType)
            .case(.capsule) {
                Capsule()
                    .frame(width: 50, height: 100)
                Text("Capsule 💊!")
            }
            .case(.circle) {
                Circle()
                    .frame(width: 50, height: 50)
                Text("Circle 🔴!")
            }
            .case(.rectangle) {
                Rectangle()
                    .frame(width: 50, height: 50)
                Text("Rectangle ⬛!")
            }
            .default {
                Text("Whoa!")
            }
    }
}
```

Whereas changing `shapeType` to `.squircle` would render the default case `Text("Woah!")`.

# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).
