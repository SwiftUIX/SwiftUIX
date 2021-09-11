//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)

/// A display of a file system path or virtual path information.
public struct PathControl<Label> {
    private let label: Label
    
    @Binding private var url: URL?
    
    private var placeholderText: String?
    private var onDoubleTapGesture: () -> Void = { }
}

extension PathControl where Label == EmptyView {
    public init(url: Binding<URL?>) {
        self._url = url
        self.label = EmptyView()
    }
    
    public init(path: Binding<String?>) {
        self.init(url: path.toFileURL())
    }
}

extension PathControl where Label == Text {
    public init<S: StringProtocol>(_ title: S, url: Binding<URL?>) {
        self._url = url
        self.label = .init(title)
        self.placeholderText = .init(title)
    }
    
    public init<S: StringProtocol>(_ title: S, path: Binding<String?>) {
        self.init(title, url: path.toFileURL())
    }
}

extension PathControl: NSViewRepresentable {
    public typealias NSViewType = NSPathControl
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType()
        
        nsView.target = context.coordinator
        nsView.action = #selector(context.coordinator.pathItemClicked)
        nsView.doubleAction = #selector(context.coordinator.pathControlDoubleClicked)
        
        nsView.delegate = context.coordinator
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.onURLChange = { self.url = $0 }
        context.coordinator.onDoubleTapGesture = onDoubleTapGesture
        
        if context.environment.pathControlStyle is StandardPathControlStyle {
            nsView.pathStyle = .standard
        } else if context.environment.pathControlStyle is PopUpPathControlStyle {
            nsView.pathStyle = .popUp
        }
        
        nsView.placeholderString = placeholderText
        nsView.isEditable = context.environment.isEnabled
        nsView.url = url
    }
    
    public final class Coordinator: NSObject, ObservableObject, NSPathControlDelegate {
        var onURLChange: (URL?) -> Void = { _ in }
        var onDoubleTapGesture: () -> Void = { }
        
        @objc func pathControlDoubleClicked(_ sender: NSPathControl) {
            onDoubleTapGesture()
        }
        
        @objc func pathItemClicked(_ sender: NSPathControl) {
            guard let clickedPathItem = sender.clickedPathItem else {
                return
            }
            
            onURLChange(clickedPathItem.url)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init()
    }
}

// MARK: - API -

extension PathControl {
    /// Adds an action to perform when this view recognizes a double-tap gesture.
    public func onDoubleTapGesture(perform action: @escaping () -> Void) -> Self {
        then({ $0.onDoubleTapGesture = action })
    }
}

extension View {
    @inlinable
    public func pathControlStyle(_ style: PathControlStyle) -> some View {
        environment(\.pathControlStyle, style)
    }
}

// MARK: - Auxiliary Implementation -

public protocol PathControlStyle {
    
}

public struct StandardPathControlStyle: PathControlStyle {
    public init() {
        
    }
}

public struct PopUpPathControlStyle: PathControlStyle {
    public init() {
        
    }
}

extension EnvironmentValues {
    @usableFromInline
    var pathControlStyle: PathControlStyle {
        get {
            self[DefaultEnvironmentKey<PathControlStyle>.self] ?? StandardPathControlStyle()
        } set {
            self[DefaultEnvironmentKey<PathControlStyle>.self] = newValue
        }
    }
}

// MARK: - Helpers -

fileprivate extension Binding where Value == String? {
    func toFileURL() -> Binding<URL?> {
        .init(
            get: { self.wrappedValue.map({ NSString(string: $0).expandingTildeInPath as String }).flatMap(URL.init(fileURLWithPath:)) },
            set: { self.wrappedValue = $0?.path }
        )
    }
}

#endif
