//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// An observable object suitable for monitoring a `Future`.
public final class FutureObservation<Output, Failure: Error>: ObservableObject, Subscriber {
    public typealias Input = Output
    
    @Published(initialValue: nil) public var result: Result<Output, Failure>?
    
    public init<S: Scheduler>(future: Future<Output, Failure>, scheduler: S) {
        future
            .subscribe(on: scheduler)
            .receive(subscriber: self)
    }
    
    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: Output) -> Subscribers.Demand {
        result = .success(input)
        
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        if case .failure(let failure) = completion {
            result = .failure(failure)
        }
    }
}
