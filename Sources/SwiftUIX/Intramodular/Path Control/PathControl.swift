//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Combine
import Swift
import SwiftUI

/// A display of a file system path or virtual path information.
public struct PathControl<Label> {
    fileprivate enum OnItemClick {
        case openItem
        case url(Binding<URL?>)
    }
    
    private let url: URL?
    private let label: Label
    private let onItemClick: OnItemClick?
    private var placeholder: String?
}

extension PathControl where Label == EmptyView {
    public init(url: Binding<URL?>) {
        self.url = url.wrappedValue
        self.onItemClick = .url(url)
        self.label = EmptyView()
    }
    
    public init(path: Binding<String?>) {
        self.init(url: path.toFileURL())
    }
    
    public init(url: URL) {
        self.url = url
        self.onItemClick = .openItem
        self.label = EmptyView()
    }
}

extension PathControl where Label == Text {
    public init<S: StringProtocol>(_ title: S, url: Binding<URL?>) {
        self.url = url.wrappedValue
        self.onItemClick = .url(url)
        self.label = .init(title)
        self.placeholder = .init(title)
    }
    
    public init<S: StringProtocol>(_ title: S, url: URL) {
        self.url = url
        self.onItemClick = .openItem
        self.label = .init(title)
        self.placeholder = .init(title)
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
        nsView.delegate = context.coordinator

        nsView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        nsView.focusRingType = .none
        
        return nsView
    }
    
    public func updateNSView(
        _ nsView: NSViewType,
        context: Context
    ) {
        context.coordinator.onItemClick = onItemClick
        
        if context.environment.pathControlStyle is StandardPathControlStyle {
            nsView._assignIfNotEqual(.standard, to: \.pathStyle)
        } else if context.environment.pathControlStyle is PopUpPathControlStyle {
            nsView._assignIfNotEqual(.popUp, to: \.pathStyle)
        }
        
        nsView._assignIfNotEqual(.init(context.environment.controlSize), to: \.controlSize)
        nsView._assignIfNotEqual(placeholder, to: \.placeholderString)
        
        switch onItemClick {
            case .openItem:
                nsView.isEditable = false
            default:
                nsView.isEditable = context.environment.isEnabled
        }

        nsView.url = url
    }
    
    public final class Coordinator: NSObject, ObservableObject, NSPathControlDelegate {
        fileprivate var onItemClick: OnItemClick?
        
        @objc func pathItemClicked(_ sender: NSPathControl) {
            guard let onItemClick, let clickedPathItem = sender.clickedPathItem else {
                return
            }
            
            switch onItemClick {
                case .openItem:
                    if let url = clickedPathItem.url {
                        NSWorkspace.shared.open(url)
                    }
                case .url(let url):
                    url.wrappedValue = clickedPathItem.url
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init()
    }
}

// MARK: - API

extension View {
    /// Sets the style for path controls within this view.
    public func pathControlStyle(_ style: PathControlStyle) -> some View {
        environment(\.pathControlStyle, style)
    }
}

// MARK: - Auxiliary

public protocol PathControlStyle {
    
}

public struct StandardPathControlStyle: PathControlStyle {
    public init() {
        
    }
}

extension PathControlStyle where Self == StandardPathControlStyle {
    public static var standard: Self {
        Self()
    }
}

public struct PopUpPathControlStyle: PathControlStyle {
    public init() {
        
    }
}

extension PathControlStyle where Self == PopUpPathControlStyle {
    public static var popUp: Self {
        Self()
    }
}

extension EnvironmentValues {
    var pathControlStyle: PathControlStyle {
        get {
            self[DefaultEnvironmentKey<PathControlStyle>.self] ?? StandardPathControlStyle()
        } set {
            self[DefaultEnvironmentKey<PathControlStyle>.self] = newValue
        }
    }
}

// MARK: - Helpers

fileprivate extension Binding where Value == String? {
    func toFileURL() -> Binding<URL?> {
        .init(
            get: {
                self.wrappedValue.map({ NSString(string: $0).expandingTildeInPath as String }).flatMap(URL.init(fileURLWithPath:))
            },
            set: {
                self.wrappedValue = $0?.path
            }
        )
    }
}

#endif
