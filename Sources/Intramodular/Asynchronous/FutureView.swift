//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that eventually produces its content.
public struct FutureView<Output, Failure: Error, Placeholder: View, Content: View>: View {
    @ObservedObject private var resolution: FutureObservation<Output, Failure>
    
    private let placeholder: Placeholder
    private let makeContent: (Result<Output, Failure>) -> Content
    
    public init(
        _ future: Future<Output, Failure>,
        placeholder: Placeholder,
        content: @escaping (Result<Output, Failure>) -> Content
    ) {
        self.resolution = .init(future: future, scheduler: DispatchQueue.main)
        self.placeholder = placeholder
        self.makeContent = content
    }
    
    public var body: some View {
        return resolution.result.map(makeContent) ?? placeholder
    }
}
