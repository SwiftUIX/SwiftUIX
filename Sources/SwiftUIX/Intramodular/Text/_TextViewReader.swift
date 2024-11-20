//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

@_documentation(visibility: internal)
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
@_documentation(visibility: internal)
public struct _TextViewReader<Content: View>: View {
    private let content: (_TextEditorProxy) -> Content
    
    @PersistentObject private var proxy = _TextEditorProxy()
    
    public init(
        @ViewBuilder content: @escaping (_TextEditorProxy) -> Content
    ) {
        self.content = content
    }
    
    public var body: some View {
        let proxyBinding = $proxy.binding
        
        content(proxy)
            .environment(\._textViewProxyBinding, .init(wrappedValue: proxyBinding))
    }
}

@_documentation(visibility: internal)
public final class _TextEditorProxy: Hashable, ObservableObject, @unchecked Sendable {
    public typealias _Base = any _SwiftUIX_AnyIndirectValueBox<AppKitOrUIKitTextView?>
    
    let _base = WeakReferenceBox<AppKitOrUIKitTextView>(nil)
    
    private var _fakeTextCursor = _ObservableTextCursor(owner: nil)
    
    @_spi(Internal)
    public var base: (any _PlatformTextViewType)? {
        get {
            _base.wrappedValue.map({ $0 as! any _PlatformTextViewType })
        } set {
            guard _base.wrappedValue !== newValue else {
                return
            }
            
            _objectWillChange_send()
            
            _base.wrappedValue = newValue
        }
    }
    
    public var isFocused: Bool {
        base?._SwiftUIX_isFirstResponder ?? false
    }
    
    public var textCursor: _ObservableTextCursor {
        base?._observableTextCursor ?? _fakeTextCursor
    }
    
    public var _textEditorEventsPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never>? {
        base?._textEditorEventPublisher
    }
    
    fileprivate init() {
        
    }
    
    public static func == (lhs: _TextEditorProxy, rhs: _TextEditorProxy) -> Bool {
        lhs.base === rhs.base
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.base.map({ ObjectIdentifier($0) }))
    }
}

// MARK: - Auxiliary

extension _TextEditorProxy {
    fileprivate struct EnvironmentKey: SwiftUI.EnvironmentKey {
        static var defaultValue: _SwiftUIX_HashableBinding<_TextEditorProxy>.Optional = .init(wrappedValue: nil)
    }
}

extension EnvironmentValues {
    @usableFromInline
    var _textViewProxyBinding: _SwiftUIX_HashableBinding<_TextEditorProxy>.Optional {
        get {
            self[_TextEditorProxy.EnvironmentKey.self]
        } set {
            self[_TextEditorProxy.EnvironmentKey.self] = newValue
        }
    }
}

#endif
