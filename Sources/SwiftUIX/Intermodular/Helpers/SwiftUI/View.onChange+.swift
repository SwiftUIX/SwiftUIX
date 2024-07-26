//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if swift(>=5.9)
extension View {
    @ViewBuilder
    public func _onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self.onChange(of: value) { oldValue, newValue in
                action(newValue)
            }
        } else {
            onChange(of: value, perform: action)
        }
    }
}
#else
extension View {
    @ViewBuilder
    public func _onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        onChange(of: value, perform: action)
    }
}
#endif

extension View {
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// `onChange` is called on the main thread. Avoid performing long-running
    /// tasks on the main thread. If you need to perform a long-running task in
    /// response to `value` changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure. The previous value may be
    /// captured by the closure to compare it to the new value. For example, in
    /// the following code example, `PlayerView` passes both the old and new
    /// values to the model.
    ///
    ///     struct PlayerView : View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) { [playState] newState in
    ///                 model.playStateDidChange(from: playState, to: newState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that failed the comparison check.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @_disfavoredOverload
    @ViewBuilder
    public func onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            onChange(of: value, perform: action)
        } else {
            _backport_onChange(of: value, perform: action)
        }
        #else
        _backport_onChange(of: value, perform: action)
        #endif
    }
    
    @ViewBuilder
    private func _backport_onChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        OnChangeOfValue(base: self, value: value, action: action)
    }

    @inlinable
    public func _onAppearAndChange<V: Equatable>(
        of value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some View {
        onAppear {
            action(value)
        }
        ._onChange(of: value, perform: action)
    }
}

extension View {
    public func withChangePublisher<Value: Equatable>(
        for value: Value,
        transform: @escaping (AnyPublisher<Value, Never>) -> Cancellable
    ) -> some View {
        modifier(_StreamChangesForValue(value: value, transform: transform))
    }
}

extension View {
    public func onChangeOfFrame(
        threshold: CGFloat? = nil,
        perform action: @escaping (CGSize) -> Void
    ) -> some View {
        modifier(_OnChangeOfFrame(threshold: threshold, action: action, onAppear: false))
    }
    
    public func onAppearAndChangeOfFrame(
        threshold: CGFloat? = nil,
        perform action: @escaping (CGSize) -> Void
    ) -> some View {
        modifier(_OnChangeOfFrame(threshold: threshold, action: action, onAppear: true))
    }
}

// MARK: - Auxiliary

// A modified implementation based on https://stackoverflow.com/questions/58363563/swiftui-get-notified-when-binding-value-changes
private struct OnChangeOfValue<Base: View, Value: Equatable>: View {
    private class ValueBox {
        private var savedValue: Value?
        
        func update(value: Value) -> Bool {
            guard value != savedValue else {
                return false
            }
            
            savedValue = value
            
            return true
        }
    }
    
    let base: Base
    let value: Value
    let action: (Value) -> Void
    
    @State private var valueBox = ValueBox()
    @State private var oldValue: Value?
    
    public var body: some View {
        if valueBox.update(value: value) {
            DispatchQueue.main.async {
                action(value)
                
                oldValue = value
            }
        }
        
        return base
    }
}

private struct _StreamChangesForValue<Value: Equatable>: ViewModifier {
    let value: Value
    let transform: (AnyPublisher<Value, Never>) -> Cancellable
    
    @ViewStorage private var valuePublisher = PassthroughSubject<Value, Never>()
    @ViewStorage private var subscription: Cancellable?
    @ViewStorage private var cancellable: AnyCancellable?
    
    func body(content: Content) -> some View {
        content
            .background {
                ZeroSizeView()
                    ._onChange(of: value) { newValue in
                        subscribeIfNecessary()
                        
                        valuePublisher.send(newValue)
                    }
                    .onAppear {
                        subscribeIfNecessary()
                    }
                    .allowsHitTesting(false)
                    .accessibility(hidden: true)
            }
    }
    
    private func subscribeIfNecessary() {
        if subscription == nil {
            let subscription = transform(valuePublisher.eraseToAnyPublisher())
            
            self.subscription = subscription
            self.cancellable = .init(subscription.cancel)
        }
    }
}

private struct _OnChangeOfFrame: ViewModifier {
    let threshold: CGFloat?
    let action: (CGSize) -> Void
    let onAppear: Bool

    @ViewStorage var oldSize: CGSize? = nil
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                ZeroSizeView()
                    .onAppear {
                        self.oldSize = proxy.size
                        
                        if onAppear {
                            self.action(proxy.size)
                        }
                    }
                    ._onChange(of: proxy.size) { newSize in
                        if let oldSize {
                            if let threshold {
                                guard !oldSize._isNearlyEqual(to: newSize, threshold: threshold) else {
                                    return
                                }
                            } else {
                                guard oldSize != newSize else {
                                    return
                                }
                            }
                            
                            action(newSize)
                            
                            self.oldSize = newSize
                        } else {
                            self.oldSize = newSize
                        }
                    }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}

extension View {
    public func _onAvailability<Value>(
        of value: Value?,
        operation: @escaping (Value) -> Void
    ) -> some View {
        self._onChange(of: value != nil) { [value] isNotNil in
            guard let value = value else {
                return
            }
            
            assert(isNotNil)
            
            operation(value)
        }
    }
}
