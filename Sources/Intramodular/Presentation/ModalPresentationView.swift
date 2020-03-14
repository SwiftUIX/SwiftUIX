//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that is configured for modal presentation.
public protocol ModalPresentationView: View {
    /// The environment to build for the modal presentation.
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    
    /// The presentation style for the modal presentation.
    var presentationStyle: ModalViewPresentationStyle { get }
}

extension ModalPresentationView {
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalViewPresentationStyle {
        .automatic
    }
}
