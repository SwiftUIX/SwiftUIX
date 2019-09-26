//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that eventually produces its content.
public struct PublisherView<P: Publisher, Placeholder: View, Content: View>: View {
    public enum SubscriptionPolicy {
        case immediate
        case delayed
    }
    
    @ObservedObject private var observation: PublisherObservation<P, DispatchQueue>
    
    private let subscriptionPolicy: SubscriptionPolicy
    private let placeholder: Placeholder
    private let makeContent: (Result<P.Output, P.Failure>) -> Content
    
    public init(
        publisher: P,
        policy: SubscriptionPolicy,
        placeholder: Placeholder,
        content: @escaping (Result<P.Output, P.Failure>) -> Content
    ) {
        self.observation = .init(publisher: publisher, scheduler: DispatchQueue.main)
        self.subscriptionPolicy = policy
        self.placeholder = placeholder
        self.makeContent = content
        
        if self.subscriptionPolicy == .immediate {
            self.observation.attach()
        }
    }
    
    public var body: some View {
        Group {
            observation.lastValue.map(makeContent) ?? placeholder
        }.onAppear {
            if self.subscriptionPolicy == .delayed {
                self.observation.attach()
            }
        }
    }
}
