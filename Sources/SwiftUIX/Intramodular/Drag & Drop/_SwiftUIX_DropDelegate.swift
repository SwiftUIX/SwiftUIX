//
// Copyright (c) Vatsal Manot
//

import _SwiftUIX
import Swift
import SwiftUI

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol _SwiftUIX_DropDelegate<DropInfoType> {
    associatedtype DropInfoType: _SwiftUI_DropInfoProtocol
    
    @MainActor func validateDrop(info: DropInfoType) -> Bool
    @MainActor func performDrop(info: DropInfoType) -> Bool
    @MainActor func dropEntered(info: DropInfoType)
    
    @MainActor func dropUpdated(info: DropInfoType) -> DropProposal?
    @MainActor func dropExited(info: DropInfoType)
}

#if os(iOS) || os(macOS) || os(visionOS)
@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@_documentation(visibility: internal)
public struct _SwiftUIX_AnyDropDelegate<DropInfo: _SwiftUI_DropInfoProtocol>: _SwiftUIX_DropDelegate {
    private var _validateDrop: (_: DropInfo) -> Bool = { _ in true }
    private var _onDrop: (_: DropInfo) -> Bool = { _ in false }
    private var _onDropEnter: (_: DropInfo) -> Void = { _ in }
    private var _onDropUpdate: (_: DropInfo) -> DropProposal? = { _ in nil }
    private var _onDropExit: (_: DropInfo) -> Void = { _ in }
 
    public init(
        validateDrop: @escaping (_: DropInfo ) -> Bool,
        onDrop: @escaping (_: DropInfo) -> Bool,
        onDropEnter: @escaping (_: DropInfo) -> Void,
        onDropUpdate: @escaping (_: DropInfo) -> DropProposal?,
        onDropExit: @escaping (_: DropInfo) -> Void
    ) {
        self._validateDrop = validateDrop
        self._onDrop = onDrop
        self._onDropEnter = onDropEnter
        self._onDropUpdate = onDropUpdate
        self._onDropExit = onDropExit
    }
    
    public init(
        validateDrop: @escaping (_: DropInfo ) -> Bool,
        onDrop: @escaping (_: DropInfo) -> Bool,
        onDropEnter: @escaping (_: DropInfo) -> Void,
        onDropUpdate: @escaping (_: DropInfo) -> DropProposal?,
        onDropExit: @escaping (_: DropInfo) -> Void
    ) where DropInfo == _SwiftUIX_DropInfo {
        self._validateDrop = validateDrop
        self._onDrop = onDrop
        self._onDropEnter = onDropEnter
        self._onDropUpdate = onDropUpdate
        self._onDropExit = onDropExit
    }
    
    public func validateDrop(info: DropInfo) -> Bool {
        _validateDrop(info)
    }
    
    public func performDrop(info: DropInfo) -> Bool {
        _onDrop(info)
    }
    
    public func dropEntered(info: DropInfo) {
        _onDropEnter(info)
    }
    
    public func dropUpdated(info: DropInfo) -> DropProposal? {
        return _onDropUpdate(info)
    }
    
    public func dropExited(info: DropInfo) {
        _onDropExit(info)
    }
}
#endif
