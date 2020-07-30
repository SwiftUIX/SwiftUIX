//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.3)

import Swift
import SwiftUI

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
fileprivate struct _bugfix_Toolbar_API_1<_Content: View>: ViewModifier {
    @State var hasAppeared: Bool = false
    
    let content: () -> _Content
    
    func body(content: Content) -> some View {
        ZStack {
            if hasAppeared {
                ZeroSizeView()
                    .toolbar(content: self.content)
            }
            
            content
        }
        .onAppear(perform: { self.hasAppeared = true })
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
fileprivate struct _bugfix_Toolbar_API_2<Items>: ViewModifier {
    @State var hasAppeared: Bool = false
    
    let items: () -> ToolbarItemGroup<Void, Items>
    
    func body(content: Content) -> some View {
        ZStack {
            if hasAppeared {
                ZeroSizeView()
                    .toolbar(items: items)
            }
            
            content
        }
        .onAppear(perform: { self.hasAppeared = true })
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
fileprivate struct _bugfix_Toolbar_API_3<Items>: ViewModifier {
    @State var hasAppeared: Bool = false
    
    let id: String
    let items: () -> ToolbarItemGroup<String, Items>
    
    func body(content: Content) -> some View {
        ZStack {
            if hasAppeared {
                ZeroSizeView()
                    .toolbar(id: id, items: items)
            }
            
            content
        }
        .onAppear(perform: { self.hasAppeared = true })
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Populates the toolbar or navigation bar with items
    /// whose content is the specified views.
    ///
    /// - Parameter content: The views representing the content of the toolbar.
    @ViewBuilder
    public func _bugfix_toolbar<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        modifier(_bugfix_Toolbar_API_1(content: content))
        #else
        toolbar(content: content)
        #endif
    }
    
    /// Populates the toolbar or navigation bar with the specified items.
    ///
    /// - Parameter items: The items representing the content of the toolbar.
    @ViewBuilder
    public func _bugfix_toolbar<Items>(
        @ToolbarContentBuilder<Void> items: @escaping () -> ToolbarItemGroup<Void, Items>
    ) -> some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        modifier(_bugfix_Toolbar_API_2(items: items))
        #else
        toolbar(items: items)
        #endif
    }
    
    /// Populates the toolbar or navigation bar with the specified items,
    /// allowing for user customization.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this toolbar.
    ///   - items: The items representing the content of the toolbar.
    @ViewBuilder
    public func _bugfix_toolbar<Items>(
        id: String,
        @ToolbarContentBuilder<String> items: @escaping () -> ToolbarItemGroup<String, Items>
    ) -> some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        modifier(_bugfix_Toolbar_API_3(id: id, items: items))
        #else
        toolbar(id: id, items: items)
        #endif
    }
}

#endif
