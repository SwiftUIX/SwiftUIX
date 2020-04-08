//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageControl`.
public struct PageControl {
    public let numberOfPages: Int
    public let currentPage: Binding<Int>
    
    @Environment(\.pageIndicatorTintColor) private var pageIndicatorTintColor
    @Environment(\.currentPageIndicatorTintColor) private var currentPageIndicatorTintColor
    
    public init(numberOfPages: Int, currentPage: Binding<Int>) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
    }
}

// MARK: - Protocol Implementations -

extension PageControl: UIViewRepresentable {
    public class Coordinator: NSObject {
        public var parent: PageControl
        
        public init(_ parent: PageControl) {
            self.parent = parent
        }
        
        @objc public func updateCurrentPage(sender: UIViewType) {
            parent.currentPage.wrappedValue = sender.currentPage
        }
    }
    
    public typealias UIViewType = UIPageControl
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIPageControl()
        
        uiView.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.currentPage = currentPage.wrappedValue
        uiView.currentPageIndicatorTintColor = currentPageIndicatorTintColor?.toUIColor3()
        uiView.numberOfPages = numberOfPages
        uiView.pageIndicatorTintColor = pageIndicatorTintColor?.toUIColor()
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(self)
    }
}

// MARK: - Auxiliary Implementation -

extension PageControl {
    struct TintColorEnvironmentKey: EnvironmentKey {
        static let defaultValue: Color? = nil
    }
    
    struct CurrentTintColorEnvironmentKey: EnvironmentKey {
        static let defaultValue: Color? = nil
    }
}

extension EnvironmentValues {
    public var pageIndicatorTintColor: Color? {
        get {
            self[PageControl.TintColorEnvironmentKey]
        } set {
            self[PageControl.TintColorEnvironmentKey] = newValue
        }
    }
    
    public var currentPageIndicatorTintColor: Color? {
        get {
            self[PageControl.CurrentTintColorEnvironmentKey]
        } set {
            self[PageControl.CurrentTintColorEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func pageIndicatorTintColor(_ color: Color) -> some View {
        environment(\.pageIndicatorTintColor, color)
    }
    
    @inlinable
    public func currentPageIndicatorTintColor(_ color: Color) -> some View {
        environment(\.currentPageIndicatorTintColor, color)
    }
}

#endif
