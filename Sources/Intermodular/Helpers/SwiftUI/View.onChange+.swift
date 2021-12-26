//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

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
}

extension View {
    public func onChangeOfFrame(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(_OnChangeOfFrame(action: action))
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

// MARK: - Auxiliary Implementation -

// A modified implementation based on https://stackoverflow.com/questions/58363563/swiftui-get-notified-when-binding-value-changes
private struct OnChangeOfValue<Base: View, Value: Equatable>: View {
    class ValueBox {
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

private struct _OnChangeOfFrame: ViewModifier {
    let action: (CGSize) -> Void
    
    func body(content: Content) -> some View {
        IntrinsicSizeReader { size in
            content.onChange(of: size, perform: action)
        }
    }
}

private struct _StreamChangesForValue<Value: Equatable>: ViewModifier {
    let value: Value
    let transform: (AnyPublisher<Value, Never>) -> Cancellable
    
    @State private var valuePublisher = PassthroughSubject<Value, Never>()
    @State private var subscription: Cancellable?
    @State private var cancellable: AnyCancellable?
    
    func body(content: Content) -> some View {
        content
            .background {
                ZeroSizeView()
                    .onChange(of: value) { newValue in
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
