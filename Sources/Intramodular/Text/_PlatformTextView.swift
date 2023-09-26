//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import Swift
import SwiftUI

@_spi(Internal)
public protocol _PlatformTextView_Type: _AppKitOrUIKitRepresented, AppKitOrUIKitTextView {
    associatedtype Label: View
    
    var _wantsTextKit1: Bool? { get }
    var _customTextStorage: NSTextStorage?  { get }
    var _lastInsertedString: String?  { get }
    var _wantsRelayout: Bool  { get }
    var _isTextLayoutInProgress: Bool? { get }
    var _needsIntrinsicContentSizeInvalidation: Bool { get set }
    
    var _textEditorEventPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never> { get }
    var _trackedTextCursor: _TextCursorTracking { get }
    
    func _SwiftUIX_makeLayoutManager() -> NSLayoutManager?

    func representableWillAssemble(context: some _AppKitOrUIKitViewRepresentableContext)
        
    @available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
    func representableDidUpdate(
        data: _TextViewDataBinding,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    )
    
    func invalidateLayout(for range: NSRange)
    func invalidateDisplay(for range: NSRange)
    func _ensureLayoutForTextContainer()
}

/// The main `UITextView` subclass used by `TextView`.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
open class _PlatformTextView<Label: View>: AppKitOrUIKitTextView, NSLayoutManagerDelegate, NSTextStorageDelegate {
    public var representatableStateFlags: _AppKitOrUIKitRepresentableStateFlags = []
    public var representableCache: _AppKitOrUIKitRepresentableCache = nil
    public var representableUpdater = EmptyObservableObject()

    @_spi(Internal)
    public internal(set) var data: _TextViewDataBinding = .string(.constant(""))
    @_spi(Internal)
    public internal(set) var configuration = TextView<Label>._Configuration()
    @_spi(Internal)
    public internal(set) var customAppKitOrUIKitClassConfiguration: TextView<Label>._CustomAppKitOrUIKitClassConfiguration!
    
    public internal(set) var _wantsTextKit1: Bool?
    public internal(set) var _customTextStorage: NSTextStorage?
    public internal(set) var _lastInsertedString: String?
    public internal(set) var _wantsRelayout: Bool = false
    public internal(set) var _isTextLayoutInProgress: Bool? = nil
    
    public var _needsIntrinsicContentSizeInvalidation = true
    
    private var _lazyTextEditorEventSubject: PassthroughSubject<_SwiftUIX_TextEditorEvent, Never>? = nil
    private var _lazyTextEditorEventPublisher: AnyPublisher<_SwiftUIX_TextEditorEvent, Never>? = nil
    private var _lazyTrackedTextCursor: _TextCursorTracking? = nil

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
    
    public var _trackedTextCursor: _TextCursorTracking {
        guard let result = _lazyTrackedTextCursor else {
            let result = _TextCursorTracking(owner: self)
            
            return result
        }
        
        return result
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open var textStorage: NSTextStorage {
        if let textStorage = _customTextStorage {
            return textStorage
        } else {
            return super.textStorage
        }
    }
    #else
    override open var textStorage: NSTextStorage? {
        if let textStorage = _customTextStorage {
            return textStorage
        } else {
            return super.textStorage
        }
    }
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
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
        
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
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
        if let result = representableCache._cachedIntrinsicContentSize {
            return result
        } else {
            return super.intrinsicContentSize
        }
    }
    
    public convenience required init(
        usingTextLayoutManager: Bool,
        textStorage: NSTextStorage?
    ) {
        if #available(iOS 16.0, tvOS 16.0, *) {
            self.init(usingTextLayoutManager: usingTextLayoutManager)
        } else {
            self.init()
        }
        
        _wantsTextKit1 = !usingTextLayoutManager
        
