//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents navigated content when triggered.
public struct NavigationPresentationLink<Label: View, Destination: View>: View {
    @State private var isActive: Bool = false
    
    private let destination: Destination
    private let label: Label
    
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    public var body: some View {
        NavigationLink(
            destination: destination
                .environment(\.presentationManager, NavigationPresentationManager(isActive: $isActive)),
            isActive: $isActive,
            label: { label }
        )
    }
}

// MARK: - Auxiliary

public struct NavigationPresentationManager: PresentationManager {
    let isActive: Binding<Bool>
    
    public init(isActive: Binding<Bool>) {
        self.isActive = isActive
    }
    
    public var isPresented: Bool {
        return isActive.wrappedValue
    }
    
    public func dismiss() {
        isActive.wrappedValue = false
    }
}
