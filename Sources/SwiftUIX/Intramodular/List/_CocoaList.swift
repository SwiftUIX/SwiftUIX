//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Swift
import SwiftUI

struct _CocoaList<Configuration: _CocoaListConfigurationType> {
    @Environment(\._cocoaListPreferences) var _cocoaListPreferences
    
    typealias Offset = ScrollView<AnyView>.ContentOffset
    
    let configuration: Configuration
    
    init(
        configuration: Configuration
    ) {
        self.configuration = configuration
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
extension _CocoaList {
    class Coordinator {
        
    }
}
#endif

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
    ) where Configuration == _CocoaListConfiguration<_AnyCocoaListDataSource<SectionType, ItemType>, _CocoaListViewProvider<SectionType, ItemType, SectionHeader, SectionFooter, RowContent>> {
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

    init<
        Data: RandomAccessCollection,
        ItemType,
        ID: Hashable,
        RowContent: View
    >(
        _ data: Data,
        id: KeyPath<ItemType, ID>,
        @ViewBuilder rowContent: @escaping (ItemType) -> RowContent
    ) where Data.Element == ItemType, Configuration == _CocoaListConfiguration<_AnyCocoaListDataSource<_KeyPathHashIdentifiableValue<Int, Int>, _KeyPathHashIdentifiableValue<ItemType, ID>>, _CocoaListViewProvider<_KeyPathHashIdentifiableValue<Int, Int>, _KeyPathHashIdentifiableValue<ItemType, ID>, Never, Never, RowContent>> {
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
            sectionHeader: Never._SwiftUIX_produce,
            sectionFooter: Never._SwiftUIX_produce,
            rowContent: {
                rowContent($0.value)
            }
        )
    }
}

#endif
