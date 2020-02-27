//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct SearchBar: UIViewRepresentable {
    public typealias UIViewType = UISearchBar
    
    @Binding fileprivate var text: String
    
    private let onEditingChanged: (Bool) -> Void
    private let onCommit: () -> Void
    
    private var placeholder: String?
    private var searchBarStyle: UISearchBar.Style = .minimal
    private var showsCancelButton: Bool = false
    private var onCancel: () -> Void = { }
    
    @Environment(\.tintColor) var tintColor
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UIViewType()
        
        uiView.delegate = context.coordinator
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.placeholder = placeholder
        uiView.searchBarStyle = searchBarStyle
        uiView.text = text
        
        if #available(iOS 13.1, *) {
            uiView.tintColor = tintColor?.toUIColor()
        }
        
        uiView.setShowsCancelButton(showsCancelButton, animated: true)
    }
    
    public class Coordinator: NSObject, UISearchBarDelegate {
        let base: SearchBar
        
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
            base.onCancel()
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(base: self)
    }
}

extension SearchBar {
    public func placeholder(_ placeholder: String) -> Self {
        then({ $0.placeholder = placeholder })
    }

    public func searchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        then({ $0.searchBarStyle = searchBarStyle })
    }

    public func showsCancelButton(_ shows: Bool) -> Self {
        then({ $0.showsCancelButton = showsCancelButton })
    }
    
    public func onCancel(perform action: @escaping () -> Void) -> Self {
        then({ $0.onCancel = action })
    }
}

#endif
