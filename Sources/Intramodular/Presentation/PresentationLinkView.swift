//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol PresentationLinkView: View {
    associatedtype Destination: View
    associatedtype Label: View
    
    init(destination: Destination, @ViewBuilder label: () -> Label)
}

// MARK: - Concrete Implementations -

extension NavigationLink: PresentationLinkView {
    
}
