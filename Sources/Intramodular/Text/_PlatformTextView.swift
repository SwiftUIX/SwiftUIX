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
    
    var _textEditorEventPublisher: AnyPublisher<_TextView_TextEditorEvent, Never> { get }
    var _trackedTextCursor: _TextCursorTracking { get }
    
    func _SwiftUIX_makeLayoutManager() -> NSLayoutManager?

    func representableWillAssemble(context: some _AppKitOrUIKitViewRepresentableContext)
        
    @available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
    func _updateTextView(
        data: _TextViewDataBinding.Value,
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
    
    public private(set) var _wantsTextKit1: Bool?
    public private(set) var _customTextStorage: NSTextStorage?
    public private(set) var _lastInsertedString: String?
    public private(set) var _wantsRelayout: Bool = false
    public private(set) var _isTextLayoutInProgress: Bool? = nil
    
    public var _needsIntrinsicContentSizeInvalidation = false
    
    private var _lazyTextEditorEventSubject: PassthroughSubject<_TextView_TextEditorEvent, Never>? = nil
    private var _lazyTextEditorEventPublisher: AnyPublisher<_TextView_TextEditorEvent, Never>? = nil
    private var _lazyTrackedTextCursor: _TextCursorTracking? = nil

    @_spi(Internal)
    public var _textEditorEventPublisher: AnyPublisher<_TextView_TextEditorEvent, Never> {
        guard let publisher = _lazyTextEditorEventPublisher else {
            let subject = PassthroughSubject<_TextView_TextEditorEvent, Never>()
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
            if let _fixedSize = configuration._fixedSize {
                switch _fixedSize {
                    case (false, false):
                        break
                    default:
                        assertionFailure()
                        break
                }
            }
            
            guard 
                self.bounds.width.isNormal,
                let result = _sizeThatFits()?.toAppKitOrUIKitIntrinsicContentSize()
            else {
                return super.intrinsicContentSize
            }
            
            representableCache._cachedIntrinsicContentSize = result
            
            return result
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
    
    open func _updateTextView(
        data: _TextViewDataBinding.Value,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        _PlatformTextView<Label>._update(
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
        if let text = insertString as? String {
            _lastInsertedString = text
            
            _publishTextEditorEvent(.insert(text: .init(string: text), range: replacementRange))
        }
        
        super.insertText(insertString, replacementRange: replacementRange)
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
        false
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
        _ proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        if let cached = representableCache.sizeThatFits(proposal) {
            return cached
        } else {
            assert(proposal.size.maximum == nil)
            
            guard var result = _uncachedSizeThatFits(for: proposal._targetAppKitOrUIKitSize.width) else {
                return nil
            }
            
            if !result._hasPlaceholderDimension(.width, for: .textContainer) {
                result.width = max(result.width, proposal.size.target.width)
            } else if let targetWidth = proposal.size.target.width, targetWidth.isNormal {
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
        
        let usedRect = layoutManager.usedRect(for: textContainer).size
                
        if !representableCache._sizeThatFitsCache.isEmpty, textContainer.containerSize.width == width, textContainer._isContainerWidthNormal, !usedRect.isAreaZero {
            return usedRect
        } else {
            return _sizeThatFits(width: width)
        }
    }
}

// MARK: -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public static func _update(
        _ view: AppKitOrUIKitTextView,
        data: _TextViewDataBinding.Value,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        let requiresAttributedText = false
        || context.environment.requiresAttributedText
        || configuration.requiresAttributedText
        || data.isAttributed
        
        var cursorOffset: Int?
        
        // Record the current cursor offset.
        if let selectedRange = view.selectedTextRange {
            cursorOffset = view.offset(from: view.beginningOfDocument, to: selectedRange.start)
        }
        
    updateUserInteractability: do {
#if !os(tvOS)
        if !configuration.isEditable {
            view.isEditable = false
        } else {
            view.isEditable = configuration.isConstant
            ? false
            : context.environment.isEnabled && configuration.isEditable
        }
#endif
        view.isScrollEnabled = context.environment._isScrollEnabled
        view.isSelectable = configuration.isSelectable
    }
        
    updateLayoutConfiguration: do {
        (view as? _PlatformTextView<Label>)?.preferredMaximumDimensions = context.environment.preferredMaximumLayoutDimensions
    }
        
    updateTextAndGeneralConfiguration: do {
        if #available(iOS 14.0, tvOS 14.0, *) {
            view.overrideUserInterfaceStyle = .init(context.environment.colorScheme)
        }
        
        view.autocapitalizationType = configuration.autocapitalization ?? .sentences
        
        let font: AppKitOrUIKitFont? = configuration.cocoaFont ?? (try? context.environment.font?.toAppKitOrUIKitFont())
        
        if let textColor = configuration.cocoaForegroundColor {
            view._assignIfNotEqual(textColor, to: \.textColor)
        }
        
        if let tintColor = configuration.tintColor {
            view._assignIfNotEqual(tintColor, to: \.tintColor)
        }
        
        if let linkForegroundColor = configuration.linkForegroundColor {
            SwiftUIX._assignIfNotEqual(linkForegroundColor, to: &view.linkTextAttributes[.foregroundColor])
        } else {
            if view.linkTextAttributes[.foregroundColor] != nil {
                view.linkTextAttributes[.foregroundColor] = nil
            }
        }
        
        view.textContentType = configuration.textContentType
        
        view.textContainer.lineFragmentPadding = .zero
        view.textContainer.maximumNumberOfLines = context.environment.lineLimit ?? 0
        view.textContainerInset = configuration.textContainerInset
        
        if data.kind != .cocoaTextStorage {
            if requiresAttributedText {
                let paragraphStyle = NSMutableParagraphStyle()
                
                paragraphStyle._assignIfNotEqual(context.environment.lineBreakMode, to: \.lineBreakMode)
                paragraphStyle._assignIfNotEqual(context.environment.lineSpacing, to: \.lineSpacing)
                
                context.environment._paragraphSpacing.map {
                    paragraphStyle.paragraphSpacing = $0
                }
                
                func attributedStringAttributes() -> [NSAttributedString.Key: Any] {
                    var attributes: [NSAttributedString.Key: Any] = [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                    
                    if let font {
                        attributes[.font] = font
                    }
                    
                    if let kerning = configuration.kerning {
                        attributes[.kern] = kerning
                    }
                    
                    if let textColor = configuration.cocoaForegroundColor {
                        attributes[.foregroundColor] = textColor
                    }
                    
                    return attributes
                }
                
                view.attributedText = data.toAttributedString(attributes: attributedStringAttributes())
            } else {
                if let text = data.stringValue {
                    view.text = text
                } else {
                    assertionFailure()
                }
                
                view.font = font
            }
        }
    }
        
    correctCursorOffset: do {
#if os(tvOS)
        if let cursorOffset = cursorOffset, let position = view.position(from: view.beginningOfDocument, offset: cursorOffset), let textRange = view.textRange(from: position, to: position) {
            view.selectedTextRange = textRange
        }
#else
        // Reset the cursor offset if possible.
        if view.isEditable, let cursorOffset = cursorOffset, let position = view.position(from: view.beginningOfDocument, offset: cursorOffset), let textRange = view.textRange(from: position, to: position) {
            view.selectedTextRange = textRange
        }
#endif
    }
        
    updateKeyboardConfiguration: do {
        view.enablesReturnKeyAutomatically = configuration.enablesReturnKeyAutomatically ?? false
        view.keyboardType = configuration.keyboardType
        view.returnKeyType = configuration.returnKeyType ?? .default
    }
        
    updateResponderChain: do {
        DispatchQueue.main.async {
            if let isFocused = configuration.isFocused, view.window != nil {
                if isFocused.wrappedValue && !view.isFirstResponder {
                    view.becomeFirstResponder()
                } else if !isFocused.wrappedValue && view.isFirstResponder {
                    view.resignFirstResponder()
                }
            } else if let isFirstResponder = configuration.isFirstResponder, view.window != nil {
                if isFirstResponder && !view.isFirstResponder, context.environment.isEnabled {
                    view.becomeFirstResponder()
                } else if !isFirstResponder && view.isFirstResponder {
                    view.resignFirstResponder()
                }
            }
        }
    }
    }
    
    func _sizeThatFits(_ size: CGSize? = nil) -> CGSize? {
        if let size {
            return self.sizeThatFits(size)
        } else {
            if let preferredMaximumLayoutWidth = preferredMaximumDimensions.width {
                return sizeThatFits(
                    CGSize(
                        width: preferredMaximumLayoutWidth,
                        height: AppKitOrUIKitView.layoutFittingCompressedSize.height
                    )
                    .clamped(to: preferredMaximumDimensions)
                )
            } else if !isScrollEnabled {
                return .init(
                    width: bounds.width,
                    height: _sizeThatFits(width: bounds.width)?.height ?? AppKitOrUIKitView.noIntrinsicMetric
                )
            } else {
                return .init(
                    width: AppKitOrUIKitView.noIntrinsicMetric,
                    height: min(
                        preferredMaximumDimensions.height ?? contentSize.height,
                        contentSize.height
                    )
                )
            }
        }
    }
    
    private func verticallyCenterTextIfNecessary() {
        guard !isScrollEnabled else {
            return
        }
        
        guard let _cachedIntrinsicContentSize = representableCache._cachedIntrinsicContentSize else {
            return
        }
        
        guard let intrinsicHeight = OptionalDimensions(intrinsicContentSize: _cachedIntrinsicContentSize).height else {
            return
        }
        
        let topOffset = (bounds.size.height - intrinsicHeight * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        
        contentOffset.y = -positiveTopOffset
    }
}
#elseif os(macOS)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public static func _update(
        _ view: AppKitOrUIKitTextView,
        data: _TextViewDataBinding.Value,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        guard let view = view as? _PlatformTextView else {
            assertionFailure("unsupported")
            
            return
        }
        
        view._update(data: data, configuration: configuration, context: context)
    }
        
    private func _update(
        data: _TextViewDataBinding.Value,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        _assignIfNotEqual(true, to: \.allowsUndo)
        _assignIfNotEqual(.clear, to: \.backgroundColor)
        _assignIfNotEqual(false, to: \.drawsBackground)
        _assignIfNotEqual(!configuration.isConstant && configuration.isEditable, to: \.isEditable)
        _assignIfNotEqual(.zero, to: \.textContainerInset)
        _assignIfNotEqual(true, to: \.usesAdaptiveColorMappingForDarkAppearance)
        
        if let font = try? configuration.cocoaFont ?? context.environment.font?.toAppKitOrUIKitFont() {
            _assignIfNotEqual(font, to: \.self.font)

            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(font, to: \.font)
            }
        }
        
        _assignIfNotEqual(configuration.cocoaForegroundColor, to: \.textColor)
        
        if let foregroundColor = configuration.cocoaForegroundColor {
            if let textStorage = _SwiftUIX_textStorage {
                textStorage._assignIfNotEqual(foregroundColor, to: \.foregroundColor)
            }
        }
        
        if let textContainer {
            textContainer._assignIfNotEqual(.zero, to: \.lineFragmentPadding)
            textContainer._assignIfNotEqual((context.environment.lineLimit ?? 0), to: \.maximumNumberOfLines)
        }
        
        _assignIfNotEqual(false, to: \.isHorizontallyResizable)
        _assignIfNotEqual(true, to: \.isVerticallyResizable)
        _assignIfNotEqual([.width], to: \.autoresizingMask)
        
        if let tintColor = configuration.tintColor {
            _assignIfNotEqual(tintColor, to: \.insertionPointColor)
        }
        
        if _currentTextViewData(kind: self.data.wrappedValue.kind) != data {
            _needsIntrinsicContentSizeInvalidation = true
            
            setData(data)
        }
                
        _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded()
    }
    
    private func _invalidateIntrinsicContentSizeAndEnsureLayoutIfNeeded() {
        guard let textContainer = textContainer else {
            return
        }
        
        if _needsIntrinsicContentSizeInvalidation {
            invalidateIntrinsicContentSize()
        }
        
        if _wantsRelayout {
            _SwiftUIX_layoutManager?.ensureLayout(for: textContainer)
            
            if _needsIntrinsicContentSizeInvalidation {
                _SwiftUIX_setNeedsLayout()
                _SwiftUIX_layoutIfNeeded()
            }
        }
        
        _needsIntrinsicContentSizeInvalidation = false
        _wantsRelayout = false
    }
    
    private func _correctNSTextContainerSize() {
        guard let textContainer else {
            return
        }
        
        if let fixedSize = configuration._fixedSize {
            if fixedSize == (false, false) {
                if textContainer.heightTracksTextView == false {
                    textContainer.widthTracksTextView = true
                    textContainer.heightTracksTextView = true
                }
                
                if textContainer.size.height != 10000000.0 {
                    textContainer.size.height = 10000000.0
                }
            } else {
                assertionFailure("unsupported")
            }
        }
    }
    
    private func _enforcePrecomputedIntrinsicContentSize() {
        guard let intrinsicContentSize = representableCache._cachedIntrinsicContentSize, !intrinsicContentSize._hasUnspecifiedIntrinsicContentSizeDimensions else {
            return
        }
    
        if frame.size.width < intrinsicContentSize.width {
            frame.size.width = intrinsicContentSize.width
        }

        if frame.size.height < intrinsicContentSize.height {
            frame.size.height = intrinsicContentSize.height
        }
    }
    
    func _sizeThatFits(
        _ size: CGSize? = nil
    ) -> CGSize? {
        guard let width = size?.width else {
            return nil
        }
        
        return _sizeThatFits(width: width)
    }
}
#endif

// MARK: - Conformances

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView: _PlatformTextView_Type {
    func _publishTextEditorEvent(_ event: _TextView_TextEditorEvent) {
        DispatchQueue.main.async {
            self._performOrSchedulePublishingChanges {
                self._lazyTextEditorEventSubject?.send(event)
            }
        }
    }
}

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension _PlatformTextView_Type {
    func _SwiftUIX_replaceTextStorage(_ textStorage: NSTextStorage) {
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.replaceLayoutManager(layoutManager)
        
        assert(self.textStorage == textStorage)
    }
}
#elseif os(macOS)
extension _PlatformTextView_Type {
    func _SwiftUIX_replaceTextStorage(
        _ textStorage: NSTextStorage
    ) {
        guard let layoutManager = _SwiftUIX_makeLayoutManager() ?? _SwiftUIX_layoutManager else {
            assertionFailure()
            
            return
        }
        
        if layoutManager != _SwiftUIX_layoutManager {
            textContainer?.replaceLayoutManager(layoutManager)
        }
        
        layoutManager.replaceTextStorage(textStorage)

        assert(self.textStorage == textStorage)
        assert(self.layoutManager == layoutManager)

        setSelectedRange(NSRange(location: string.count, length: 0))
    }
}
#endif

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    public func invalidateLayout(
        for range: NSRange
    ) {
        guard let layoutManager = _SwiftUIX_layoutManager else {
            return
        }
        
        layoutManager.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
    }
    
    public func invalidateDisplay(
        for range: NSRange
    ) {
        _SwiftUIX_layoutManager?.invalidateDisplay(forCharacterRange: range)
    }
    
    public func _ensureLayoutForTextContainer() {
        if let textContainer = _SwiftUIX_textContainer {
            _SwiftUIX_layoutManager?.invalidateLayout(forCharacterRange: .init(location: 0, length: _SwiftUIX_attributedText.length), actualCharacterRange: nil)
            _SwiftUIX_layoutManager?.ensureLayout(for: textContainer)
        }
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension NSTextContainer {
    var containerSize: CGSize {
        get {
            size
        } set {
            size = newValue
        }
    }
}

extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = EditActions
}
#elseif os(macOS)
extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = NSTextStorageEditActions
}
#endif

extension NSTextContainer {
    var _isContainerWidthNormal: Bool {
        containerSize.width.isNormal && containerSize.width != 10000000.0
    }
}

extension EnvironmentValues {
    var requiresAttributedText: Bool {
        _paragraphSpacing != nil
    }
}

private extension CGSize {
    var edgeInsets: EdgeInsets {
        .init(
            top: height / 2,
            leading: width / 2,
            bottom: height / 2,
            trailing: width / 2
        )
    }
}

#endif
