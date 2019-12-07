//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct AdaptableSection<Parent: View, Footer: View, Content: View>: View {
    private let header: Parent
    private let footer: Footer
    private let content: Content
    
    public init(
        header: Parent,
        footer: Footer,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    public var body: some View {
        VStack {
            HStack {
                header
                Spacer()
            }
            content
            HStack {
                footer
                Spacer()
            }
        }
    }
}

extension AdaptableSection where Footer == EmptyView {
    public init(
        header: Parent,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: header, footer: EmptyView(), content: content)
    }
}
