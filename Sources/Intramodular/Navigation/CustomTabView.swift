//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(watchOS, unavailable)
public struct CustomTabView<SelectionValue: Hashable, Content: View>: View {
    private let _tabView: TabView<SelectionValue, Content>
    
    public init(
        selection: Binding<SelectionValue>?,
        @ViewBuilder content: () -> Content
    ) {
        _tabView = .init(selection: selection, content: content)
    }
    
    public var body: some View {
        _tabView.backgroundPreferenceValue(CustomTabViewBackground.self, { $0 })
    }
}

@available(watchOS, unavailable)
extension CustomTabView where SelectionValue == Int {
    public init(@ViewBuilder content: () -> Content) {
        _tabView = .init(content: content)
    }
}

// MARK: - Auxiliary Implementation -

private class CustomTabViewBackground: TakeFirstPreferenceKey<AnyView> {
    
}

extension View {
    public func tabBackground<Background: View>(_ view: Background) -> some View {
        preference(key: CustomTabViewBackground.self, value: .init(view))
    }
}
