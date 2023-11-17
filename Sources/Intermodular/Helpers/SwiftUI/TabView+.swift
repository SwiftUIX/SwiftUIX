//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension TabView  {
    public init<_Content: View>(
        _ titles: [String],
        @ViewBuilder content: () -> _Content
    ) where SelectionValue == Int, Content == _SwiftUIX_TitledTabViewContent<_Content> {
        self.init(content: {
            _SwiftUIX_TitledTabViewContent(
                titles,
                content: content
            )
        })
    }
    
    public init<_Content: View>(
        _ titles: String...,
        @ViewBuilder content: () -> _Content
    ) where SelectionValue == Int, Content == _SwiftUIX_TitledTabViewContent<_Content> {
        self.init(titles, content: content)
    }
}

public struct _SwiftUIX_TitledTabViewContent<Content: View>: View {
    let titles: [String]
    let content: Content
    
    public init(
        _ titles: [String],
        @ViewBuilder content: () -> Content
    ) {
        self.titles = titles
        self.content = content()
    }
    
    public var body: some View {
        _VariadicViewAdapter(content) { content in
            if titles.count == content.children.count {
                _ForEachSubview(enumerating: content) { (index, subview) in
                    subview.tabItem {
                        Text(verbatim: titles[index])
                    }
                }
            }
        }
    }
}

