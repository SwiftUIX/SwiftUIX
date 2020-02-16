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
    
    @Environment(\.tintColor) private var tintColor
    
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
        
        if #available(iOS 13.1, *) {
            uiView.color = tintColor?.toUIColor()
            uiView.tintColor = tintColor?.toUIColor()
        }
        
        isAnimated ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
    public func animated(_ isAnimated: Bool) -> ActivityIndicator {
        then({ $0.isAnimated = isAnimated })
    }
    
    public func style(_ style: Style?) -> ActivityIndicator {
        then({ $0.style = style })
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

// MARK: - Helpers -

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
