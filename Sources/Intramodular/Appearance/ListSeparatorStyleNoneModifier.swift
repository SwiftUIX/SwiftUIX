//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

public struct ListSeparatorStyleNoneModifier: ViewModifier {
    @inlinable
    public func body(content: Content) -> some View {
        content.onAppear {
            UITableView.appearance().separatorStyle = .none
        }.onDisappear {
            UITableView.appearance().separatorStyle = .singleLine
        }
    }
    
    @usableFromInline
    init() {
        
    }
}

extension View {
    @available(iOS, introduced: 13.4, deprecated: 14.0, message: "This no longer works on iOS 14.")
    @inlinable
    public func listSeparatorStyleNone() -> some View {
        modifier(ListSeparatorStyleNoneModifier())
    }
}

#endif
