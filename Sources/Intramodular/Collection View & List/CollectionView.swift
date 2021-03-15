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
    
    private var _collectionViewConfiguration = _CollectionViewConfiguration()
    private var _dynamicViewContentTraitValues = _DynamicViewContentTraitValues()
    private var _scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>()
    
    public var body: some View {
        internalBody
            .environment(\._collectionViewConfiguration, _collectionViewConfiguration)
            .environment(\._dynamicViewContentTraitValues, _dynamicViewContentTraitValues)
            .environment(\._scrollViewConfiguration, _scrollViewConfiguration)
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
                    .diffableDataSource(dataSource),
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
            internalBody: _CollectionView(
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
            internalBody: _CollectionView(
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
    /// Sets the deletion action for the dynamic view.
    ///
    /// - Parameter action: The action that you want SwiftUI to perform when
    ///   elements in the view are deleted. SwiftUI passes a set of indices to the
    ///   closure that's relative to the dynamic view's underlying collection of
    ///   data.
    ///
    /// - Returns: A view that calls `action` when elements are deleted from the
    ///   original view.
    @available(tvOS, unavailable)
    public func onDelete(perform action: ((IndexSet) -> Void)?) -> Self {
        then({ $0._dynamicViewContentTraitValues.onDelete = action })
    }
    
    /// Sets the move action for the dynamic view.
    ///
    /// - Parameters:
    ///   - action: A closure that SwiftUI invokes when elements in the dynamic
    ///     view are moved. The closure takes two arguments that represent the
    ///     offset relative to the dynamic view's underlying collection of data.
    ///     Pass `nil` to disable the ability to move items.
    ///
    /// - Returns: A view that calls `action` when elements are moved within the
    ///   original view.
    @available(tvOS, unavailable)
    public func onMove(perform action: ((IndexSet, Int) -> Void)?) -> Self {
        then({ $0._dynamicViewContentTraitValues.onMove = action })
    }
    
    /// Sets the move action (if available) for the dynamic view.
    ///
    /// - Parameters:
    ///   - action: A closure that SwiftUI invokes when elements in the dynamic
    ///     view are moved. The closure takes two arguments that represent the
    ///     offset relative to the dynamic view's underlying collection of data.
    ///     Pass `nil` to disable the ability to move items.
    ///
    /// - Returns: A view that calls `action` when elements are moved within the
    ///   original view.
    public func onMoveIfAvailable(perform action: ((IndexSet, Int) -> Void)?) -> Self {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return onMove(perform: action)
        #else
        return self
        #endif
    }
}

extension CollectionView {
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        then({ $0._collectionViewConfiguration.allowsMultipleSelection = allowsMultipleSelection })
    }
}

extension CollectionView {
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0._scrollViewConfiguration.onOffsetChange = body })
    }
    
    public func disableAnimatingDifferences(_ disableAnimatingDifferences: Bool) -> Self {
        then({ $0._collectionViewConfiguration.disableAnimatingDifferences = disableAnimatingDifferences })
    }
    
    @available(tvOS, unavailable)
    public func reorderingCadence(_ reorderingCadence: UICollectionView.ReorderingCadence) -> Self {
        then({
            #if !os(tvOS)
            $0._collectionViewConfiguration.reorderingCadence = reorderingCadence
            #else
            _ = $0
            #endif
        })
    }
}

extension CollectionView {
    @available(tvOS, unavailable)
    public func onRefresh(_ body: @escaping () -> Void) -> Self {
        then({ $0._scrollViewConfiguration.onRefresh = body })
    }
    
    @available(tvOS, unavailable)
    public func isRefreshing(_ isRefreshing: Bool) -> Self {
        then({ $0._scrollViewConfiguration.isRefreshing = isRefreshing })
    }
    
    @_disfavoredOverload
    @available(tvOS, unavailable)
    public func refreshControlTintColor(_ color: UIColor?) -> Self {
        then({ $0._scrollViewConfiguration.refreshControlTintColor = color })
    }
    
    @available(tvOS, unavailable)
    public func refreshControlTintColor(_ color: Color?) -> Self {
        then({ $0._scrollViewConfiguration.refreshControlTintColor = color?.toUIColor() })
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
        return lhs.id == rhs.id
    }
}
