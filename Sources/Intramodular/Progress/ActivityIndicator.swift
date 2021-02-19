//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that shows that a task is in progress.
public struct ActivityIndicator {
    public enum Style {
        case medium
        case large
    }
    
    private var isAnimated: Bool = true
    private var style: Style?
    
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
        if let style = style {
            uiView.style = .init(style)
        }
        
        uiView.color = tintUIColor ?? context.environment.tintColor?.toUIColor()
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
    
    public func style(_ style: Style?) -> Self {
        then({ $0.style = style })
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
    public typealias NSViewType = NSProgressIndicator
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSProgressIndicator()
        
        nsView.isIndeterminate = true
        nsView.style = .spinning
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        isAnimated ? nsView.startAnimation(self) : nsView.stopAnimation(self)
    }
}

#endif

// MARK: - API -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ActivityIndicator {
    public func animated(_ isAnimated: Bool) -> ActivityIndicator {
        then({ $0.isAnimated = isAnimated })
    }
}

#endif

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIActivityIndicatorView.Style {
    public init(_ style: ActivityIndicator.Style) {
        switch style {
            case .medium:
                self = .medium
            case .large:
                self = .large
        }
    }
}

#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
            .tintColor(UIColor.red)
    }
}

#endif
