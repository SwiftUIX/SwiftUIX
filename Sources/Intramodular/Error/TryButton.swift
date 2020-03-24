//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct TryButton<Label: View>: View {
    private let action: () throws -> ()
    private let label: Label
    
    @State var error: Error?
    
    public init(action: @escaping () throws -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: trigger) {
            label
        }
        .preference(
            key: ErrorContextPreferenceKey.self,
            value: error.map({ .init([$0]) }) ?? .init()
        )
    }
    
    public func trigger() {
        error = nil
        
        do {
            try action()
        } catch {
            self.error = error
        }
    }
}
