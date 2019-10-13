//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CollectionView<SelectionValue: Hashable, Content: View>: View {
    struct Index: Identifiable {
        var value: IndexPath
        
        init(_ value: IndexPath) {
            self.value = value
        }
        
        var id: Int {
            return value.hashValue
        }
    }
    
    private let numberOfSections: Int
    private let numberOfRowsForSection: (Int) -> Int
    private let layout: CollectionViewLayout
    private let makeCellView: (Index) -> AnyView
    private let selection: Binding<Set<SelectionValue>>?
    
    var indices: [Index] {
        return (0..<numberOfSections).flatMap { section in
            (0..<numberOfRowsForSection(section)).map { row in
                Index(IndexPath(row: row, section: section ))
            }
        }
    }
    
    public var body: some View {
        _CollectionView<[Index], AnyView>.init(
            data: indices,
            collectionViewLayout: layout._toUICollectionViewLayout(),
            makeCellView: makeCellView
        )
    }
}

extension CollectionView {
    fileprivate init<Data: RandomAccessCollection, RowContent: View>(
        layout: CollectionViewLayout = CollectionViewFlowLayout(),
        data: Data,
        selection: Binding<Set<SelectionValue>>? = nil,
        @ViewBuilder _rowContent: @escaping (Data.Element) -> RowContent
    ) where Data.Element: Identifiable {
        self.numberOfSections = 1
        self.numberOfRowsForSection = { _ in data.count }
        self.layout = layout
        self.selection = selection
        self.makeCellView = { index in
            let elementIndex = data.index(data.startIndex, offsetBy: index.value.item)
            
            return _rowContent(data[elementIndex]).eraseToAnyView()
        }
    }
    
    public init<Data: RandomAccessCollection, RowContent: View>(
        layout: CollectionViewLayout = CollectionViewFlowLayout(),
        data: Data,
        selection: Binding<Set<SelectionValue>>? = nil,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data.Element: Identifiable {
        self.numberOfSections = 1
        self.numberOfRowsForSection = { _ in data.count }
        self.layout = layout
        self.selection = selection
        self.makeCellView = { index in
            let elementIndex = data.index(data.startIndex, offsetBy: index.value.item)
            
            return rowContent(data[elementIndex]).eraseToAnyView()
        }
    }
}

extension CollectionView where SelectionValue == Never {
    private struct ViewListIndex: Identifiable {
        var id: Int
    }
    
    public init(
        layout: CollectionViewLayout = CollectionViewFlowLayout(),
        @ViewBuilder _ content: () -> Content
    ) {
        let viewList = (content() as? ViewListMaker)?.makeViewList() ?? [content().eraseToAnyView()]
        
        self.init(
            layout: layout,
            data: viewList.indices.map(ViewListIndex.init),
            _rowContent: { viewList[$0.id] }
        )
    }
    
    public init<Data: RandomAccessCollection, RowContent: View>(
        layout: CollectionViewLayout = CollectionViewFlowLayout(),
        data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data.Element: Identifiable {
        self.init(layout: layout, data: data, selection: nil, rowContent: rowContent)
    }
}

#endif
