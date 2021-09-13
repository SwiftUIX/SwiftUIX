//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public final class PublisherObserver<P: Publisher, S: Scheduler>: ObservableObject, Subscriber {
    public enum SubscriptionPolicy {
        case immediate
        case delayed
    }
    
    public typealias Input = P.Output
    
    private let publisher: P
    private let scheduler: S
    private var subscription: Subscription?
    
    @Published public var lastValue: Result<P.Output, P.Failure>?
    
    public init(publisher: P, scheduler: S, subscriptionPolicy: SubscriptionPolicy) {
        self.publisher = publisher
        self.scheduler = scheduler
        
        if subscriptionPolicy == .immediate {
            attach()
        }
    }
    
    public func receive(subscription: Subscription) {
        self.subscription = subscription
        
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: Input) -> Subscribers.Demand {
        lastValue = .success(input)
        
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<P.Failure>) {
        switch completion {
            case .finished:
                break
            case .failure(let failure):
                lastValue = .failure(failure)
        }
    }
    
    /// Attach the receiver to the target publisher.
    public func attach() {
        guard subscription == nil else {
            return
        }
        
        publisher
            .subscribe(on: scheduler)
            .receive(subscriber: self)
    }
    
    /// Detach the receiver from the target publisher.
    public func detatch() {
        subscription?.cancel()
        subscription = nil
    }
    
    deinit {
        detatch()
    }
}
