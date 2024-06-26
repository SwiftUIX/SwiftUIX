//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

public protocol _CocoaHostingControllerOrView: AppKitOrUIKitResponder {
    var _SwiftUIX_cancellables: [AnyCancellable] { get set }
    var _configuration: CocoaHostingControllerConfiguration { get set }
    var _hostingViewConfigurationFlags: Set<_CocoaHostingViewConfigurationFlag> { get }
    var _hostingViewStateFlags: Set<_CocoaHostingViewStateFlag> { get }
    var _observedPreferenceValues: _ObservedPreferenceValues { get }
    
    func withCriticalScope<Result>(
        _ flags: Set<_CocoaHostingViewConfigurationFlag>,
        perform action: () -> Result
    ) -> Result
}

public protocol CocoaViewController: AppKitOrUIKitViewController {
    func _namedViewDescription(for _: AnyHashable) -> _NamedViewDescription?
    func _setNamedViewDescription(_: _NamedViewDescription?, for _: AnyHashable)
    func _disableSafeAreaInsetsIfNecessary()
    
    func _SwiftUIX_sizeThatFits(in size: CGSize) -> CGSize
}

// MARK: - API

extension _CocoaHostingControllerOrView {
    public var _measuredSizePublisher: AnyPublisher<CGSize, Never> {
        _configuration._measuredSizePublisher.eraseToAnyPublisher()
    }

    public func _observePreferenceKey<Key: PreferenceKey>(
        _ key: Key.Type,
        _ operation: ((Key.Value) -> Void)? = nil
    ) where Key.Value: Equatable {
        guard !_configuration.observedPreferenceKeys.contains(where: { $0 == key }) else {
            return
        }
        
        _configuration.observedPreferenceKeys.append(key)
        _configuration.preferenceValueObservers.append(
            PreferenceValueObserver<Key>(store: self._observedPreferenceValues)
                .eraseToAnyViewModifier()
        )
        
        if let operation {
            _observedPreferenceValues.observe(key, operation)
        }
    }
    
    public subscript<Key: PreferenceKey>(
        _ key: Key.Type
    ) -> Key.Value? where Key.Value: Equatable {
        self._observedPreferenceValues[key]
    }
}

#endif
