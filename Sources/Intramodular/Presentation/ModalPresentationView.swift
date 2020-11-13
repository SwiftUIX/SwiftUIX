//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _opaque_ModalPresentationView: _opaque_View {
    var preferredSourceViewName: ViewName? { get }
    var presentationStyle: ModalPresentationStyle { get }
}

/// A view that is configured for modal presentation.
public protocol ModalPresentationView: _opaque_ModalPresentationView, View {
    /// The preferred source view for the modal presentation.
    var preferredSourceViewName: ViewName? { get }
    
    /// The presentation style for the modal presentation.
    var presentationStyle: ModalPresentationStyle { get }
}

// MARK: - Implementation -

extension ModalPresentationView {
    public var preferredSourceViewName: ViewName? {
        nil
    }
    
    public var presentationStyle: ModalPresentationStyle {
        .automatic
    }
}
