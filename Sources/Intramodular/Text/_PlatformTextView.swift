//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

@_spi(Internal)
public protocol _PlatformTextView_Type: AppKitOrUIKitTextView {
    associatedtype Label: View
    
    var _trackedTextCursor: _TextCursorTracking { get }
    
    func _setUpTextView(context: some _AppKitOrUIKitViewRepresentableContext)
    
    @available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
    func _updateTextView(
        data: _TextViewDataBinding.Value,
        configuration: TextView<Label>._Configuration,
        context: some _AppKitOrUIKitViewRepresentableContext
    )
}

/// The main `UITextView` subclass used by `TextView`.
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
open class _PlatformTextView<Label: View>: AppKitOrUIKitTextView, NSLayoutManagerDelegate, NSTextStorageDelegate {
    var representationStateFlags: _AppKitOrUIKitRepresentationStateFlags = []
    var representationCache: _AppKitOrUIKitRepresentationCache = nil
    
    var data: _TextViewDataBinding = .string(.constant(""))
    var configuration = TextView<Label>._Configuration()
    var customAppKitOrUIKitClassConfiguration: TextView<Label>._CustomAppKitOrUIKitClassConfiguration!
    
    public private(set) lazy var _trackedTextCursor = _TextCursorTracking(owner: self)
    
    private var _wantsTextKit1: Bool?
    private var _customTextStorage: NSTextStorage?
    private var _cachedIntrinsicContentSize: CGSize?
    private var lastBounds: CGSize = .zero
    
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
        if let fixedSize = configuration._fixedSize {
            switch fixedSize {
                case (false, false):
                    return CGSize(
                        width: AppKitOrUIKitView.noIntrinsicMetric,
                        height: AppKitOrUIKitView.noIntrinsicMetric
                    )
                default:
                    assertionFailure("unsupported")
                    
                    return super.intrinsicContentSize
            }
        }
        
        if let result = representationCache._cachedIntrinsicContentSize {
            return result
        } else {
            guard let result = _sizeThatFits() else {
                return super.intrinsicContentSize
            }
            
            representationCache._cachedIntrinsicContentSize = result
            
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
    
    open func _setUpTextView(
        context: some _AppKitOrUIKitViewRepresentableContext
    ) {
        assert(!representationStateFlags.contains(.didUpdateAtLeastOnce))
        
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
        
        DispatchQueue.main.async {
            self._trackedTextCursor.update()
        }
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        verticallyCenterTextIfNecessary()
    }
    #endif
    
    override open func invalidateIntrinsicContentSize() {
        representationCache.invalidate(.intrinsicContentSize)
        
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
        self.needsDisplay = true
        
        return super.becomeFirstResponder()
    }
    #endif
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func deleteBackward() {
        super.deleteBackward()
        
        configuration.onDeleteBackward()
    }
    #elseif os(macOS)
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
                    configuration.onCommit()
                                        
                    self._SwiftUIX_didCommit()
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
        guard !representationStateFlags.contains(.updateInProgress) else {
            return
        }
        
        guard !representationStateFlags.contains(.dismantled) else {
            return
        }
        
        if configuration.isFocused?.wrappedValue != _SwiftUIX_isFirstResponder {
            configuration.isFocused?.wrappedValue = _SwiftUIX_isFirstResponder
        }
    }
    
    // MARK: - NSTextStorageDelegate
    
