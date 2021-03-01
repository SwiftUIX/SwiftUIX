//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

/// A specialized view for receiving search-related information from the user.
public struct SearchBar: DefaultTextInputType {
    @Binding fileprivate var text: String
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @ObservedObject private var keyboard = Keyboard.main
    #endif
    
    private let onEditingChanged: (Bool) -> Void
    private let onCommit: () -> Void
    
    private var placeholder: String?
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    private var searchBarStyle: UISearchBar.Style = .minimal
    #endif
    
    private var showsCancelButton: Bool = false
    private var onCancel: () -> Void = { }
    
    var customAppKitOrUIKitClass: AppKitOrUIKitSearchBar.Type?
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    private var returnKeyType: UIReturnKeyType?
    private var enablesReturnKeyAutomatically: Bool?
    private var isSecureTextEntry: Bool = false
    private var textContentType: UITextContentType? = nil
    private var keyboardType: UIKeyboardType?
    #endif
    
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

#if os(iOS) || targetEnvironment(macCatalyst)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar: UIViewRepresentable {
    public typealias UIViewType = UISearchBar
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIViewType()
        
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.base = self
        
        uiView.placeholder = placeholder
        uiView.searchBarStyle = searchBarStyle
        
        if uiView.text != text {
            uiView.text = text
        }
        
        uiView.tintColor = context.environment.tintColor?.toUIColor()
        
        uiView.setShowsCancelButton(showsCancelButton, animated: true)
        
        if let returnKeyType = returnKeyType {
            uiView.returnKeyType = returnKeyType
        }
        
        if let keyboardType = keyboardType {
            uiView.keyboardType = keyboardType
        }
        
        if let enablesReturnKeyAutomatically = enablesReturnKeyAutomatically {
            uiView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        }
    }
    
    public class Coordinator: NSObject, UISearchBarDelegate {
        var base: SearchBar
        
        init(base: SearchBar) {
            self.base = base
        }
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(true)
        }
        
        public func searchBar(_ searchBar: UIViewType, textDidChange searchText: String) {
            base.text = searchText
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(false)
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.onCancel()
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(base: self)
    }
}

#elseif os(macOS)

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar: NSViewRepresentable {
    public typealias NSViewType = NSSearchField
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSSearchField(string: placeholder ?? "")
        
        nsView.delegate = context.coordinator
        nsView.target = context.coordinator
        nsView.action = #selector(context.coordinator.performAction(_:))
        
        nsView.bezelStyle = .roundedBezel
        nsView.cell?.sendsActionOnEndEditing = false
        nsView.isBordered = false
        nsView.isBezeled = true
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSSearchField, context: Context) {
        context.coordinator.base = self
        
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    final public class Coordinator: NSObject, NSSearchFieldDelegate {
        var base: SearchBar
        
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

// MARK: - API -

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar {
    public func customAppKitOrUIKitClass(_ cls: AppKitOrUIKitSearchBar.Type) -> Self {
        then({ $0.customAppKitOrUIKitClass = cls })
    }
}

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension SearchBar {
    #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }
    #endif
    
    #if os(iOS) || targetEnvironment(macCatalyst)
    public func searchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        then({ $0.searchBarStyle = searchBarStyle })
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
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || targetEnvironment(macCatalyst)

extension UISearchBar {
    /// Retrieves the UITextField contained inside the UISearchBar.
    ///
    /// - Returns: the UITextField inside the UISearchBar
    func _retrieveTextField() -> UITextField? {
        findSubview(ofKind: UITextField.self)
    }
}

#endif

#endif