        if let textStorage {
            _SwiftUIX_replaceTextStorage(textStorage)
            
            self._customTextStorage = textStorage // TODO: Remove if not needed.
        }
    }
    
    open func _SwiftUIX_makeLayoutManager() -> NSLayoutManager? {
        return nil
    }
    
    open func representableWillAssemble(
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        assert(!representatableStateFlags.contains(.didUpdateAtLeastOnce))
        
        guard let textStorage = _SwiftUIX_textStorage else {
            assertionFailure()
            
            return
        }
        
        textStorage.delegate = self
        
        if _wantsTextKit1 == true {
            _SwiftUIX_layoutManager?.delegate = self
        }
    }
    
    open func representableDidUpdate(
        data: _TextViewDataBinding,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        _PlatformTextView<Label>.updateAppKitOrUIKitTextView(
            self,
            data: data,
            configuration: configuration,
            context: context
        )
        
        _lazyTrackedTextCursor?.update()
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func layoutSubviews() {
        super.layoutSubviews()
        
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
    }
    
    #if os(macOS)
    open override func drawInsertionPoint(
        in rect: NSRect,
        color: NSColor,
        turnedOn flag: Bool
    ) {
        super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
    }
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
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
    open override func insertText(
        _ insertString: Any,
        replacementRange: NSRange
    ) {
        guard let textStorage = _SwiftUIX_textStorage else {
            assertionFailure()
            
            return
        }
        
        if let text = (insertString as? String) ?? (insertString as? NSAttributedString)?.string {
            _lastInsertedString = text
            
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
        } else {
            super.insertText(insertString, replacementRange: replacementRange)
        }
    }
    
    open override func shouldChangeText(
        in affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        if let _lastInsertedString = _lastInsertedString, replacementString == _lastInsertedString {
            self._lastInsertedString = nil
        } else if let replacementString = replacementString {
            self._publishTextEditorEvent(.replace(text: .init(string: replacementString), range: affectedCharRange))
        } else {
            if _lazyTextEditorEventSubject != nil {
                let deletedText = _SwiftUIX_attributedText.attributedSubstring(from: affectedCharRange)
                
                self._publishTextEditorEvent(.delete(text: deletedText, range: affectedCharRange))
            }
        }
        
        self._lastInsertedString = nil
        
        return super.shouldChangeText(
            in: affectedCharRange,
            replacementString: replacementString
        )
    }
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func deleteBackward() {
        super.deleteBackward()
        
        configuration.onDeleteBackward()
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
    }
    
    override open func deleteBackward(_ sender: Any?) {
        super.deleteBackward(sender)
        
        configuration.onDeleteBackward()
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
                    if let onCommit = configuration.onCommit {
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
        
        if configuration.isFocused?.wrappedValue != _SwiftUIX_isFirstResponder {
            configuration.isFocused?.wrappedValue = _SwiftUIX_isFirstResponder
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
            DispatchQueue.main.async {
                operation()
            }
        } else {
            operation()
        }
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    func _sizeThatFits(
        proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        guard let targetWidth = proposal.replacingUnspecifiedDimensions(by: .zero).targetWidth else {
            assertionFailure()
            
            return nil
        }
                
        if let cached = representableCache.sizeThatFits(proposal: proposal) {
            return cached
        } else {
            assert(proposal.size.maximum == nil)
            
            guard var result = _uncachedSizeThatFits(for: targetWidth) else {
                return nil
            }
            
            if !result._hasPlaceholderDimension(.width, for: .textContainer) {
                var _result = result._filterPlaceholderDimensions(for: .textContainer)
                
                if let _fixedSize = configuration._fixedSize {
                    switch _fixedSize {
                        case (false, false):
                            if (_result.width ?? 0) < targetWidth {
                                _result.width = targetWidth
                            }
                            
                            if let targetHeight = proposal.targetHeight, (_result.height ?? 0) < targetHeight {
                                _result.height = targetHeight
                            }
                        default:
                            assertionFailure()
                            
                            break
                    }
                } else {
                    _result.width = max(result.width, targetWidth)
                }
                
                guard let _result = CGSize(_result) else {
                    return nil
                }
                                                
                result = _result
            } else {
                guard !targetWidth.isPlaceholderDimension(for: .textContainer) else {
                    return nil
                }
                
                result.width = targetWidth
            }
             
            representableCache._sizeThatFitsCache[proposal] = result

            return result
        }
    }
    
    private func _uncachedSizeThatFits(
        for width: CGFloat
    ) -> CGSize? {
        guard let textContainer = _SwiftUIX_textContainer, let layoutManager = _SwiftUIX_layoutManager else {
            return nil
        }
                        
        if !representableCache._sizeThatFitsCache.isEmpty, textContainer.containerSize.width == width, textContainer._isContainerWidthNormal {
            let usedRect = layoutManager.usedRect(for: textContainer).size

            if usedRect.isAreaZero {
                return _sizeThatFits(width: width)
            }
            
            return usedRect
        } else {
            return _sizeThatFits(width: width)
        }
    }
}

// MARK: - Conformances

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView: _PlatformTextView_Type {
    func _publishTextEditorEvent(_ event: _SwiftUIX_TextEditorEvent) {
        DispatchQueue.main.async {
            self._performOrSchedulePublishingChanges {
                self._lazyTextEditorEventSubject?.send(event)
            }
        }
    }
}

#endif
