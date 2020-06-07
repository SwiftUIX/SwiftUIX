SwiftUIX offers affordances for emulating certain types of control flow.

### Switch Statements

Below is an example of a [`switch`](https://en.wikipedia.org/wiki/Control_flow#Case_and_switch_statements) control flow being emulated. 

The following, for example, will render a circle:


```Swift
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

Whereas changing `shapeType` to `.squircle` would render the default case `Text("Whoa!")`.

A more complex case wherein associated values are present:

```Swift
enum Foo: Equatable {
    case bar
    case baz(String)
    
    var bazValue: String? {
        if case let .baz(value) = self {
            return value
        } else {
            return nil
        }
    }
}

struct ContentView: View {
    @State var foo: Foo = .baz("test")
    
    var body: some View {
        SwitchOver(foo)
            .case(.bar) { Text("Bar!") }
            .case(predicate: { $0.bazValue != nil }) { Text(foo.bazValue!) }
    }
}
```