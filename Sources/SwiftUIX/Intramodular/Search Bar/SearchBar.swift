//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)

/// A specialized view for receiving search-related information from the user.
public struct SearchBar: DefaultTextInputType {
    @Binding fileprivate var text: String
    
    fileprivate var searchTokens: Binding<[SearchToken]>?
    
    var customAppKitOrUIKitClass: AppKitOrUIKitSearchBar.Type?
        
    private let onEditingChanged: (Bool) -> Void
    private let onCommit: () -> Void
    private var isInitialFirstResponder: Bool?
    private var isFocused: Binding<Bool>? = nil
    
    private var placeholder: String?
    
    private var appKitOrUIKitFont: AppKitOrUIKitFont?
    private var appKitOrUIKitForegroundColor: AppKitOrUIKitColor?
    #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
    private var appKitOrUIKitSearchFieldBackgroundColor: UIColor?
    private var searchBarStyle: UISearchBar.Style = .minimal
    private var iconImageConfiguration: [UISearchBar.Icon: AppKitOrUIKitImage] = [:]
    #endif
    
    private var showsCancelButton: Bool?
    private var onCancel: () -> Void = { }
    
    #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
    private var returnKeyType: UIReturnKeyType?
    private var enablesReturnKeyAutomatically: Bool?
    private var isSecureTextEntry: Bool = false
    private var textContentType: UITextContentType? = nil
    private var keyboardType: UIKeyboardType?
    #endif

    #if os(macOS)
    private var isBezeled: Bool = true
    private var focusRingType: NSFocusRingType = .default
    #endif

    private var isEditingValue: Bool? = nil
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.placeholder = String(title)
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
    
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        onCommit: @escaping () -> Void = { }
    ) {
        self.placeholder = String(title)
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = {
            isEditing.removeDuplicates().wrappedValue = $0
        }
        
        self.isFocused = isEditing
        self.isEditingValue = isEditing.wrappedValue
    }

    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
}

