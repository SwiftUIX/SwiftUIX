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
        policy: SubscriptionPolicy = .immediate,
        placeholder: Placeholder,
        @ViewBuilder content: @escaping (Result<P.Output, P.Failure>) -> Content
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
        Group {
            observer.lastValue.map(makeContent) ?? placeholder
        }
        .onAppear {
            if self.policy == .delayed {
                self.observer.attach()
            }
        }
    }
}

extension PublisherOutputView where P.Failure == Never {
    public init(
        publisher: P,
        policy: SubscriptionPolicy = .immediate,
        placeholder: Placeholder,
        @ViewBuilder content: @escaping (P.Output) -> Content
    ) {
        self.init(
            publisher: publisher,
            policy: policy,
            placeholder: placeholder
        ) { result in
            switch result {
                case .success(let value):
                    content(value)
            }
        }
    }
    
    public init(
        publisher: P,
        policy: SubscriptionPolicy = .immediate,
        @ViewBuilder content: @escaping (P.Output) -> Content
    ) where Placeholder == EmptyView {
        self.init(
            publisher: publisher,
            policy: policy,
            placeholder: EmptyView(),
            content: content
        )
    }
}
