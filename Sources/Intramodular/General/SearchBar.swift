//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct SearchBar: UIViewRepresentable {
    @Binding fileprivate var text: String
    
    private let onEditingChanged: (Bool) -> ()
    private let onCommit: () -> ()
    
    fileprivate var searchBarStyle: UISearchBar.Style = .default
    
    public init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
    
    public func makeUIView(context: Context) -> UISearchBar {
        UISearchBar(frame: .zero).then {
            $0.configure(for: self)
            $0.delegate = context.coordinator
        }
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.configure(for: self)
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

extension UISearchBar {
    public func configure(for parent: SearchBar) {
        searchBarStyle = parent.searchBarStyle
        text = parent.text
        tintColor = Color.accentColor.toUIColor()
    }
}

#endif
