//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
struct _TextView<Label: View> {
    @Environment(\._textViewConfigurationMutation) private var _textViewConfigurationMutation
    
    @ObservedObject fileprivate var updater: EmptyObservableObject
    
    fileprivate let data: _TextViewDataBinding
    fileprivate let unresolvedTextViewConfiguration: _TextViewConfiguration
            
    init(
        updater: EmptyObservableObject,
        data: _TextViewDataBinding,
        textViewConfiguration: _TextViewConfiguration
    ) {
        self.updater = updater
        self.data = data
        self.unresolvedTextViewConfiguration = textViewConfiguration
    }
}

extension _TextView {
    var resolvedAppKitOrUIKitTextViewClass: AppKitOrUIKitTextView.Type {
        resolvedTextViewConfiguration.customAppKitOrUIKitClassConfiguration?.classProvider.provideClass(labelType: Label.self) ?? _PlatformTextView<Label>.self
    }
    
    var resolvedTextViewConfiguration: _TextViewConfiguration {
        var result = unresolvedTextViewConfiguration
        
        _textViewConfigurationMutation(&result)
        
        return result
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension _TextView: AppKitOrUIKitViewRepresentable {
    typealias AppKitOrUIKitViewType = AppKitOrUIKitTextView
    
    func makeAppKitOrUIKitView(
        context: Context
    ) -> AppKitOrUIKitViewType {
        let view: AppKitOrUIKitViewType
        
        if case .cocoaTextStorage(let textStorage) = data {
            if let textStorage: NSTextStorage = textStorage() {
                if let type: _PlatformTextView<Label>.Type = resolvedTextViewConfiguration.customAppKitOrUIKitClassConfiguration?.classProvider.provideClass(labelType: Label.self) as? _PlatformTextView<Label>.Type {
                    view = type.init(
                        usingTextLayoutManager: false,
                        textStorage: textStorage
                    )
                } else {
                    view = resolvedAppKitOrUIKitTextViewClass._SwiftUIX_initialize(customTextStorage: textStorage)
                }
            } else {
                assertionFailure()
                
                view = resolvedAppKitOrUIKitTextViewClass.init()
            }
        } else {
            if let type: _PlatformTextView<Label>.Type = resolvedAppKitOrUIKitTextViewClass as? _PlatformTextView<Label>.Type {
                view = type.init(
                    usingTextLayoutManager: false,
                    textStorage: nil
                )
            } else {
                view = resolvedAppKitOrUIKitTextViewClass._SwiftUIX_initialize(customTextStorage: nil)
            }
        }
        
        if let _view = view as? _PlatformTextView<Label> {
            _view.representableUpdater = updater
        }
        
        resolvedTextViewConfiguration.customAppKitOrUIKitClassConfiguration?.update(view, context)
        
        if let view = view as? _PlatformTextView<Label> {
            view.data = data
            view.textViewConfiguration = resolvedTextViewConfiguration
            
            view.representableWillAssemble(context: context)
        }
        
        view.delegate = context.coordinator
        
        #if os(iOS) || os(tvOS)
        view.backgroundColor = nil
        #elseif os(macOS)
        view.focusRingType = .none
        #endif
        
        donateProxy(view, context: context)
        
        if context.environment.isEnabled {
            Task.detached(priority: .userInitiated) { @MainActor in
                if (resolvedTextViewConfiguration.isInitialFirstResponder ?? resolvedTextViewConfiguration.isFocused?.wrappedValue) ?? false {
                    view._SwiftUIX_becomeFirstResponder()
                }
            }
        }
        
        return view
    }
    
    func updateAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        donateProxy(view, context: context)
        
        resolvedTextViewConfiguration.customAppKitOrUIKitClassConfiguration?.update(view, context)
        
        if let view = view as? _PlatformTextView<Label> {
            assert(view.representatableStateFlags.contains(.updateInProgress))
                        
            view.representableDidUpdate(
                data: self.data,
                textViewConfiguration: resolvedTextViewConfiguration,
                context: context
            )
        } else {
            _PlatformTextView<Label>.updateAppKitOrUIKitTextView(
                view,
                data: self.data,
                textViewConfiguration: resolvedTextViewConfiguration,
                context: context
            )
        }
    }
    
    static func dismantleAppKitOrUIKitView(
        _ view: AppKitOrUIKitViewType,
        coordinator: Coordinator
    ) {
        guard let view = (view as? (any _PlatformTextViewType)) else {
            return
        }
        
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            view._textEditorProxyBase?.wrappedValue = nil
        }
    }
    
