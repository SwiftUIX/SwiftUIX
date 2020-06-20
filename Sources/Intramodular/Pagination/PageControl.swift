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
    
    @usableFromInline
    var defersCurrentPageDisplay: Bool?
    
    @usableFromInline
    var hidesForSinglePage: Bool?
    
    @inlinable
    public init(numberOfPages: Int, currentPage: Binding<Int>) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
    }
}

// MARK: - Protocol Implementations -

extension PageControl: UIViewRepresentable {
    public class Coordinator: NSObject {
        @usableFromInline
        var base: PageControl
        
        @usableFromInline
        init(_ base: PageControl) {
            self.base = base
        }
        
        @inlinable
        @objc public func updateCurrentPage(sender: UIViewType) {
            base.currentPage.wrappedValue = sender.currentPage
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
        context.coordinator.base = self
        
        uiView.currentPage = currentPage.wrappedValue
        uiView.currentPageIndicatorTintColor = currentPageIndicatorTintColor?.toUIColor3()
        uiView.numberOfPages = numberOfPages
        uiView.pageIndicatorTintColor = pageIndicatorTintColor?.toUIColor()
        
        if let hidesForSinglePage = hidesForSinglePage {
            uiView.hidesForSinglePage = hidesForSinglePage
        }
        
        if let defersCurrentPageDisplay = defersCurrentPageDisplay {
            uiView.defersCurrentPageDisplay = defersCurrentPageDisplay
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(self)
    }
}

// MARK: - API -

extension PageControl {
    @inlinable
    public func defersCurrentPageDisplay(_ defersCurrentPageDisplay: Bool) -> Self {
        then({ $0.defersCurrentPageDisplay = defersCurrentPageDisplay })
    }
    
    @inlinable
    public func hidesForSinglePage(_ hidesForSinglePage: Bool) -> Self {
        then({ $0.hidesForSinglePage = hidesForSinglePage })
    }
}

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

#endif
