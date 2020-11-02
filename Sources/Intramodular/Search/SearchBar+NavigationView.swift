//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

fileprivate struct _NavigationSearchBarConfigurator<SearchResultsContent: View>: UIViewControllerRepresentable  {
    let searchBar: SearchBar
    let searchResultsContent: () -> SearchResultsContent
    
    var automaticallyShowSearchBar: Bool? = true
    var hideNavigationBarDuringPresentation: Bool?
    var hideSearchBarOnScroll: Bool?
    var obscuresBackgroundDuringPresentation: Bool?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(base: self, searchBarCoordinator: .init(base: searchBar))
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.base = self
        context.coordinator.searchBarCoordinator.base = searchBar
        context.coordinator.uiViewController = uiViewController
        
        context.coordinator.updateSearchController()
    }
}

extension _NavigationSearchBarConfigurator {
    class Coordinator: NSObject, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
        var base: _NavigationSearchBarConfigurator
        var searchBarCoordinator: SearchBar.Coordinator
        var searchController: UISearchController!
        
        weak var uiViewController: UIViewControllerType?
        
        init(
            base: _NavigationSearchBarConfigurator,
            searchBarCoordinator: SearchBar.Coordinator
        ) {
            self.base = base
            self.searchBarCoordinator = searchBarCoordinator
            
            super.init()
            
            initializeSearchController()
        }
        
        func initializeSearchController() {
            let searchResultsController: UIViewController?
            let searchResultsContent = base.searchResultsContent()
            
            if searchResultsContent is EmptyView {
                searchResultsController = nil
            } else {
                searchResultsController = UIHostingController<SearchResultsContent>(rootView: base.searchResultsContent())
            }
            
            searchController = UISearchController(searchResultsController: searchResultsController)
            searchController.definesPresentationContext = true
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = self
            
            updateSearchController()
        }
        
        func updateSearchController() {
            guard let uiViewController = uiViewController else {
                return
            }
            
            if let obscuresBackgroundDuringPresentation = base.obscuresBackgroundDuringPresentation {
                searchController.obscuresBackgroundDuringPresentation = obscuresBackgroundDuringPresentation
            } else {
                searchController.obscuresBackgroundDuringPresentation = false
            }
            
            if let hideNavigationBarDuringPresentation = base.hideNavigationBarDuringPresentation {
                searchController.hidesNavigationBarDuringPresentation = hideNavigationBarDuringPresentation
            }
            
            (searchController.searchResultsController as? UIHostingController<SearchResultsContent>)?.rootView = base.searchResultsContent()
            
            if let hideSearchBarOnScroll = base.hideSearchBarOnScroll {
                uiViewController.hidesSearchBarWhenScrolling = hideSearchBarOnScroll
            }
            
            if let automaticallyShowSearchBar = base.automaticallyShowSearchBar, automaticallyShowSearchBar {
                uiViewController.navigationBarSizeToFit()
            }
            
            if uiViewController.searchController !== searchController {
                uiViewController.searchController = searchController
            }
        }
        
        // MARK: - UISearchBarDelegate
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarTextDidBeginEditing(searchBar)
        }
        
        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchBarCoordinator.searchBar(searchBar, textDidChange: searchText)
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarTextDidEndEditing(searchBar)
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarCancelButtonClicked(searchBar)
            
            searchController.isActive = false
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBarCoordinator.searchBarSearchButtonClicked(searchBar)
            
            searchController.isActive = false
        }
        
        // MARK: UISearchControllerDelegate
        
        func willPresentSearchController(_ searchController: UISearchController) {
            
        }
        
        func didPresentSearchController(_ searchController: UISearchController) {
            
        }
        
        func willDismissSearchController(_ searchController: UISearchController) {
            
        }
        
        func didDismissSearchController(_ searchController: UISearchController) {
            
        }
        
        // MARK: UISearchResultsUpdating
        
        func updateSearchResults(for searchController: UISearchController) {
            
        }
    }
    
    class UIViewControllerType: UIViewController {
        var searchController: UISearchController? {
            get {
                self.parent?.navigationItem.searchController
            } set {
                self.parent?.navigationItem.searchController = newValue
            }
        }
        
        var hidesSearchBarWhenScrolling: Bool {
            get {
                self.parent?.navigationItem.hidesSearchBarWhenScrolling ?? true
            } set {
                self.parent?.navigationItem.hidesSearchBarWhenScrolling = newValue
            }
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
        
        func navigationBarSizeToFit() {
            self.parent?.navigationController?.navigationBar.sizeToFit()
        }
    }
}

// MARK: - API -

extension View {
    public func navigationSearchBar(_ searchBar: () -> SearchBar) -> some View {
        background(_NavigationSearchBarConfigurator(searchBar: searchBar(), searchResultsContent: { EmptyView() }))
    }
}

private struct Previews: PreviewProvider {
    static var previews: some View {
        WithInlineState(initialValue: "") { searchText in
            NavigationView {
                List {
                    Text("1")
                    Text("2")
                    Text("3")
                }
                .navigationSearchBar {
                    SearchBar("test", text: searchText)
                }
            }
        }
    }
}

#endif
