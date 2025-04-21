//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import _SwiftUIX
import Combine
import Swift
import SwiftUI

@_spi(Internal)
public protocol _PlatformTextViewType: _AppKitOrUIKitRepresented, _AnyPlatformTextView {
    associatedtype Label: View
    
    var _SwiftUIX_textViewConfiguration: _TextViewConfiguration { get }
    
    var _textEditorProxyBase: _TextEditorProxy._Base? { get }
    var _wantsTextKit1: Bool? { get }
    var _customTextStorage: NSTextStorage?  { get }
    var _lastInsertedString: NSAttributedString?  { get }
    var _wantsRelayout: Bool  { get }
    var _isTextLayoutInProgress: Bool? { get }
    var _needsIntrinsicContentSizeInvalidation: Bool { get set }
    
    var _textEditorEventPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never> { get }
    var _observableTextCursor: _ObservableTextCursor { get }
    
    static func _SwiftUIX_makeLayoutManager() -> NSLayoutManager?
    
    func _SwiftUIX_makeLayoutManager() -> NSLayoutManager?

    func representableWillAssemble(context: some _AppKitOrUIKitViewRepresentableContext)
        
    @available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
    func representableDidUpdate(
        data: _TextViewDataBinding,
        textViewConfiguration: _TextViewConfiguration,
        context: some _AppKitOrUIKitViewRepresentableContext
    )
       
    func _ensureLayoutForTextContainer()
}

public enum _AnyPlatformTextViewState {
    
}

open class _AnyPlatformTextView: AppKitOrUIKitTextView, AppKitOrUIKitTextInputDelegate {
    public var representatableStateFlags: _AppKitOrUIKitRepresentableStateFlags = []
    public var representableCache: _AppKitOrUIKitRepresentableCache = nil
    public var representableUpdater = EmptyObservableObject()

    public let _wantsTextKit1: Bool?
 
    public internal(set) var _customTextStorage: NSTextStorage?

    @_spi(Internal)
    public internal(set) var data: _TextViewDataBinding = .string(.constant(""))
    @_spi(Internal)
    public internal(set) var textViewConfiguration = _TextViewConfiguration()
    
    public var _needsIntrinsicContentSizeInvalidation = true
    public var _cachedIntrinsicContentSizeUsedAtLeastOnce: Bool = false
    public var _wantsRelayout: Bool = false
    public var _isTextLayoutInProgress: Bool? = nil

    open var _providesCustomSetDataValueMethod: Bool {
        false
    }

    public var _SwiftUIX_textViewConfiguration: _TextViewConfiguration {
        textViewConfiguration
    }
    
    public var _SwiftUIX_intrinsicContentSizeIsDisabled: Bool {
        if let _fixedSize: _SwiftUIX_FixedSizeInfo = textViewConfiguration._fixedSize {
            if _fixedSize.value == (false, false) {
                return true
            }
        }
        
        return false
    }

    override open var selectedRange: NSRange {
        get {
            super.selectedRange
        } set {
            super.selectedRange = newValue
        }
    }
    
    #if os(iOS)
    override open var selectedTextRange: UITextRange? {
        get {
            super.selectedTextRange
        } set {
            if let newValue {
                super.selectedTextRange = newValue
            } else {
                super.selectedTextRange = nil
            }
        }
    }
    #endif
    
    open class func _SwiftUIX_makeLayoutManager() -> NSLayoutManager? {
        return nil
    }
    
    open func _SwiftUIX_makeLayoutManager() -> NSLayoutManager? {
        return nil
    }

    func _setUpAnyPlatformTextView() {
        #if os(iOS)
        self.inputDelegate = self
        #endif
    }
    
    override public init(
        frame: CGRect,
        textContainer: NSTextContainer?
    ) {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            self._wantsTextKit1 = textContainer?.textLayoutManager == nil
        } else {
            self._wantsTextKit1 = true
        }

        super.init(frame: frame, textContainer: textContainer)
        
