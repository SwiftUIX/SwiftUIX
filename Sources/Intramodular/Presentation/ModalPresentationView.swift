//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _opaque_ModalPresentationView: _opaque_View {
    var preferredSourceViewName: ViewName? { get }
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    var presentationStyle: ModalPresentationStyle { get }
    var isModalPresentationAnimated: Bool { get }
    var isModalDismissable: Bool { get }
    
    func onPresent()
    func onDismiss()
}

/// A view that is configured for modal presentation.
public protocol ModalPresentationView: _opaque_ModalPresentationView, View {
    /// The preferred source view for the modal presentation.
    var preferredSourceViewName: ViewName? { get }
    
    /// The environment to build for the modal presentation.
    var presentationEnvironmentBuilder: EnvironmentBuilder? { get }
    
    /// The presentation style for the modal presentation.
    var presentationStyle: ModalPresentationStyle { get }
    
    /// Whether the modal presentation is animated or not.
    var isModalPresentationAnimated: Bool { get }
    
    /// Whether the modal is dismissable or not.
    var isModalDismissable: Bool { get }
    
    func onPresent()
    func onDismiss()
}

// MARK: - Implementation -

extension ModalPresentationView {
    public var preferredSourceViewName: ViewName? {
        nil
    }
    
    public var presentationEnvironmentBuilder: EnvironmentBuilder? {
        presentationEnvironmentBuilder
    }
    
    public var presentationStyle: ModalPresentationStyle {
        .automatic
    }
    
    public var isModalPresentationAnimated: Bool {
        true
    }
    
    public var isModalDismissable: Bool {
        true
    }
    
    public func onPresent() {
        
    }
    
    public func onDismiss() {
        
    }
}