    open func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorage._SwiftUIX_EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        
    }
    
    open func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage._SwiftUIX_EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        
    }
    
    // MARK: - NSLayoutManagerDelegate
    
    open func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView {
    func _sizeThatFits(
        _ proposal: AppKitOrUIKitLayoutSizeProposal
    ) -> CGSize? {
        if let cachedResult = representationCache._sizeThatFitsCache[proposal] {
            return cachedResult
        }
        
        guard let targetWidth = proposal.size.target.width else {
            assertionFailure("unsupported")
            
            return nil
        }
        
        guard proposal.size.target.width != .zero else {
            return nil
        }
        
        let oldFrame = frame
        
        defer {
            if oldFrame != self.frame {
                self.frame = oldFrame
            }
        }
        
        guard let idealSize = self._sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude)) else {
            return .zero
        }
        
        let result: CGSize
        
        if proposal.fit.horizontal == .required {
            result = CGSize(
                width: min(targetWidth, idealSize.width),
                height: idealSize.height
            )
        } else {
            result = CGSize(
                width: max(targetWidth, idealSize.width),
                height: idealSize.height
            )
        }
        
        if result.isAreaZero {
            return nil
        }
        
        representationCache._sizeThatFitsCache[proposal] = result
        
        return result
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
            _assignIfNotEqual(textColor, to: &view.textColor)
        }
        
        if let tintColor = configuration.tintColor {
            _assignIfNotEqual(tintColor, to: &view.tintColor)
        }
        
        if let linkForegroundColor = configuration.linkForegroundColor {
            _assignIfNotEqual(linkForegroundColor, to: &view.linkTextAttributes[.foregroundColor])
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
                
                _assignIfNotEqual(context.environment.lineBreakMode, to: &paragraphStyle.lineBreakMode)
                _assignIfNotEqual(context.environment.lineSpacing, to: &paragraphStyle.lineSpacing)
                
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
        
        guard let _cachedIntrinsicContentSize = _cachedIntrinsicContentSize else {
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
        _assignIfNotEqual(true, to: &allowsUndo)
        _assignIfNotEqual(.clear, to: &backgroundColor)
        _assignIfNotEqual(false, to: &drawsBackground)
        _assignIfNotEqual(!configuration.isConstant && configuration.isEditable, to: &isEditable)
        _assignIfNotEqual(.zero, to: &textContainerInset)
        _assignIfNotEqual(true, to: &usesAdaptiveColorMappingForDarkAppearance)
        
        if let font = try? configuration.cocoaFont ?? context.environment.font?.toAppKitOrUIKitFont() {
            _assignIfNotEqual(font, to: &self.font)
            
            if let textStorage = _SwiftUIX_textStorage {
                _assignIfNotEqual(font, to: &textStorage.font)
            }
        }
        
        _assignIfNotEqual(configuration.cocoaForegroundColor, to: &textColor)
        
        if let foregroundColor = configuration.cocoaForegroundColor {
            if let textStorage = _SwiftUIX_textStorage {
                _assignIfNotEqual(foregroundColor, to: &textStorage.foregroundColor)
            }
        }
        
        if let textContainer {
            _assignIfNotEqual(.zero, to: &textContainer.lineFragmentPadding)
            _assignIfNotEqual((context.environment.lineLimit ?? 0), to: &textContainer.maximumNumberOfLines)
        }
        
        _assignIfNotEqual(false, to: &isHorizontallyResizable)
        _assignIfNotEqual(true, to: &isVerticallyResizable)
        _assignIfNotEqual([.width], to: &autoresizingMask)
        
        if let tintColor = configuration.tintColor {
            _assignIfNotEqual(tintColor, to: &insertionPointColor)
        }
        
        if _currentTextViewData(kind: self.data.wrappedValue.kind) != data {
            setData(data)
        }
        
        if let fixedSize = configuration._fixedSize {
            if fixedSize == (false, false) {
                textContainer?.widthTracksTextView = true
                textContainer?.containerSize.height = AppKitOrUIKitView.layoutFittingExpandedSize.height
            } else {
                assertionFailure("unsupported")
            }
        } else {
            invalidateIntrinsicContentSize()
            
            let intrinsicContentSize = self.intrinsicContentSize
            
            if frame.size.width < intrinsicContentSize.width || frame.size.height < intrinsicContentSize.height {
                frame.size = intrinsicContentSize
            }
        }
    }
        
    func _sizeThatFits(
        _ size: CGSize? = nil
    ) -> CGSize? {
        guard let textContainer = self.textContainer, let layoutManager = self.layoutManager else {
            assert(_currentTextViewData(kind: self.data.wrappedValue.kind).isEmpty)
            
            return nil
        }
        
        if let size, textContainer.containerSize != size {
            textContainer.containerSize = size
        }
        
        layoutManager.ensureLayout(for: textContainer)
        
        let measuredSize = layoutManager.boundingRect(
            forGlyphRange: layoutManager.glyphRange(for: textContainer),
            in: textContainer
        ).size
        
        var extraHeight: CGFloat = 0
        
        if measuredSize.height == 0 || string.hasSuffix("\n") {
            extraHeight += (_heightDifferenceForNewline ?? 0)
        }
        
        let result = CGSize(
            width: measuredSize.width,
            height: measuredSize.height + extraHeight
        )
        
        return result
    }
}
#endif

// MARK: - Conformances

@_spi(Internal)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
extension _PlatformTextView: _PlatformTextView_Type {
    
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
    func _SwiftUIX_replaceTextStorage(_ textStorage: NSTextStorage) {
        guard let layoutManager = _SwiftUIX_layoutManager else {
            assertionFailure()
            
            return
        }
        
        textStorage.addLayoutManager(layoutManager)
                
        layoutManager.replaceTextStorage(textStorage)
        
        assert(self.textStorage == textStorage)
    }
}
#endif

@_spi(Internal)
extension _PlatformTextView_Type {
    public func invalidateLayout(
        for range: NSRange
    ) {
        _SwiftUIX_layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
    }
    
    public func invalidateDisplay(
        for range: NSRange
    ) {
        _SwiftUIX_layoutManager?.invalidateDisplay(forCharacterRange: range)
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = EditActions
}
#elseif os(macOS)
extension NSTextStorage {
    public typealias _SwiftUIX_EditActions = NSTextStorageEditActions
}
#endif

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
