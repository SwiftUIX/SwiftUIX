//
// Copyright (c) Vatsal Manot
//


#if os(macOS)

import SwiftUI

@_documentation(visibility: internal)
public struct _AnyApp: SwiftUI.App {
    public var body: some Scene {
        _EmptyScene()
    }
    
    public init() {
        
    }
}

extension SwiftUI.App where Self == _AnyApp {
    public static var _current: Self {
        Self()
    }
}

extension App {
    public static var _SwiftUIX_appActivationPolicy: _SwiftUIX_AppActivationPolicy {
        get {
            _SwiftUIX_AppActivationPolicy(from: NSApplication.shared.activationPolicy())
        } set {
            guard newValue != self._SwiftUIX_appActivationPolicy else {
                return
            }
            
            switch newValue {
                case .regular:
                    NSApplication.shared.setActivationPolicy(.regular)
                case .accessory:
                    NSApplication.shared.setActivationPolicy(.accessory)
                case .prohibited:
                    NSApplication.shared.setActivationPolicy(.prohibited)
            }
        }
    }
    
    public var _SwiftUIX_appActivationPolicy: _SwiftUIX_AppActivationPolicy {
        get {
            Self._SwiftUIX_appActivationPolicy
        } nonmutating set {
            Self._SwiftUIX_appActivationPolicy = newValue
        }
    }
}

@_documentation(visibility: internal)
public enum _SwiftUIX_AppActivationPolicy: Hashable {
    case regular
    case accessory
    case prohibited
    
    fileprivate init(from policy: NSApplication.ActivationPolicy) {
        switch policy {
            case .regular:
                self = .regular
            case .accessory:
                self = .accessory
            case .prohibited:
                self = .prohibited
            default:
                assertionFailure()
                
                self = .regular
        }
    }
}

#endif
