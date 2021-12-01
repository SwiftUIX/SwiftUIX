//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

@propertyWrapper
public struct OptionalObservedObject<ObjectType: ObservableObject>: DynamicProperty {
    private let base: ObjectType?

    @State
    fileprivate var container: Container
    @ObservedObject
    fileprivate var observedContainer: Container

    /// The current state value.
    public var wrappedValue: ObjectType? {
        get {
            container.base
        } nonmutating set {
            container.base = newValue
        }
    }

    /// Initialize with the provided initial value.
    public init(wrappedValue value: ObjectType?) {
        let container = Container(base: value)

        self.base = value
        self.container = container
        self.observedContainer = container
    }

    public init() {
        self.init(wrappedValue: nil)
    }

    public mutating func update() {
        withExtendedLifetime(container) {
            withExtendedLifetime(container.base) {
                if base !== container.base {
                    container.base = base
                }

                if container !== observedContainer {
                    let container = self.container

                    observedContainer = container
                }
            }
        }
    }
}

// MARK: - Auxiliary Implementation -

extension OptionalObservedObject {
    fileprivate final class Container: ObservableObject {
        var baseSubscription: AnyCancellable?

        var base: ObjectType? {
            didSet {
                if let oldValue = oldValue, let base = base {
                    if oldValue === base, baseSubscription != nil {
                        return
                    }
                }

                subscribe()
            }
        }

        init(base: ObjectType?) {
            self.base = base

            withExtendedLifetime(self) {
                withExtendedLifetime(base) {
                    subscribe()
                }
            }
        }

        func subscribe() {
            guard let base = base else {
                return
            }

            baseSubscription = base
                .objectWillChange
                .sink(receiveValue: { [weak self] _ in
                    self?.objectWillChange.send()
                })
        }
    }
}
