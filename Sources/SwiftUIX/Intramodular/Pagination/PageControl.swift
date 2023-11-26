//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A SwiftUI port of `UIPageControl`.
@frozen
public struct PageControl {
    public let numberOfPages: Int
    public let currentPage: Binding<Int>
    
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

// MARK: - Conformances

extension PageControl: UIViewRepresentable {
    public typealias UIViewType = UIPageControl
    
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
    
    @inlinable
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIPageControl()
        
        uiView.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        
        return uiView
    }
    
    @inlinable
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.base = self
        
        uiView.currentPage = currentPage.wrappedValue
        uiView.currentPageIndicatorTintColor = context.environment.currentPageIndicatorTintColor?.toUIColor()
        uiView.numberOfPages = numberOfPages
        uiView.pageIndicatorTintColor = context.environment.pageIndicatorTintColor?.toUIColor()
        
        if #available(iOS 14.0, tvOS 14.0, *) {
            if let backgroundStyle = context.environment.pageControlBackgroundStyle {
                uiView.backgroundStyle = backgroundStyle
            }
        }
        
        if let hidesForSinglePage = hidesForSinglePage {
            uiView.hidesForSinglePage = hidesForSinglePage
        }
        
        #if !os(visionOS)
        if let defersCurrentPageDisplay = defersCurrentPageDisplay {
            uiView.defersCurrentPageDisplay = defersCurrentPageDisplay
        }
        #endif
    }
    
    @inlinable
    public func makeCoordinator() -> Coordinator {
        .init(self)
    }
}

// MARK: - API

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
    @available(iOS 14.0, tvOS 14.0, *)
    @inlinable
    public func pageControlBackgroundStyle(_ backgroundStyle: UIPageControl.BackgroundStyle) -> some View {
        environment(\.pageControlBackgroundStyle, backgroundStyle)
    }
    
    @inlinable
    public func pageIndicatorTintColor(_ color: Color) -> some View {
        environment(\.pageIndicatorTintColor, color)
    }
    
    @inlinable
    public func currentPageIndicatorTintColor(_ color: Color) -> some View {
        environment(\.currentPageIndicatorTintColor, color)
    }
}

// MARK: - Auxiliary

extension PageControl {
    @available(iOS 14.0, tvOS 14.0, *)
    @usableFromInline
    struct BackgroundStyleEnvironmentKey: EnvironmentKey {
        @usableFromInline
        static let defaultValue: UIPageControl.BackgroundStyle? = nil
    }
    
    @usableFromInline
    struct TintColorEnvironmentKey: EnvironmentKey {
        @usableFromInline
        static let defaultValue: Color? = nil
    }
    
    @usableFromInline
    struct CurrentTintColorEnvironmentKey: EnvironmentKey {
        @usableFromInline
        static let defaultValue: Color? = nil
    }
}

extension EnvironmentValues {
    @available(iOS 14.0, tvOS 14.0, *)
    @inlinable
    public var pageControlBackgroundStyle: UIPageControl.BackgroundStyle? {
        get {
            self[PageControl.BackgroundStyleEnvironmentKey.self]
        } set {
            self[PageControl.BackgroundStyleEnvironmentKey.self] = newValue
        }
    }
    
    @inlinable
    public var pageIndicatorTintColor: Color? {
        get {
            self[PageControl.TintColorEnvironmentKey.self]
        } set {
            self[PageControl.TintColorEnvironmentKey.self] = newValue
        }
    }
    
    @inlinable
    public var currentPageIndicatorTintColor: Color? {
        get {
            self[PageControl.CurrentTintColorEnvironmentKey.self]
        } set {
            self[PageControl.CurrentTintColorEnvironmentKey.self] = newValue
        }
    }
}

#endif
