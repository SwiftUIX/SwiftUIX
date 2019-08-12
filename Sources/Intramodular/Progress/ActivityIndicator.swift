//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that shows that a task is in progress.
public struct ActivityIndicator {
    private var isAnimating: Bool = true

    public init() {

    }

    public func animating(_ isAnimating: Bool) -> ActivityIndicator {
        var result = self

        result.isAnimating = isAnimating

        return result
    }
}

#if os(iOS)

import UIKit

extension ActivityIndicator: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    public typealias UIViewType = UIActivityIndicatorView

    public func makeUIView(context: Context) -> UIViewType {
        UIActivityIndicatorView(style: .medium)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
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
        isAnimating ? nsView.startAnimation(self) : nsView.stopAnimation(self)
    }
}

#endif