#if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar: UIViewRepresentable {
    public typealias UIViewType = UISearchBar
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = _UISearchBar()
        
        uiView.delegate = context.coordinator

        if context.environment.isEnabled {
            DispatchQueue.main.async {
                if (isInitialFirstResponder ?? isFocused?.wrappedValue) ?? false {
                    uiView.becomeFirstResponder()
                }
            }
        }

        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.base = self
        
        _updateUISearchBar(uiView, environment: context.environment)
    }
    
    func _updateUISearchBar(
        _ uiView: UIViewType,
        searchController: UISearchController? = nil,
        environment: EnvironmentValues
    ) {
        uiView.isUserInteractionEnabled = environment.isEnabled

        style: do {
            uiView.searchTextField.autocorrectionType = environment.disableAutocorrection.map({ $0 ? .no : .yes }) ?? .default
            
            if (appKitOrUIKitFont != nil || environment.font != nil) || appKitOrUIKitForegroundColor != nil || appKitOrUIKitSearchFieldBackgroundColor != nil {
                if let font = try? appKitOrUIKitFont ?? environment.font?.toAppKitOrUIKitFont() {
                    uiView.searchTextField.font = font
                }
                
                if let foregroundColor = appKitOrUIKitForegroundColor {
                    uiView.searchTextField.textColor = foregroundColor
                }
                
                if let backgroundColor = appKitOrUIKitSearchFieldBackgroundColor {
                    uiView.searchTextField.backgroundColor = backgroundColor
                }
            }
            
            if let placeholder = placeholder {
                uiView.placeholder = placeholder
            }

            _assignIfNotEqual(searchBarStyle, to: &uiView.searchBarStyle)

            for (icon, image) in iconImageConfiguration {
                if uiView.image(for: icon, state: .normal) == nil { // FIXME: This is a performance hack.
                    uiView.setImage(image, for: icon, state: .normal)
                }
            }

            _assignIfNotEqual(environment.tintColor?.toUIColor(), to: &uiView.tintColor)

            if let showsCancelButton = showsCancelButton {
                if uiView.showsCancelButton != showsCancelButton {
                    uiView.setShowsCancelButton(showsCancelButton, animated: true)
                }
            }
        }
        
        keyboard: do {
            _assignIfNotEqual(returnKeyType ?? .default, to: &uiView.returnKeyType)
            _assignIfNotEqual(keyboardType ?? .default, to: &uiView.keyboardType)
            _assignIfNotEqual(enablesReturnKeyAutomatically ?? false, to: &uiView.enablesReturnKeyAutomatically)
        }
        
        data: do {
            if uiView.text != text {
                uiView.text = text
            }
            
            if let searchTokens = searchTokens?.wrappedValue {
                if uiView.searchTextField.tokens.map(\._SwiftUIX_text) != searchTokens.map(\.text) {
                    uiView.searchTextField.tokens = searchTokens.map({ .init($0) })
                }
            } else {
                if !uiView.searchTextField.tokens.isEmpty {
                    uiView.searchTextField.tokens = []
                }
            }
        }

        (uiView as? _UISearchBar)?.isFirstResponderBinding = isFocused

        updateResponderChain: do {
            if environment.isEnabled {
                DispatchQueue.main.async {
                    if let isFocused = isFocused, uiView.window != nil {
                        if isFocused.wrappedValue && !(searchController?.isActive ?? uiView.isFirstResponder) {
                            uiView.becomeFirstResponder()
                            
                            searchController?.isActive = true
                        } else if !isFocused.wrappedValue && (searchController?.isActive ?? uiView.isFirstResponder) {
                            uiView.resignFirstResponder()
                            
                            searchController?.isActive = false
                        }
                    }
                }
            }
        }
    }
    
    public class Coordinator: NSObject, UISearchBarDelegate {
        var base: SearchBar
        
        init(base: SearchBar) {
            self.base = base
        }
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            base.isFocused?.removeDuplicates().wrappedValue = true
            
            base.onEditingChanged(true)
        }
        
        public func searchBar(_ searchBar: UIViewType, textDidChange searchText: String) {
            base.text = searchText
        }

        public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return true
        }

        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(false)
            
            base.isFocused?.removeDuplicates().wrappedValue = false
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.isFocused?.removeDuplicates().wrappedValue = false

            base.onCancel()
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.isFocused?.removeDuplicates().wrappedValue = false

            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#elseif os(macOS)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar: NSViewRepresentable {
    public final class NSViewType: NSSearchField {
        var isFirstResponderBinding: Binding<Bool>?

        override public func becomeFirstResponder() -> Bool {
            let result = super.becomeFirstResponder()
            
            isFirstResponderBinding?.wrappedValue = result
            
            return result
        }
        
        override public func resignFirstResponder() -> Bool {
            let result = super.resignFirstResponder()
            
            isFirstResponderBinding?.wrappedValue = !result
            
            return result
        }
    }
        
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType(string: placeholder ?? "")

        nsView.delegate = context.coordinator
        nsView.target = context.coordinator
        nsView.action = #selector(context.coordinator.performAction(_:))

        nsView.cell?.sendsActionOnEndEditing = false

        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.base = self
        context.coordinator.view = nsView

        nsView.isFirstResponderBinding = isFocused

        _assignIfNotEqual(NSControl.ControlSize(context.environment.controlSize), to: &nsView.controlSize)
        _assignIfNotEqual(.roundedBezel, to: &nsView.bezelStyle)
        _assignIfNotEqual(focusRingType, to: &nsView.focusRingType)
        _assignIfNotEqual(false, to: &nsView.isBordered)
        _assignIfNotEqual(isBezeled, to: &nsView.isBezeled)
        _assignIfNotEqual(placeholder, to: &nsView.placeholderString)

        (nsView.cell as? NSSearchFieldCell)?.searchButtonCell?.isTransparent = !isBezeled

        if let appKitOrUIKitFont = appKitOrUIKitFont {
            _assignIfNotEqual(appKitOrUIKitFont, to: &nsView.font)
        }

        _assignIfNotEqual(text, to: &nsView.stringValue)
    }
    
    final public class Coordinator: NSObject, NSSearchFieldDelegate {
        var base: SearchBar
        
        weak var view: NSViewType?
        
        init(base: SearchBar) {
            self.base = base
        }
        
        public func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else {
                return
            }
            
            base.text = textField.stringValue
        }
        
        public func controlTextDidBeginEditing(_ notification: Notification) {
            base.onEditingChanged(true)
        }
        
        public func controlTextDidEndEditing(_ notification: Notification) {
            base.onEditingChanged(false)
        }
        
        @objc
        fileprivate func performAction(_ sender: NSTextField?) {
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

#endif

// MARK: - API

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar {
    public func customAppKitOrUIKitClass(_ cls: AppKitOrUIKitSearchBar.Type) -> Self {
        then({ $0.customAppKitOrUIKitClass = cls })
    }
}

extension SearchBar {
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.isInitialFirstResponder = isInitialFirstResponder })
    }

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public func focused(_ isFocused: Binding<Bool>) -> Self {
        then({ $0.isFocused = isFocused })
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar {
    public func searchTokens(_ tokens: Binding<[SearchToken]>) -> Self {
        then({ $0.searchTokens = tokens })
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar {
    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    public func placeholder(_ placeholder: String?) -> Self {
        then({ $0.placeholder = placeholder })
    }
    #endif

    /// Sets the default font for text in the view.
    public func font(_ font: AppKitOrUIKitFont?) -> Self {
        then({ $0.appKitOrUIKitFont = font })
    }

    /// Sets the default font for text in the view.
    public func font<F: FontFamily>(_ font: F, size: CGFloat) -> Self {
        self.font(AppKitOrUIKitFont(name: font.rawValue, size: size))
    }

    public func foregroundColor(_ foregroundColor: AppKitOrUIKitColor) -> Self {
        then({ $0.appKitOrUIKitForegroundColor = foregroundColor })
    }
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @_disfavoredOverload
    public func foregroundColor(_ foregroundColor: Color) -> Self {
        then({ $0.appKitOrUIKitForegroundColor = foregroundColor.toUIColor() })
    }
    
    public func textFieldBackgroundColor(_ backgroundColor: UIColor) -> Self {
        then({ $0.appKitOrUIKitSearchFieldBackgroundColor = backgroundColor })
    }
    
    @_disfavoredOverload
    public func textFieldBackgroundColor(_ backgroundColor: Color) -> Self {
        then({ $0.appKitOrUIKitSearchFieldBackgroundColor = backgroundColor.toUIColor() })
    }
    
    public func searchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        then({ $0.searchBarStyle = searchBarStyle })
    }
    
    public func iconImage(_ icon: UISearchBar.Icon, _ image: AppKitOrUIKitImage) -> Self {
        then({ $0.iconImageConfiguration[icon] = image })
    }
    
    public func showsCancelButton(_ showsCancelButton: Bool) -> Self {
        then({ $0.showsCancelButton = showsCancelButton })
    }
    
    public func onCancel(perform action: @escaping () -> Void) -> Self {
        then({ $0.onCancel = action })
    }
    
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        then({ $0.returnKeyType = returnKeyType })
    }
    
    public func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        then({ $0.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
    
    public func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        then({ $0.isSecureTextEntry = isSecureTextEntry })
    }
    
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        then({ $0.textContentType = textContentType })
    }
    
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        then({ $0.keyboardType = keyboardType })
    }
    #endif

    #if os(macOS)
    public func focusRingType(_ focusRingType: NSFocusRingType) -> Self {
        then({ $0.focusRingType = focusRingType })
    }

    public func isBezeled(_ isBezeled: Bool) -> Self {
        then({ $0.isBezeled = isBezeled })
    }
    #endif
}

// MARK: - Auxiliary

#if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
private final class _UISearchBar: UISearchBar {
    var isFirstResponderBinding: Binding<Bool>?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        
        isFirstResponderBinding?.wrappedValue = result
        
        return result
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        isFirstResponderBinding?.wrappedValue = !result
        
        return result
    }
}
#endif

#endif

// MARK: - Development Preview -

#if (os(iOS) && canImport(CoreTelephony)) || targetEnvironment(macCatalyst)
@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar("Search...", text: .constant(""))
            .searchBarStyle(.minimal)
    }
}
#endif
