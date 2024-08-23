//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A view that eventually produces its content.
@_documentation(visibility: internal)
public struct PublisherOutputView<P: Publisher, Placeholder: View, Content: View>: View {
    public typealias SubscriptionPolicy = _PublisherObserver<P, DispatchQueue>.SubscriptionPolicy
    
    @PersistentObject private var observer: _PublisherObserver<P, DispatchQueue>
    
    private let subscriptionPolicy: SubscriptionPolicy
    private let placeholder: Placeholder
    private let makeContent: (Result<P.Output, P.Failure>) -> Content
    
    public init(
        publisher: P,
        policy subscriptionPolicy: SubscriptionPolicy = .immediate,
        placeholder: Placeholder,
        @ViewBuilder content: @escaping (Result<P.Output, P.Failure>) -> Content
    ) {
        self._observer = .init(
            wrappedValue: .init(
                publisher: publisher,
                scheduler: DispatchQueue.main,
                subscriptionPolicy: subscriptionPolicy
            )
        )
        self.subscriptionPolicy = subscriptionPolicy
        self.placeholder = placeholder
        self.makeContent = content
    }
    
    public var body: some View {
        ZStack {
            ZeroSizeView().onAppear {
                if subscriptionPolicy == .deferred {
                    observer.attach()
                }
            }
            .accessibility(hidden: true)
            
            if let lastValue = observer.lastValue {
                makeContent(lastValue)
            } else {
                placeholder
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
