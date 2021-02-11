//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CollectionView: View {
    public typealias Offset = ScrollView<AnyView>.ContentOffset
    
    private let internalBody: AnyView
    private var scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
    public var body: some View {
        internalBody.environment(\._scrollViewConfiguration, scrollViewConfiguration)
    }
    
    fileprivate init(internalBody: AnyView) {
        self.internalBody = internalBody
    }
}

extension CollectionView {
    public init<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable, RowContent: View>(
        _ dataSource: Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>,
        rowContent: @escaping (ItemIdentifierType) -> RowContent
    ) {
        self.init(
            internalBody:
                _CollectionView(
                    .dynamic(dataSource),
                    sectionHeader: Never.produce,
                    sectionFooter: Never.produce,
                    rowContent: rowContent
                )
                .eraseToAnyView()
        )
    }
    
    public init<Data: RandomAccessCollection, RowContent: View>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where Data.Element: Identifiable {
        self.init(
            internalBody:
                _CollectionView(
                    [ListSection(model: 0, items: data.lazy.map(_IdentifierHashedValue.init))],
                    sectionHeader: Never.produce,
                    sectionFooter: Never.produce,
                    rowContent: { rowContent($0.value) }
                )
                .eraseToAnyView()
        )
    }
    
    public init<Data: RandomAccessCollection, ID: Hashable, RowContent: View>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.init(
            internalBody:
                _CollectionView(
                    [ListSection(model: 0, items: data.lazy.map({ _IdentifierHashedValue(KeyPathHashIdentifiableValue(value: $0, keyPath: id)) }))],
                    sectionHeader: Never.produce,
                    sectionFooter: Never.produce,
                    rowContent: { rowContent($0.value.value) }
                )
                .eraseToAnyView()
        )
    }
}

// MARK: - API -

extension CollectionView {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0.scrollViewConfiguration.onOffsetChange = body })
    }
    
    @available(tvOS, unavailable)
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0.scrollViewConfiguration.onRefresh = body })
    }
    
    @available(tvOS, unavailable)
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0.scrollViewConfiguration.isRefreshing = isRefreshing })
    }
    
    @_disfavoredOverload
    @available(tvOS, unavailable)
    public func refreshControlTintColor(_ color: UIColor?) -> Self {
        then({ $0.scrollViewConfiguration.refreshControlTintColor = color })
    }
    
    @available(tvOS, unavailable)
    public func refreshControlTintColor(_ color: Color?) -> Self {
        then({ $0.scrollViewConfiguration.refreshControlTintColor = color?.toUIColor() })
    }
}

#endif

// MARK: - Auxiliary Implementation -

fileprivate struct _IdentifierHashedValue<Value: Identifiable>: Hashable, Identifiable {
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    var id: Value.ID {
        value.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
