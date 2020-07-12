//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that eventually produces its content.
public struct PublisherOutputView<P: Publisher, Placeholder: View, Content: View>: View {
    public enum SubscriptionPolicy {
        case immediate
        case delayed
    }
    
    @ObservedObject private var observer: PublisherObserver<P, DispatchQueue>
    
    private let policy: SubscriptionPolicy
    private let placeholder: Placeholder
    private let makeContent: (Result<P.Output, P.Failure>) -> Content
    
    public init(
        publisher: P,
        policy: SubscriptionPolicy,
        placeholder: Placeholder,
        content: @escaping (Result<P.Output, P.Failure>) -> Content
    ) {
        self.observer = .init(publisher: publisher, scheduler: DispatchQueue.main)
        self.policy = policy
        self.placeholder = placeholder
        self.makeContent = content
        
        if self.policy == .immediate {
            self.observer.attach()
        }
    }
    
    public var body: some View {
        (observer.lastValue.map(makeContent) ?? placeholder)
          .onAppear {
              if self.policy == .delayed {
                  self.observer.attach()
              }
          }
    }
}
