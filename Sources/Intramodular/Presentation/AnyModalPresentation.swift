//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    
    public let id = UUID()
    public let content: EnvironmentalAnyView
    
    let resetBinding: () -> ()
    
    init(_ content: EnvironmentalAnyView) {
        self.content = content
        self.resetBinding = { }
    }
    
    init<V: View>(
        content: V,
        contentName: ViewName?,
        presentationStyle: ModalViewPresentationStyle,
        isModalDismissable: @escaping () -> Bool = { true },
        onPresent: @escaping () -> Void = { },
        onDismiss: @escaping () -> Void = { },
        resetBinding: @escaping () -> ()
    ) {
        self.content = EnvironmentalAnyView(content)
            .modalPresentationStyle(presentationStyle)
            .isModalDismissable(isModalDismissable)
            .onPresent(perform: onPresent)
            .onDismiss(perform: onDismiss)
            .name(contentName)
        
        self.resetBinding = resetBinding
    }
}

// MARK: - Protocol Implementations -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        return lhs.id == rhs.id
    }
}
