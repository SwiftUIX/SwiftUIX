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
        #if os(iOS) || targetEnvironment(macCatalyst)
        return onAppKitOrUIKitViewControllerResolution {
            $0.isModalInPresentation = value
        }
        .preference(key: IsModalInPresentation.self, value: value)
        #else
        return preference(key: IsModalInPresentation.self, value: value)
        #endif
    }
}

// MARK: - Auxiliary Implementation -

struct IsModalInPresentation: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