        _setUpAnyPlatformTextView()
    }
    
    @objc public required init(
        usingTextLayoutManager: Bool,
        textStorage customTextStorage: NSTextStorage?
    ) {
        let wantsTextKit1 = !usingTextLayoutManager
        
        self._wantsTextKit1 = wantsTextKit1

        /// The macOS check is necessary. It seems that on macOS, initializing the NSTextView first and then calling `_SwiftUIX_replaceTextStorage` works better than initializing with a custom `NSTextContainer`.
        if let customTextStorage: NSTextStorage, wantsTextKit1, _SwiftUI_TargetPlatformType.current != .macOS {
            assert(customTextStorage.layoutManagers.isEmpty)
            
            let layoutManager: NSLayoutManager = Self._SwiftUIX_makeLayoutManager() ?? NSLayoutManager()
            customTextStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer()
            layoutManager.addTextContainer(textContainer)
            
            super.init(frame: .zero, textContainer: textContainer)
        } else {
            if #available(iOS 16.0, tvOS 16.0, *) {
                super.init(_SwiftUIX_usingTextLayoutManager: usingTextLayoutManager)
            } else {
                super.init()
            }
            
            if let customTextStorage: NSTextStorage {
                assert(self.textStorage !== customTextStorage)
                
                _SwiftUIX_replaceTextStorage(customTextStorage)
            }
        }
        
        if let customTextStorage {
            self._customTextStorage = customTextStorage // TODO: Remove if not needed.
            
            assert(self.textStorage == customTextStorage)
        }

        _setUpAnyPlatformTextView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITextInputDelegate

    #if os(iOS) || os(tvOS)
    open func selectionWillChange(_ textInput: (any UITextInput)?) {

    }
    
    open func selectionDidChange(_ textInput: (any UITextInput)?) {

    }
    
    open func textWillChange(_ textInput: (any UITextInput)?) {

    }
    
    open func textDidChange(_ textInput: (any UITextInput)?) {

    }
    #endif
        
    #if compiler(>=6.1) && os(iOS) && !targetEnvironment(macCatalyst)
    @available(iOS 18.4, *)
    public func conversationContext(
        _ context: UIConversationContext?,
        didChange textInput: (any UITextInput)?
    ) {
        
    }
    #endif
}

/// The main `UITextView` subclass used by `TextView`.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@_documentation(visibility: internal)
open class _PlatformTextView<Label: View>: _AnyPlatformTextView, NSLayoutManagerDelegate, NSTextStorageDelegate {
    @_spi(Internal)
    public internal(set) var customAppKitOrUIKitClassConfiguration: _AnyTextView._CustomAppKitOrUIKitClassConfiguration!
    
    public var _textEditorProxyBase: _TextEditorProxy._Base?
    
    public internal(set) var _lastInsertedString: NSAttributedString?
        
    private var _lazyTextEditorEventSubject: PassthroughSubject<_SwiftUIX_TextEditorEvent, Never>? = nil
    private var _lazyTextEditorEventPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never>? = nil
    
    private var _lazy_observableTextCursor: _ObservableTextCursor? = nil
            
    @_spi(Internal)
    public var _textEditorEventPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never> {
        guard let publisher = _lazyTextEditorEventPublisher else {
            let subject = PassthroughSubject<_SwiftUIX_TextEditorEvent, Never>()
            let publisher = subject.eraseToAnyPublisher()
            
            self._lazyTextEditorEventSubject = subject
            self._lazyTextEditorEventPublisher = publisher
            
            return publisher
        }
        
        return publisher
    }
    
    public var _observableTextCursor: _ObservableTextCursor {
        guard let result = _lazy_observableTextCursor else {
            let result = _ObservableTextCursor(owner: self)
            
            self._lazy_observableTextCursor = result
            
            return result
        }
        
        return result
    }
    
