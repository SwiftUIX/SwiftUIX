//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public typealias PreferenceKey = TakeLastPreferenceKey<AnyModalPresentation>
    
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
}

extension AnyModalPresentation {
    public var presentationStyle: ModalPresentationStyle {
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
    public func isModalInPresentation(_ value: Bool) -> some View {
        modifier(_SetIsModalInPresentation(isModalInPresentation: value))
    }
}

// MARK: - Auxiliary Implementation -

struct _IsModalInPresentation: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct _SetIsModalInPresentation: ViewModifier {
    let isModalInPresentation: Bool
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @State var viewControllerBox = WeakReferenceBox<AppKitOrUIKitViewController>(nil)
    #endif
    
    func body(content: Content) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return content.onAppKitOrUIKitViewControllerResolution { viewController in
            viewControllerBox.value = viewController.root ?? viewController
            viewControllerBox.value?.isModalInPresentation = isModalInPresentation
        }
        .preference(key: _IsModalInPresentation.self, value: isModalInPresentation)
        .onChange(of: isModalInPresentation) { isModalInPresentation in
            viewControllerBox.value?.isModalInPresentation = isModalInPresentation
        }
        #else
        return content.preference(key: _IsModalInPresentation.self, value: isModalInPresentation)
        #endif
    }
}
