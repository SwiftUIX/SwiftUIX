//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that eventually produces its content.
public struct PublisherView<P: Publisher, Placeholder: View, Content: View>: View {
    @ObservedObject private var observation: PublisherObservation<P, DispatchQueue>

    private let placeholder: Placeholder
    private let makeContent: (Result<P.Output, P.Failure>) -> Content

    public init(
        _ publisher: P,
        placeholder: Placeholder,
        content: @escaping (Result<P.Output, P.Failure>) -> Content
    ) {
        self.observation = .init(publisher: publisher, scheduler: DispatchQueue.main)
        self.placeholder = placeholder
        self.makeContent = content
    }

    public var body: some View {
        return observation.lastValue.map(makeContent) ?? placeholder
    }
}
