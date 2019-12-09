//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct CocoaPresentation: Equatable, Identifiable {
    let id = UUID()
    let content: () -> AnyView
    let onDismiss: (() -> Void)?
    let shouldDismiss: () -> Bool
    let resetBinding: () -> Void
    let presentationStyle: ModalViewPresentationStyle
    
    static func == (lhs: CocoaPresentation, rhs: CocoaPresentation) -> Bool {
        return lhs.id == rhs.id
    }
}

#endif

