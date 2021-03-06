//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that shows that a task is in progress.
public struct ActivityIndicator {
    public enum Style {
        #if os(macOS)
        case small
        #endif
        case regular
        case large
        
        @available(*, unavailable, renamed: "ActivityIndicator.Style.regular")
        public static var medium: Self {
            .regular
        }
    }
    
    private var isAnimated: Bool = true
    
    #if os(macOS)
    private var style: Style = .small
    #else
    private var style: Style = .regular
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private var tintUIColor: UIColor?
    #endif
    
    public init() {
        
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension ActivityIndicator: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    public typealias UIViewType = UIActivityIndicatorView
    
    public func makeUIView(context: Context) -> UIViewType {
        UIActivityIndicatorView(style: .medium)
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.color = tintUIColor ?? context.environment.tintColor?.toUIColor()
        uiView.style = .init(style)
        uiView.tintColor = tintUIColor ?? context.environment.tintColor?.toUIColor()
        
        if !context.environment.isEnabled && uiView.isAnimating {
            uiView.stopAnimating()
        } else {
            if isAnimated {
                if !uiView.isAnimating {
                    uiView.startAnimating()
                }
            } else {
                if uiView.isAnimating {
                    uiView.stopAnimating()
                }
            }
        }
    }
    
    @_disfavoredOverload
    public func tintColor(_ color: UIColor?) -> Self {
        then({ $0.tintUIColor = color })
    }
}

#elseif os(macOS)

import Cocoa
import AppKit

extension ActivityIndicator: NSViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
    
    public final class NSViewType: NSProgressIndicator {
        public private(set) var isAnimating: Bool = false
        
        public override func startAnimation(_ sender: Any?) {
            super.startAnimation(sender)
            
            isAnimating = true
        }
        
        public override func stopAnimation(_ sender: Any?) {
            super.startAnimation(sender)
            
            isAnimating = true
        }
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType()
        
        nsView.controlSize = .init(style)
        nsView.isIndeterminate = true
        nsView.style = .spinning
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        if !context.environment.isEnabled && nsView.isAnimating {
            nsView.stopAnimation(self)
        } else {
            if isAnimated {
                if !nsView.isAnimating {
                    nsView.startAnimation(self)
                }
            } else {
                if nsView.isAnimating {
                    nsView.stopAnimation(self)
                }
            }
        }
        
        isAnimated ? nsView.startAnimation(self) : nsView.stopAnimation(self)
    }
}

#endif

// MARK: - API -

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ActivityIndicator {
    public func animated(_ isAnimated: Bool) -> ActivityIndicator {
        then({ $0.isAnimated = isAnimated })
    }
    
    public func style(_ style: Style) -> Self {
        then({ $0.style = style })
    }
}

#endif

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIActivityIndicatorView.Style {
    public init(_ style: ActivityIndicator.Style) {
        switch style {
            case .regular:
                self = .medium
            case .large:
                self = .large
        }
    }
}

#elseif os(macOS)

extension NSControl.ControlSize {
    public init(_ style: ActivityIndicator.Style) {
        switch style {
            case .small:
                self = .small
            case .regular:
                self = .regular
            case .large: do {
                if #available(OSX 11.0, *) {
                    self = .large
                } else {
                    self = .regular
                }
            }
        }
    }
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
            .tintColor(.red)
    }
}

#endif
