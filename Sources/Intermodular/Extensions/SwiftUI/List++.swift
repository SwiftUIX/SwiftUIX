//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension List {
    #if swift(>=5.5.1) || (swift(>=5.5) && !targetEnvironment(macCatalyst) && !os(macOS))
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
