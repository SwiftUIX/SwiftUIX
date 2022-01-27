//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol PresentationLinkView: View {
    associatedtype Destination: View
    associatedtype Label: View
    
    init(
        destination: Destination,
        onDismiss: (() -> Void)?,
        @ViewBuilder label: () -> Label
    )
}

// MARK: - Extensions -

extension PresentationLinkView {
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.init(destination: destination, onDismiss: nil, label: label)
    }
    
    public init(
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(destination: destination(), onDismiss: nil, label: label)
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        @ViewBuilder destination: () -> Destination
    ) where Label == Text {
        self.init(destination: destination(), label: { Text(title) })
    }
}

extension PresentationLinkView where Label == Image {
    public init(
        systemImage: SFSymbolName,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.init(destination: destination(), onDismiss: nil) {
            Image(systemName: systemImage)
        }
    }
}

/*@available(iOS 14.0, OSX 10.16, tvOS 14.0, watchOS 7.0, *)
extension PresentationLinkView where Label == SwiftUI.Label<Text, Image> {
    public init<S: StringProtocol>(
        _ title: S,
        systemImage: SFSymbolName,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.init(destination: destination(), onDismiss: nil) {
            Label(title, systemImage: systemImage)
        }
    }
}*/
