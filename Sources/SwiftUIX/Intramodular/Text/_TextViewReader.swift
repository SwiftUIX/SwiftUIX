//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

@_spi(Internal)
public enum _SwiftUIX_TextEditorEvent: Hashable {
    case insert(text: NSAttributedString, range: NSRange?)
    case delete(text: NSAttributedString, range: NSRange)
    case replace(text: NSAttributedString, range: NSRange)
    case append(text: NSAttributedString)
    
    public var text: String {
        switch self {
            case .insert(let text, _):
                return text.string
            case .delete(let text, _):
                return text.string
            case .replace(let text, _):
                return text.string
            case .append(let text):
                return text.string
        }
    }
}

@available(macOS 11.0, *)
public struct _TextViewReader<Content: View>: View {
    private let content: (_TextEditorProxy) -> Content
    
    @PersistentObject private var proxy = _TextEditorProxy()
    
    public init(
        @ViewBuilder content: @escaping (_TextEditorProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        content(proxy)
            .environment(\._textViewProxy, Binding(get: { proxy }, set: { proxy = $0 }))
    }
}

public final class _TextEditorProxy: Equatable, ObservableObject {
    private let _base = WeakReferenceBox<AppKitOrUIKitTextView>(nil)
    private var _fakeTextCursor = _TextCursorTracking(owner: nil)
    
    @_spi(Internal)
    public var base: (any _PlatformTextView_Type)? {
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
    
    @_spi(Internal)
    public var _textEditorEventsPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never>? {
        base?._textEditorEventPublisher
    }
    
    fileprivate init() {
        
    }
    
    public static func == (lhs: _TextEditorProxy, rhs: _TextEditorProxy) -> Bool {
        lhs.base === rhs.base
    }
}

// MARK: - Auxiliary

extension _TextEditorProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static let defaultValue: Binding<_TextEditorProxy>? = nil
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _textViewProxy: Binding<_TextEditorProxy>? {
        get {
            self[_TextEditorProxy.EnvironmentKey.self]
        } set {
            self[_TextEditorProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