    private func donateProxy(
        _ view: AppKitOrUIKitViewType,
        context: Context
    ) {
        guard let proxyBinding = context.environment._textViewProxyBinding.wrappedValue, let view = view as? _PlatformTextView<Label> else {
            return
        }
        
        if let existing = proxyBinding.wrappedValue.base {
            if existing.representatableStateFlags.contains(.dismantled) {
                proxyBinding.wrappedValue._base.wrappedValue = nil
            }
        }
        
        if proxyBinding.wrappedValue.base !== view {
            Task.detached(priority: .userInitiated) { @MainActor in
                proxyBinding.wrappedValue.base = view
            }
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _TextView {
    class Coordinator: NSObject, UITextViewDelegate {
        var updater: EmptyObservableObject
        var data: _TextViewDataBinding
        var textViewConfiguration: _TextViewConfiguration
        
        init(
            updater: EmptyObservableObject,
            data: _TextViewDataBinding,
            textViewConfiguration: _TextViewConfiguration
        ) {
            self.updater = updater
            self.data = data
            self.textViewConfiguration = textViewConfiguration
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textViewConfiguration.onEditingChanged(true)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let textView = textView as? _PlatformTextView<Label> {
                guard !textView.representatableStateFlags.contains(.dismantled) else {
                    return
                }
            }
            
            let data = textView._currentTextViewData(kind: data.wrappedValue.kind)
            
            guard textView.markedTextRange == nil, data != self.data.wrappedValue else {
                return
            }
            
            self.data.wrappedValue = data
        }
        
        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if textViewConfiguration.dismissKeyboardOnReturn {
                if text == "\n" {
                    DispatchQueue.main.async {
                        #if os(iOS) || os(visionOS)
                        guard textView.isFirstResponder else {
                            return
                        }
                        
                        #if os(visionOS)
                        guard !textView.text.isEmpty else {
                            return
                        }
                        #endif
                        self.textViewConfiguration.onCommit?()
                        
                        textView.resignFirstResponder()
                        #endif
                    }
                    
                    return false
                }
            }
            
            return true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.textViewConfiguration.onEditingChanged(false)
            }
        }
    }
}
#elseif os(macOS)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _TextView {
    class Coordinator: NSObject, NSTextViewDelegate {
        var updater: EmptyObservableObject
        var data: _TextViewDataBinding
        var textViewConfiguration: _TextViewConfiguration
        
        init(
            updater: EmptyObservableObject,
            data: _TextViewDataBinding,
            textViewConfiguration: _TextViewConfiguration
        ) {
            self.updater = updater
            self.data = data
            self.textViewConfiguration = textViewConfiguration
        }
        
        /*func textView(
         _ view: NSTextView,
         write cell: NSTextAttachmentCellProtocol,
         at charIndex: Int,
         to pboard: NSPasteboard,
         type: NSPasteboard.PasteboardType
         ) -> Bool {
         return false // TODO: Implement
         }
         
         func textView(
         _ view: NSTextView,
         writablePasteboardTypesFor cell: NSTextAttachmentCellProtocol,
         at charIndex: Int
         ) -> [NSPasteboard.PasteboardType] {
         return [] // TODO: Implement
         }*/
        
        public func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            return true
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            _ = textView
            
            textViewConfiguration.onEditingChanged(true)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            let data = textView._currentTextViewData(kind: data.wrappedValue.kind)
            
            if let textView = textView as? _PlatformTextView<Label> {
                if !textView._providesCustomSetDataValueMethod {
                    guard data != self.data.wrappedValue else {
                        return
                    }
                    
                    self.data.wrappedValue = data
                    
                    textView.invalidateIntrinsicContentSize()
                }
            } else {
                guard data != self.data.wrappedValue else {
                    return
                }
                
                self.data.wrappedValue = data
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            _ = textView
            
            textViewConfiguration.onEditingChanged(false)
        }
    }
}
#endif

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _TextView {
    func makeCoordinator() -> Coordinator {
        Coordinator(
            updater: updater,
            data: data,
            textViewConfiguration: resolvedTextViewConfiguration
        )
    }
}

// MARK: - Conformances

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _TextView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
            && (lhs.data.wrappedValue == rhs.data.wrappedValue)
            && (lhs.unresolvedTextViewConfiguration == rhs.unresolvedTextViewConfiguration)
    }
}

// MARK: - Auxiliary

extension View {
    /// Sets the amount of space between paragraphs of text in this view.
    ///
    /// Use `paragraphSpacing(_:)` to set the amount of spacing from the bottom of one paragraph to the top of the next for text elements in the view.
    public func paragraphSpacing(
        _ paragraphSpacing: CGFloat
    ) -> some View {
        environment(\._textView_paragraphSpacing, paragraphSpacing)
    }
}

extension EnvironmentValues {
    struct _ParagraphSpacingKey: EnvironmentKey {
        static let defaultValue: CGFloat? = nil
    }
    
    @_spi(Internal)
    public var _textView_paragraphSpacing: CGFloat? {
        get {
            self[_ParagraphSpacingKey.self]
        } set {
            self[_ParagraphSpacingKey.self] = newValue
        }
    }
}

#endif

