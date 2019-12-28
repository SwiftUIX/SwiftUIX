//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct SearchBar: UIViewRepresentable {
    public typealias UIViewType = UISearchBar
    
    @Binding fileprivate var text: String
    
    private let onEditingChanged: (Bool) -> ()
    private let onCommit: () -> ()
    
    private var searchBarStyle: UISearchBar.Style = .default
    
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
        
        configureUIView(uiView, context: context)
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        configureUIView(uiView, context: context)
    }

    public func configureUIView(_ uiView: UIViewType, context: Context) {
        uiView.searchBarStyle = searchBarStyle
        uiView.text = text
        uiView.tintColor = Color.accentColor.toUIColor()
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
            
            base.onEditingChanged(true)
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            base.onEditingChanged(false)
            base.onCommit()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(base: self)
    }
}

extension SearchBar {
    public func searchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        then { $0.searchBarStyle = searchBarStyle }
    }
}

#endif
