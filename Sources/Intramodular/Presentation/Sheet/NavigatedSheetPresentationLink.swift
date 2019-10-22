//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents a sheet of navigated content when triggered.
public struct NavigatedSheetPresentationLink<Destination: View, Label: View>: View {
    public let body: SheetPresentationLink<NavigationView<Destination>, Label>
    
    public init(
        destination: Destination,
        onDismiss: (() -> ())? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.body = .init(
            destination: NavigationView { destination },
            onDismiss: onDismiss,
            label: label
        )
    }
}
