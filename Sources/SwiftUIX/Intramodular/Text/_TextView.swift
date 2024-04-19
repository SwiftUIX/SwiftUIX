//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

// MARK: - Implementation

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
struct _TextView<Label: View> {
    typealias Configuration = TextView<Label>._Configuration

    @Environment(\._textViewConfigurationMutation) private var _textViewConfigurationMutation
        
    @ObservedObject var updater: EmptyObservableObject
    
    let data: _TextViewDataBinding
    let _configuration: Configuration
    let customAppKitOrUIKitClassConfiguration: TextView<Label>._CustomAppKitOrUIKitClassConfiguration
    
    var configuration: Configuration {
        var result = _configuration
        
        _textViewConfigurationMutation(&result)
        
        return result
    }
    
    init(
        updater: EmptyObservableObject,
        data: _TextViewDataBinding,
        configuration: Configuration,
        customAppKitOrUIKitClassConfiguration: TextView<Label>._CustomAppKitOrUIKitClassConfiguration
    ) {
        self.updater = updater
        self.data = data
        self._configuration = configuration
        self.customAppKitOrUIKitClassConfiguration = customAppKitOrUIKitClassConfiguration
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
            if let textStorage = textStorage() {
                if let type = customAppKitOrUIKitClassConfiguration.class as? _PlatformTextView<Label>.Type {
                    view = type.init(
                        usingTextLayoutManager: false,
                        textStorage: textStorage
                    )
                } else {
                    let layoutManager = NSLayoutManager()
                    textStorage.addLayoutManager(layoutManager)
                    let textContainer = NSTextContainer(size: .zero)
                    layoutManager.addTextContainer(textContainer)
                    
                    view = customAppKitOrUIKitClassConfiguration.class.init(
                        frame: .zero,
                        textContainer: textContainer
                    )
                }
            } else {
                assertionFailure()
                
                view = customAppKitOrUIKitClassConfiguration.class.init()
            }
        } else {
            view = customAppKitOrUIKitClassConfiguration.class.init()
        }
        
        if let _view = view as? _PlatformTextView<Label> {
            _view.representableUpdater = updater
        }

        customAppKitOrUIKitClassConfiguration.update(view, context)
        
        if let view = view as? _PlatformTextView<Label> {
            view.customAppKitOrUIKitClassConfiguration = customAppKitOrUIKitClassConfiguration
            view.data = data
            view.configuration = configuration
            
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
            DispatchQueue.main.async {
                if (configuration.isInitialFirstResponder ?? configuration.isFocused?.wrappedValue) ?? false {
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

        customAppKitOrUIKitClassConfiguration.update(view, context)

        _withoutAppKitOrUIKitAnimation(context.transaction.disablesAnimations) {
            if let view = view as? _PlatformTextView<Label> {
                assert(view.representatableStateFlags.contains(.updateInProgress))
                
                view.customAppKitOrUIKitClassConfiguration = customAppKitOrUIKitClassConfiguration
                
                view.representableDidUpdate(
                    data: self.data,
                    configuration: configuration,
                    context: context
                )
            } else {
                _PlatformTextView<Label>.updateAppKitOrUIKitTextView(
                    view,
                    data: self.data,
                    configuration: configuration,
                    context: context
                )
            }
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
        if let proxyBinding = context.environment._textViewProxy, let view = view as? _PlatformTextView<Label> {
            if let existing = proxyBinding.wrappedValue.base {
                if existing.representatableStateFlags.contains(.dismantled) {
                    proxyBinding.wrappedValue._base.wrappedValue = nil
                }
            }
            
            if proxyBinding.wrappedValue.base !== view {
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
        var configuration: Configuration
        
        init(
            updater: EmptyObservableObject,
            data: _TextViewDataBinding,
            configuration: Configuration
        ) {
            self.updater = updater
            self.data = data
            self.configuration = configuration
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            configuration.onEditingChanged(true)
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
            if configuration.dismissKeyboardOnReturn {
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
                        self.configuration.onCommit?()
                        
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
                self.configuration.onEditingChanged(false)
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
        var configuration: Configuration
        
        init(
            updater: EmptyObservableObject,
            data: _TextViewDataBinding,
            configuration: Configuration
        ) {
            self.updater = updater
            self.data = data
            self.configuration = configuration
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
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            data.wrappedValue = textView._currentTextViewData(kind: data.wrappedValue.kind)
            
            configuration.onEditingChanged(true)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
                        
            let data = textView._currentTextViewData(kind: data.wrappedValue.kind)
            
            guard data != self.data.wrappedValue else {
                return
            }
            
            (textView as? _PlatformTextView<Label>)?._needsIntrinsicContentSizeInvalidation = true

            self.data.wrappedValue = data
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            configuration.onEditingChanged(false)
            
            data.wrappedValue = textView._currentTextViewData(kind: data.wrappedValue.kind)
        }
    }
}
#endif

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _TextView {
    func makeCoordinator() -> Coordinator {
        Coordinator(updater: updater, data: data, configuration: configuration)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        view: AppKitOrUIKitViewType,
        context: Context
    ) -> CGSize? {
        guard let view = view as? _PlatformTextView<Label> else {
            return nil // TODO: Implement sizing for custom text views as well
        }
        
        guard !view.representatableStateFlags.contains(.dismantled) else {
            return nil
        }

        guard let size = view._sizeThatFits(
            proposal: AppKitOrUIKitLayoutSizeProposal(
                proposal,
                fixedSize: configuration._fixedSize
            )
        ) else {
            return nil
        }
                
        return size
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
    
    struct _TextField_KeyboardTypeKey: EnvironmentKey {
        static let defaultValue: _TextField_KeyboardType = .default
    }
    
    @_spi(Internal)
    public var _textField_keyboardType: _TextField_KeyboardType {
        get {
            self[_TextField_KeyboardTypeKey.self]
        } set {
            self[_TextField_KeyboardTypeKey.self] = newValue
        }
    }
}

/// The keyboard type to be displayed.
public enum _TextField_KeyboardType {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension UIKeyboardType {
    public init(from keyboardType: _TextField_KeyboardType) {
        switch keyboardType {
            case .default:
                self = .default
            case .asciiCapable:
                self = .asciiCapable
            case .numbersAndPunctuation:
                self = .numbersAndPunctuation
            case .URL:
                self = .URL
            case .numberPad:
                self = .numberPad
            case .phonePad:
                self = .phonePad
            case .namePhonePad:
                self = .namePhonePad
            case .emailAddress:
                self = .emailAddress
            case .decimalPad:
                self = .decimalPad
            case .twitter:
                self = .twitter
            case .webSearch:
                self = .webSearch
            case .asciiCapableNumberPad:
                self = .asciiCapable
        }
    }
}
#else
extension View {
    public func keyboardType(
        _ keyboardType: _TextField_KeyboardType
    ) -> some View {
        environment(\._textField_keyboardType, keyboardType)
    }
}
#endif

#endif
