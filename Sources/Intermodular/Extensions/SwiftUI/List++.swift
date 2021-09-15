//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension List {
    #if swift(>=5.5) && !os(macOS)
    @available(watchOS, unavailable)
    public init<Data: RandomAccessCollection, RowContent: View>(
        _ data: Data,
        selection: Binding<Set<SelectionValue>>,
        @ViewBuilder rowContent: @escaping (Data.Element, _ isSelected: Bool) -> RowContent
    ) where Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, RowContent>, SelectionValue == Data.Element.ID {
        self.init(data, selection: selection, rowContent: { element in
            rowContent(element, selection.wrappedValue.contains(element.id))
        })
    }
    
    @available(watchOS, unavailable)
    public init<Data: RandomAccessCollection, RowContent: View>(
        _ data: Data,
        selection: Binding<Set<SelectionValue>>,
        @ViewBuilder rowContent: @escaping (Data.Element, _ isSelected: Bool) -> RowContent
    ) where Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, RowContent>, SelectionValue == Data.Element {
        self.init(data, selection: selection, rowContent: { element in
            rowContent(element, selection.wrappedValue.contains(element))
        })
    }
    #else
    @available(watchOS, unavailable)
    public init<Data: RandomAccessCollection, RowContent: View>(
        _ data: Data,
        selection: Binding<Set<SelectionValue>>,
        @ViewBuilder rowContent: @escaping (Data.Element, _ isSelected: Bool) -> RowContent
    ) where Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, SelectionValue == Data.Element.ID {
        self.init(data, selection: selection, rowContent: { element in
            rowContent(element, selection.wrappedValue.contains(element.id))
        })
    }
    
    @available(watchOS, unavailable)
    public init<Data: RandomAccessCollection, RowContent: View>(
        _ data: Data,
        selection: Binding<Set<SelectionValue>>,
        @ViewBuilder rowContent: @escaping (Data.Element, _ isSelected: Bool) -> RowContent
    ) where Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, SelectionValue == Data.Element {
        self.init(data, selection: selection, rowContent: { element in
            rowContent(element, selection.wrappedValue.contains(element))
        })
    }
    #endif
}

extension List where SelectionValue == Never {
    @available(watchOS, unavailable)
    public init<Data: MutableCollection & RandomAccessCollection, RowContent: View>(
        _ data: Binding<Data>,
        @ViewBuilder rowContent: @escaping (Binding<Data.Element>) -> RowContent
    ) where Data.Element: Identifiable, Content == ForEach<AnyRandomAccessCollection<_IdentifiableElementOffsetPair<Data.Element, Data.Index>>, Data.Element.ID, RowContent> {
        self.init {
            ForEach(data) { (element: Binding<Data.Element>) -> RowContent in
                rowContent(element)
            }
        }
    }
}