    #if os(macOS)
    override open var needsUpdateConstraints: Bool {
        get {
            guard !representatableStateFlags.contains(.dismantled) else {
                return false
            }
            
            return super.needsUpdateConstraints
        } set {
            guard !representatableStateFlags.contains(.dismantled) else {
                return
            }
            
            super.needsUpdateConstraints = true
        }
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open var textStorage: NSTextStorage {
        if let textStorage = _customTextStorage {
            return textStorage
        } else {
            return super.textStorage
        }
    }
    #elseif os(macOS)
    override open var textStorage: NSTextStorage? {
        if let textStorage = _customTextStorage {
            return textStorage
        } else {
            return super.textStorage
        }
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open var attributedText: NSAttributedString! {
        didSet {
            if preferredMaximumDimensions.height != nil {
                if isScrollEnabled {
                    DispatchQueue.main.async {
                        self.invalidateIntrinsicContentSize()
                    }
                }
            }
        }
    }
    
    override open var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                input: "\r",
                modifierFlags: .shift ,
                action: #selector(handleShiftEnter(command:))
            )
        ]
    }
    
    @objc func handleShiftEnter(command: UIKeyCommand) {
        if UserInterfaceIdiom.current == .mac {
            if text != nil {
                text.append("\n")
            } else if let attributedText = attributedText {
                let newAttributedText = NSMutableAttributedString(attributedString: attributedText)
                
                newAttributedText.append(.init(string: "\n"))
                
                self.attributedText = newAttributedText
            }
        }
    }
    #endif
        
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var preferredMaximumDimensions: OptionalDimensions = nil {
        didSet {
            guard preferredMaximumDimensions != oldValue else {
                return
            }
            
            let desiredHorizontalContentHuggingPriority = preferredMaximumDimensions.width == nil
                ? AppKitOrUIKitLayoutPriority.defaultLow
                : AppKitOrUIKitLayoutPriority.defaultHigh
            
            if contentHuggingPriority(for: .horizontal) != desiredHorizontalContentHuggingPriority {
                setContentHuggingPriority(
                    desiredHorizontalContentHuggingPriority,
                    for: .horizontal
                )
            }
            
            let desiredVerticalContentHuggingPriority = preferredMaximumDimensions.height == nil
                ? AppKitOrUIKitLayoutPriority.defaultLow
                : AppKitOrUIKitLayoutPriority.defaultHigh
            
            if contentHuggingPriority(for: .vertical) != desiredVerticalContentHuggingPriority {
                setContentHuggingPriority(
                    desiredVerticalContentHuggingPriority,
                    for: .vertical
                )
            }
            
            if (oldValue.width != nil || oldValue.height != nil), preferredMaximumDimensions != oldValue {
                invalidateIntrinsicContentSize()
                
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    #endif
        
    override open var intrinsicContentSize: CGSize {
        if let _fixedSize: _SwiftUIX_FixedSizeInfo = textViewConfiguration._fixedSize {
            if _fixedSize.value == (false, false) {
                return CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: AppKitOrUIKitView.noIntrinsicMetric)
            }
        }
        
        if let result = representableCache._cachedIntrinsicContentSize {
            _cachedIntrinsicContentSizeUsedAtLeastOnce = true
            
            return result
        } else {
            let result = super.intrinsicContentSize
            
            if !result._hasUnspecifiedIntrinsicContentSizeDimensions {
                representableCache._cachedIntrinsicContentSize = result
            }
            
            return result
        }
    }
                
    open func representableWillAssemble(
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        assert(!representatableStateFlags.contains(.didUpdateAtLeastOnce))
        
        guard let textStorage: NSTextStorage = _SwiftUIX_textStorage else {
            assertionFailure()
            
            return
        }
        
        textStorage.delegate = self
        
        if _wantsTextKit1 == true {
            guard let layoutManager: NSLayoutManager = _SwiftUIX_layoutManager else {
                assertionFailure()
                
                return
            }
            
            layoutManager.delegate = self
        }
    }
    
    open func representableDidUpdate(
        data: _TextViewDataBinding,
        textViewConfiguration: _TextViewConfiguration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self._textEditorProxyBase = context.environment._textViewProxyBinding.wrappedValue?.wrappedValue._base
        } 
        
        _PlatformTextView<Label>.updateAppKitOrUIKitTextView(
            self,
            data: data,
            textViewConfiguration: textViewConfiguration,
            context: context
        )
        
        _lazy_observableTextCursor?.update()
    }
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard !representatableStateFlags.contains(.dismantled) else {
            return
        }

        verticallyCenterTextIfNecessary()
    }
    #elseif os(macOS)
    override open func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    override open func layout() {
        super.layout()
    }
    
    override open func layoutSubtreeIfNeeded() {
        super.layoutSubtreeIfNeeded()
    }
    #endif
    
    override open func invalidateIntrinsicContentSize() {
        representableCache.invalidate(.intrinsicContentSize)
                
        super.invalidateIntrinsicContentSize()
        
        _cachedIntrinsicContentSizeUsedAtLeastOnce = false
    }
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        defer {
            _synchronizeFocusState()
        }
        
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        defer {
            _synchronizeFocusState()
        }
        
        return super.resignFirstResponder()
    }
    #elseif os(macOS)
    override open func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
    }
    #endif
            
    #if os(macOS)
    open override func draggingEntered(
        _ sender: NSDraggingInfo
    ) -> NSDragOperation {
        _SwiftUIX_draggingEntered(sender)
    }
    
    open override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        _SwiftUIX_draggingUpdated(sender)
    }

    override open func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        _SwiftUIX_performDragOperation(sender)
    }

    override open func draggingExited(_ sender: (any NSDraggingInfo)?) {
        _SwiftUIX_draggingExited(sender)
    }
        
    open override func insertText(
        _ insertString: Any,
        replacementRange: NSRange
    ) {
        guard let textStorage = _SwiftUIX_textStorage else {
            assertionFailure()
            
            return
        }
        
        if let text = insertString as? String {
            _lastInsertedString = NSAttributedString(string: text)
            
            let currentLength = textStorage.length
            
            super.insertText(insertString, replacementRange: replacementRange)

            if replacementRange.location == currentLength {
                _publishTextEditorEvent(.append(text: NSAttributedString(string: text)))
            } else {
                _publishTextEditorEvent(
                    .insert(
                        text: NSAttributedString(string: text),
                        range: replacementRange.location == 0 ? nil : replacementRange
                    )
                )
            }
        } else if let insertString = insertString as? NSAttributedString {
            _lastInsertedString = insertString
            
            let currentLength = textStorage.length
            
            if insertString._isSingleTextAttachment {
                if replacementRange.length == 0 {
                    textStorage.replaceCharacters(in: replacementRange, with: insertString)
                } else {
                    assertionFailure()
                }
            } else {
                super.insertText(insertString, replacementRange: replacementRange)
            }
            
            if replacementRange.location == currentLength {
                _publishTextEditorEvent(
                    .append(text: insertString)
                )
            } else {
                _publishTextEditorEvent(
                    .insert(
                        text: insertString,
                        range: replacementRange.location == 0 ? nil : replacementRange
                    )
                )
            }
        } else {
            super.insertText(insertString, replacementRange: replacementRange)
        }
    }
    
    open override func shouldChangeText(
        in affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        if let _lastInsertedString = _lastInsertedString, replacementString == _lastInsertedString.string {
            self._lastInsertedString = nil
        } else if let replacementString = replacementString {
            self._publishTextEditorEvent(
                .replace(
                    text: NSAttributedString(string: replacementString),
                    range: affectedCharRange
                )
            )
        } else {
            if _lazyTextEditorEventSubject != nil {
                let deletedText = _SwiftUIX_attributedText.attributedSubstring(from: affectedCharRange)
                
                self._publishTextEditorEvent(
                    .delete(
                        text: deletedText,
                        range: affectedCharRange
                    )
                )
            }
        }
        
        self._lastInsertedString = nil
        
        return super.shouldChangeText(
            in: affectedCharRange,
            replacementString: replacementString
        )
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    override open func deleteBackward() {
        super.deleteBackward()
        
        textViewConfiguration.onDeleteBackward()
    }
    #elseif os(macOS)
    open override func setSelectedRange(
        _ charRange: NSRange,
        affinity: NSSelectionAffinity,
        stillSelecting stillSelectingFlag: Bool
    ) {
        super.setSelectedRange(
            charRange,
            affinity: affinity,
            stillSelecting: stillSelectingFlag
        )
        
        _lazy_observableTextCursor?.update()
    }
    
    override open func deleteBackward(_ sender: Any?) {
        super.deleteBackward(sender)
        
        textViewConfiguration.onDeleteBackward()
        
        _lazy_observableTextCursor?.update()
    }
    
    override open func preferredPasteboardType(
        from availableTypes: [NSPasteboard.PasteboardType],
        restrictedToTypesFrom allowedTypes: [NSPasteboard.PasteboardType]?
    ) -> NSPasteboard.PasteboardType? {
        if availableTypes.contains(.string) {
            return .string
        } else {
            return super.preferredPasteboardType(
                from: availableTypes,
                restrictedToTypesFrom: allowedTypes
            )
        }
    }
    
    override open func keyDown(with event: NSEvent) {
        if let shortcut = KeyboardShortcut(from: event) {
            switch shortcut {
                case KeyboardShortcut(.return, modifiers: []):
                    if let onCommit = textViewConfiguration.onCommit {
                        onCommit()
                        
                        self._SwiftUIX_didCommit()
                    } else {
                        super.keyDown(with: event)
                    }
                default:
                    super.keyDown(with: event)
            }
        } else {
            super.keyDown(with: event)
        }
    }
    #endif
    
    /// Informs the view that a commit just took place.
    open func _SwiftUIX_didCommit() {
        
    }
    
    private func _synchronizeFocusState() {
        guard !representatableStateFlags.contains(.updateInProgress) else {
            return
        }
        
        guard !representatableStateFlags.contains(.dismantled) else {
            return
        }
        
        if textViewConfiguration.isFocused?.wrappedValue != _SwiftUIX_isFirstResponder {
            textViewConfiguration.isFocused?.wrappedValue = _SwiftUIX_isFirstResponder
        }
    }
    
    // MARK: - NSTextStorageDelegate
    
    private var _isTextStorageEditing: Bool? = nil
    
    open func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorage._SwiftUIX_EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        _isTextStorageEditing = true
    }
    
    open func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage._SwiftUIX_EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        _isTextStorageEditing = false
    }
    
    // MARK: - NSLayoutManagerDelegate
        
    @objc open func layoutManagerDidInvalidateLayout(
        _ sender: NSLayoutManager
    ) {
        _isTextLayoutInProgress = true
    }

    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
        properties: UnsafePointer<NSLayoutManager.GlyphProperty>,
        characterIndexes: UnsafePointer<Int>,
        font: AppKitOrUIKitFont,
        forGlyphRange range: NSRange
    ) -> Int {
        return 0
    }
    
    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        lineSpacingAfterGlyphAt glyphIndex: Int,
        withProposedLineFragmentRect rect: CGRect
    ) -> CGFloat {
        0
    }
    
    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldUse action: NSLayoutManager.ControlCharacterAction,
        forControlCharacterAt charIndex: Int
    ) -> NSLayoutManager.ControlCharacterAction {
        return action
    }
    
    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        boundingBoxForControlGlyphAt glyphIndex: Int,
        for textContainer: NSTextContainer,
        proposedLineFragment proposedRect: CGRect,
        glyphPosition: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        return proposedRect
    }

    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldBreakLineByWordBeforeCharacterAt charIndex: Int
    ) -> Bool {
        true
    }
        
    @objc open func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        _isTextLayoutInProgress = !layoutFinishedFlag
    }
            
    // MARK: -
    
    override open func _performOrSchedulePublishingChanges(
        @_implicitSelfCapture _ operation: @escaping () -> Void
    ) {
        guard !(_isTextStorageEditing == true) else {
            return
        }
        
        if representatableStateFlags.contains(.updateInProgress) {
            Task.detached(priority: .userInitiated) { @MainActor in
                operation()
            }
        } else {
            operation()
        }
    }
}

// MARK: - Conformances

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView: _PlatformTextViewType {
    func _publishTextEditorEvent(_ event: _SwiftUIX_TextEditorEvent) {                
        Task.detached(priority: .userInitiated) { @MainActor in
            self._performOrSchedulePublishingChanges {
                self._lazyTextEditorEventSubject?.send(event)
            }
        }
    }
}

#endif
