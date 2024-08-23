//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol _SectionView: View {
    associatedtype Parent: View
    associatedtype Content: View
    associatedtype Footer: View
    
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Parent,
        @ViewBuilder footer: () -> Footer
    )
    
    init(
        header: Parent,
        footer: Footer,
        content: Content
    )
    
    init(
        header: Parent,
        footer: Footer,
        @ViewBuilder content: () -> Content
    )
}

extension _SectionView {
    public init(
        header: Parent,
        footer: Footer,
        content: Content
    ) {
        self.init(content: { content }, header: { header }, footer: { footer })
    }
    
    public init(
        header: Parent,
        footer: Footer,
        @ViewBuilder content: () -> Content
    ) {
        self.init(content: { content() }, header: { header }, footer: { footer })
    }
    
    public init(
        header: Parent,
        @ViewBuilder content: () -> Content
    ) where Footer == EmptyView {
        self.init(content: { content() }, header: { header }, footer: { EmptyView() })
    }
    
    public init(
        header: Parent,
        content: Content
    ) where Footer == EmptyView {
        self.init(content: { content }, header: { header }, footer: { EmptyView() })
    }
}

extension Section: _SectionView where Parent: View, Content: View, Footer: View {
    
}

fileprivate struct _SwiftUI_Section<Parent, Content, Footer> {
    let header: Parent
    let content: Content
    let footer: Footer
}

extension Section {
    fileprivate var _internalStructure: _SwiftUI_Section<Parent, Content, Footer> {
        if MemoryLayout<Self>.size == MemoryLayout<(Parent, Content, Footer)>.size {
            let guts = unsafeBitCast(self, to: (Parent, Content, Footer).self)
            
            return .init(header: guts.0, content: guts.1, footer: guts.2)
        } else {
            let mirror = Mirror(reflecting: self)
            
            let header = mirror[_SwiftUIX_keyPath: "header"] as! Parent
            let content = mirror[_SwiftUIX_keyPath: "content"] as! Content
            let footer = mirror[_SwiftUIX_keyPath: "footer"] as! Footer
            
            return .init(header: header, content: content, footer: footer)
        }
    }
    
    public var header: Parent {
        _internalStructure.header
    }
    
    public var content: Content {
        _internalStructure.content
    }
    
    public var footer: Footer {
        _internalStructure.footer
    }
}

extension _SectionView where Parent == Text, Content: View, Footer == EmptyView {
    @_disfavoredOverload
    public init(
        _ header: Text,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: header, content: content)
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ header: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), content: content)
    }
    
    @_disfavoredOverload
    public init(
        _ header: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), content: content)
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(
        header: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), content: content)
    }
}

extension _SectionView where Parent == Text, Content: View, Footer == Text {
    public init<S: StringProtocol>(
        header: S,
        footer: S,
        @ViewBuilder content: () -> Content
    ) {
        self.init(header: Text(header), footer: Text(footer), content: content())
    }
}

@_documentation(visibility: internal)
public struct _SectionX<Header: View, Content: View, Footer: View>: _SectionView {
    public let header: Header
    public let content: Content
    public let footer: Footer
    
    public var body: some View {
        _VariadicViewAdapter(content) { content in
            Section(
                header: header,
                footer: footer
            ) {
                content
            }
        }
    }
    
    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
    }
}
