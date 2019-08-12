//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS)

fileprivate struct SystemFillBackgroundModifer: ViewModifier {
    let colorRank: ColorRank

    init(_ colorRank: ColorRank) {
        self.colorRank = colorRank
    }

    func body(content: Content) -> some View {
        switch colorRank {
        case .primary:
            return content
                .background(Color.systemFill)
        case .secondary:
            return content
                .background(Color.secondarySystemFill)
        case .tertiary:
            return content
                .background(Color.tertiarySystemFill)
        case .quaternary:
            return content
                .background(Color.quaternarySystemFill)
        }
    }
}

// MARK: - Helpers -

extension View {
    public func systemFillBackground(_ colorRank: ColorRank) -> some View {
        return modifier(SystemFillBackgroundModifer(colorRank))
    }
}

#endif
