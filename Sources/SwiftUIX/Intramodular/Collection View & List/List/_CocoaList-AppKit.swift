//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Swift
import SwiftUI

struct _CocoaList<Configuration: _CocoaListConfigurationType> {
    typealias Offset = ScrollView<AnyView>.ContentOffset
    
    let configuration: Configuration
        
    init(configuration: Configuration) {
        self.configuration = configuration
    }
}

extension _CocoaList: NSViewRepresentable {
    public typealias Coordinator = _PlatformTableView<Configuration>.Coordinator
    public typealias NSViewType = _PlatformTableView<Configuration>

    func makeNSView(
        context: Context
    ) -> NSViewType {
        NSViewType(coordinator: context.coordinator)
    }
    
    func updateNSView(
        _ view: NSViewType,
        context: Context
    ) {
        context.coordinator.configuration = configuration
        
        view.tableView.reloadData()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}

// MARK: - Initializers

extension _CocoaList {
    init<
        SectionType: Identifiable,
        ItemType: Identifiable,
        Data: RandomAccessCollection<ListSection<SectionType, ItemType>>,
        SectionHeader: View,
        SectionFooter: View,
        RowContent: View
    >(
        _ data: Data,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) where Configuration == _CocoaListConfiguration<_CocoaListData<SectionType, ItemType>, _CocoaListViewProvider<SectionType, ItemType, SectionHeader, SectionFooter, RowContent>> {
        self.init(
            configuration: .init(
                data: .init(data),
                viewProvider: .init(
                    sectionHeader: sectionHeader,
                    sectionFooter: sectionFooter,
                    rowContent: rowContent
                )
            )
        )
    }
}

extension _CocoaList {
    init<
        Data: RandomAccessCollection,
        ItemType,
        ID: Hashable,
        RowContent: View
    >(
        _ data: Data,
        id: KeyPath<ItemType, ID>,
        @ViewBuilder rowContent: @escaping (ItemType) -> RowContent
    ) where Data.Element == ItemType, Configuration == _CocoaListConfiguration<_CocoaListData<_KeyPathHashIdentifiableValue<Int, Int>, _KeyPathHashIdentifiableValue<ItemType, ID>>, _CocoaListViewProvider<_KeyPathHashIdentifiableValue<Int, Int>, _KeyPathHashIdentifiableValue<ItemType, ID>, Never, Never, RowContent>> {
        self.init(
            AnyRandomAccessCollection(
                [
                    ListSection(
                        _KeyPathHashIdentifiableValue(
                            value: 0,
                            keyPath: \.self
                        ),
                        items: data.elements(identifiedBy: id)
                    )
                ]
            ),
            sectionHeader: Never.produce,
            sectionFooter: Never.produce,
            rowContent: {
                rowContent($0.value)
            }
        )
    }
}

#endif
