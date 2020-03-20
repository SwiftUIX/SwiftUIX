//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public let id = UUID()
    
    let content: () -> EnvironmentalAnyView
    let contentName: ViewName?
    
    let completion: () -> ()
    let shouldDismiss: () -> Bool
    let onDismiss: () -> Void
    let resetBinding: () -> ()
    
    let animated: Bool
    let presentationStyle: ModalViewPresentationStyle
    
    init(_ view: EnvironmentalAnyView) {
        fatalError()
    }
    
    init<V: View>(
        content: @escaping () -> V,
        contentName: ViewName?,
        completion: @escaping () -> () = { },
        shouldDismiss: @escaping () -> Bool,
        onDismiss: @escaping () -> Void,
        resetBinding: @escaping () -> (),
        animated: Bool = true,
        presentationStyle: ModalViewPresentationStyle
    ) {
        self.content = { .init(content()) }
        self.contentName = contentName
        self.completion = completion
        self.shouldDismiss = shouldDismiss
        self.onDismiss = onDismiss
        self.animated = animated
        self.presentationStyle = presentationStyle
        self.resetBinding = resetBinding
    }
}

// MARK: - Protocol Implementations -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        return lhs.id == rhs.id
    }
}
