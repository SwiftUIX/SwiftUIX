//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS)

import Foundation
import SwiftUI
import UIKit

public protocol _SwiftUIX_AppKitOrUIKitHostingViewProtocol<HostedContent>: AppKitOrUIKitView {
    associatedtype HostedContent: SwiftUI.View
    
    var _SwiftUIX_hostedContent: HostedContent { get set }
}

@available(iOS 16.0, tvOS 16.0, visionOS 1.0, *)
open class _SwiftUIX_AppKitOrUIKitHostingView<Content: View>: _UIHostingView<Content> {
    
}

#endif

#if os(macOS)

import AppKit
import Foundation
import SwiftUI

public protocol _SwiftUIX_AppKitOrUIKitHostingViewProtocol<HostedContent>: AppKitOrUIKitView, NSObjectProtocol {
    associatedtype HostedContent: SwiftUI.View
    
    var _SwiftUIX_hostedContent: HostedContent { get set }
    
    @available(macOS 13.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    var sizingOptions: NSHostingSizingOptions { get set }
}

open class _SwiftUIX_AppKitOrUIKitHostingView<Content: View>: NSHostingView<Content>, _SwiftUIX_AppKitOrUIKitHostingViewProtocol {
    public typealias HostedContent = Content
    
    open var _SwiftUIX_hostedContent: HostedContent {
        get {
            self.rootView
        } set {
            self.rootView = newValue
        }
    }
}

#endif
