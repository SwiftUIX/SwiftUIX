//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_ModalPresentationView: opaque_View {
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    var presentationStyle: ModalViewPresentationStyle { get }
}

/// A view that is configured for modal presentation.
public protocol ModalPresentationView: opaque_ModalPresentationView, View {
    /// The environment to build for the modal presentation.
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    
    /// The presentation style for the modal presentation.
    var presentationStyle: ModalViewPresentationStyle { get }
}

// MARK: - Implementation -

extension ModalPresentationView {
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalViewPresentationStyle {
        .automatic
    }
}
