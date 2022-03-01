//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public var id: AnyHashable
    public var content: AnyPresentationView
    public var onDismiss: () -> Void
    public var reset: () -> Void
    
    init(
        id: AnyHashable = UUID(),
        content: AnyPresentationView,
        onDismiss: @escaping () -> Void = { },
        reset: @escaping () -> Void = { }
    ) {
        self.id = id
        self.content = content
        self.onDismiss = onDismiss
        self.reset = reset
    }
    
    public func environment<T>(_ key: WritableKeyPath<EnvironmentValues, T>, _ value: T) -> Self {
        var result = self
        
        result.content.environmentInPlace(.value(value, forKey: key))
        
        return result
    }
}

extension AnyModalPresentation {
    public var style: ModalPresentationStyle {
        content.modalPresentationStyle
    }
    
    public var popoverAttachmentAnchorBounds: CGRect? {
        content.popoverAttachmentAnchorBounds
    }
    
    public func popoverAttachmentAnchorBounds(_ bounds: CGRect?) -> Self {
        var result = self
        
        result.content = result.content.popoverAttachmentAnchorBounds(bounds)
        
        return result
    }
}

// MARK: - Conformances -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        true
            && lhs.id == rhs.id
            && lhs.popoverAttachmentAnchorBounds == rhs.popoverAttachmentAnchorBounds
    }
}

// MARK: - API -

extension View {
    /// Adds a condition for whether the presented view hierarchy is dismissable.
    public func dismissDisabled(_ value: Bool) -> some View {
        modifier(_SetDismissDisabled(disabled: value))
    }
    
    @available(*, deprecated, renamed: "dismissDisabled")
    public func isModalInPresentation(_ value: Bool) -> some View {
        dismissDisabled(value)
    }
}

// MARK: - Auxiliary Implementation -

extension AnyModalPresentation {
    struct PreferenceKeyValue: Equatable {
        let presentationID: AnyHashable
        let presentation: AnyModalPresentation?
    }
    
    typealias PreferenceKey = TakeLastPreferenceKey<PreferenceKeyValue>
}

struct _DismissDisabled: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct _SetDismissDisabled: ViewModifier {
    let disabled: Bool
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @State var viewControllerBox = WeakReferenceBox<AppKitOrUIKitViewController>(nil)
    #endif
    
    func body(content: Content) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return content.onAppKitOrUIKitViewControllerResolution { [weak viewControllerBox] viewController in
            viewControllerBox?.value = viewController.root ?? viewController
            viewControllerBox?.value?.isModalInPresentation = disabled
        }
        .preference(key: _DismissDisabled.self, value: disabled)
        .onChange(of: disabled) { [weak viewControllerBox] disabled in
            viewControllerBox?.value?.isModalInPresentation = disabled
        }
        #else
        return content.preference(key: _DismissDisabled.self, value: disabled)
        #endif
    }
}
