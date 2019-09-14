//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public final class PublisherObservation<P: Publisher, S: Scheduler>: ObservableObject, Subscriber {
    public typealias Input = P.Output

    @Published(initialValue: nil) public var lastValue: Result<P.Output, P.Failure>?

    public init(publisher: P, scheduler: S) {
        publisher
            .subscribe(on: scheduler)
            .receive(subscriber: self)
    }

    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        lastValue = .success(input)

        return .unlimited
    }

    public func receive(completion: Subscribers.Completion<P.Failure>) {
        switch completion {
            case .finished:
                lastValue = nil
            case .failure(let failure):
                lastValue = .failure(failure)
        }
    }
}
