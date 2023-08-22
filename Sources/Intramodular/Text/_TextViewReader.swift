//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@available(macOS 11.0, *)
public struct _TextViewReader<Content: View>: View {
    private let content: (_TextViewProxy) -> Content
    
    @PersistentObject private var proxy = _TextViewProxy()
    
    public init(
        @ViewBuilder content: @escaping (_TextViewProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(proxy)
            .environment(\._textViewProxy, Binding(get: { proxy }, set: { proxy = $0 }))
    }
}

public final class _TextViewProxy: Equatable, ObservableObject {
    let _base = WeakReferenceBox<AppKitOrUIKitTextView>(nil)
    
    var _fakeTextCursor = _TextCursorTracking(owner: nil)
    
    var base: (any _PlatformTextView_Type)? {
        get {
            _base.wrappedValue.map({ $0 as! any _PlatformTextView_Type })
        } set {
            objectWillChange.send()
            
            _base.wrappedValue = newValue
        }
    }
    
    public var textCursor: _TextCursorTracking {
        base?._trackedTextCursor ?? _fakeTextCursor
    }
    
    fileprivate init() {
        
    }
    
    public static func == (lhs: _TextViewProxy, rhs: _TextViewProxy) -> Bool {
        lhs.base === rhs.base
    }
}

// MARK: - Auxiliary

extension _TextViewProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<_TextViewProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _textViewProxy: Binding<_TextViewProxy>? {
        get {
            self[_TextViewProxy.EnvironmentKey.self]
        } set {
            self[_TextViewProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
