//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#endif
import Combine
import Swift
import SwiftUI
#if os(iOS)
import UIKit
#endif

/// A value relative to one or multiple coordinate spaces.
@_documentation(visibility: internal)
public struct _CoordinateSpaceRelative<Value: Equatable & Sendable>: Equatable, Sendable {
    private var storage: [_ScreenOrCoordinateSpace: Value] = [:]
    
    private weak var __sourceAppKitOrUIKitWindow: (NSObject & Sendable)?
    
    init(
        storage: [_ScreenOrCoordinateSpace: Value],
        _sourceAppKitOrUIKitWindow: NSObject?
    ) {
        self.storage = storage
        self.__sourceAppKitOrUIKitWindow = _sourceAppKitOrUIKitWindow
    }
    
    public init() {
        
    }
    
    public init(_ value: Value, in space: _ScreenOrCoordinateSpace) {
        self.storage[space] = value
    }
    
    public subscript(
        _ key: _ScreenOrCoordinateSpace
    ) -> Value? {
        get {
            guard let result = storage[key] else {
                return nil
            }
            
            return result
        } set {
            storage[key] = newValue
        }
    }
}

extension _CoordinateSpaceRelative {
    public subscript<T>(
        _ keyPath: KeyPath<Value, T>
    ) -> _CoordinateSpaceRelative<T> {
        get {
            .init(
                storage: self.storage.compactMapValues({ $0[keyPath: keyPath] }),
                _sourceAppKitOrUIKitWindow: __sourceAppKitOrUIKitWindow
            )
        }
    }
    
    @_spi(Internal)
    public subscript<T>(
        _unsafe keyPath: WritableKeyPath<Value, T>
    ) -> T {
        get {
            self.storage.first!.value[keyPath: keyPath]
        } set {
            self.storage.keys.forEach { key in
                self.storage[key]![keyPath: keyPath] = newValue
            }
        }
    }
    
    public func first(
        where predicate: (_ScreenOrCoordinateSpace) -> Bool
    ) -> (_ScreenOrCoordinateSpace, Value)? {
        storage.first(where: { predicate($0.key) })
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension _CoordinateSpaceRelative {
    public var _sourceAppKitOrUIKitWindow: AppKitOrUIKitWindow? {
        get {
            __sourceAppKitOrUIKitWindow as? AppKitOrUIKitWindow
        } set {
            __sourceAppKitOrUIKitWindow = newValue
        }
    }
}
#endif

extension _CoordinateSpaceRelative where Value == CGPoint {
    public func offset(x: CGFloat, y: CGFloat) -> Self {
        var storage = self.storage
        
        for (key, value) in storage {
            switch key {
                case .cocoa:
                    storage[key] = CGPoint(x: value.x + x, y: value.y + y)
                case .coordinateSpace:
                    storage[key] = CGPoint(x: value.x + x, y: value.y + y)
            }
        }
        
        return Self(
            storage: storage,
            _sourceAppKitOrUIKitWindow: __sourceAppKitOrUIKitWindow
        )
    }
    
    public func offset(_ offset: CGPoint) -> Self {
        self.offset(x: offset.x, y: offset.y)
    }
}

extension _CoordinateSpaceRelative where Value == CGRect {
    public static var zero: Self {
        .init(.zero, in: .coordinateSpace(.global))
    }
    
    public var size: CGSize {
        get {
            storage.first!.value.size
        } set {
            storage.keys.forEach { key in
                storage[key]!.size = newValue
            }
        }
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension _CoordinateSpaceRelative where Value == CGRect {
    public var origin: _CoordinateSpaceRelative<CGPoint> {
        get {
            _CoordinateSpaceRelative<CGPoint>(
                storage: storage.mapValues({ $0.origin }),
                _sourceAppKitOrUIKitWindow: self._sourceAppKitOrUIKitWindow
            )
        }
    }
}
#endif

// MARK: - Conformances

extension _CoordinateSpaceRelative: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
        hasher.combine(__sourceAppKitOrUIKitWindow)
    }
}

// MARK: - Supplementary

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
#if os(macOS)
extension AppKitOrUIKitWindow {
    public var _coordinateSpaceRelativeFrame: _CoordinateSpaceRelative<CGRect> {
        var frame = frame
        
        frame.origin.y = Screen.main.height - (frame.origin.y + frame.height)
        
        let result = _CoordinateSpaceRelative(frame, in: .cocoa(screen))
        
        return result
    }
}
#else
extension AppKitOrUIKitWindow {
    public var _coordinateSpaceRelativeFrame: _CoordinateSpaceRelative<CGRect> {
        fatalError("unimplemented")
    }
}
#endif
#endif
#endif
