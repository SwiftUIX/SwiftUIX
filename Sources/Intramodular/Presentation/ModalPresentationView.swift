//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_ModalPresentationView: opaque_View {
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    var presentationStyle: ModalViewPresentationStyle { get }
    var isModalPresentationAnimated: Bool { get }
    var isModalDismissable: Bool { get }

    func onPresent()
    func onDismiss()
}

/// A view that is configured for modal presentation.
public protocol ModalPresentationView: opaque_ModalPresentationView, View {
    /// The environment to build for the modal presentation.
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    
    /// The presentation style for the modal presentation.
    var presentationStyle: ModalViewPresentationStyle { get }
    
    /// Whether the modal presentation is animated or not.
    var isModalPresentationAnimated: Bool { get }
    
    /// Whether the modal is dismissable or not.
    var isModalDismissable: Bool { get }
    
    func onPresent()
    func onDismiss()
}

// MARK: - Implementation -

extension ModalPresentationView {
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalViewPresentationStyle {
        .automatic
    }
    
    public var isModalPresentationAnimated: Bool {
        return true
    }
    
    public var isModalDismissable: Bool {
        return true
    }
    
    public func onPresent() {
        
    }
    
    public func onDismiss() {
        
    }
}
