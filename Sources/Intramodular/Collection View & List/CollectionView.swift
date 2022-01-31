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
                    rowContent: { rowContent($1) }
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
                CollectionOfOne(ListSection<Int, _IdentifierHashedValue<Data.Element>>(0, items: data.lazy.map(_IdentifierHashedValue.init))),
                sectionHeader: Never.produce,
                sectionFooter: Never.produce,
                rowContent: { rowContent($1.value) }
            )
            .eraseToAnyView()
        )
    }

    public init<Data: RandomAccessCollection, Header: View, RowContent: View, Footer: View>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Data.Element: Identifiable {
        self.init(
            internalBody: _CollectionView(
                CollectionOfOne(ListSection<Int, _IdentifierHashedValue<Data.Element>>(0, items: data.lazy.map(_IdentifierHashedValue.init))),
                sectionHeader: { _ in header() },
                sectionFooter: { _ in footer() },
                rowContent: { rowContent($1.value) }
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
                CollectionOfOne(ListSection(0, items: data.lazy.map({ _IdentifierHashedValue(KeyPathHashIdentifiableValue(value: $0, keyPath: id)) }))),
                sectionHeader: Never.produce,
                sectionFooter: Never.produce,
                rowContent: { rowContent($1.value.value) }
            )
            .eraseToAnyView()
        )
    }
}

extension CollectionView {
    public init<
        Data: RandomAccessCollection,
        SectionType: Identifiable,
        ItemType: Identifiable,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (SectionType, ListSection<SectionType, ItemType>.Items) -> Section<Header, ForEach<Data.Element.Items, ItemType.ID, RowContent>, Footer>
    ) where Data.Element == ListSection<SectionType, ItemType> {
        self.init(
            internalBody: _CollectionView(
                data.lazy.map { section in
                    ListSection(section, items: section.items)
                },
                sectionHeader: { rowContent($0.model, $0.items).header },
                sectionFooter: { rowContent($0.model, $0.items).footer },
                rowContent: { rowContent($0.model, $0.items).content.content($1) }
            )
            .eraseToAnyView()
        )
    }
    
    public init<
        Data: RandomAccessCollection,
        ID: Hashable,
        Items: RandomAccessCollection,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        sections data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> Section<Header, ForEach<Items, Items.Element.ID, RowContent>, Footer>
    ) where Items.Element: Identifiable {
        self.init(
            internalBody: _CollectionView(
                data.map { section in
                    ListSection(
                        model: _IdentifierHashedValue(
                            KeyPathHashIdentifiableValue(
                                value: section,
                                keyPath: id
                            )
                        ),
                        items: rowContent(section).content.data.map { item in
                            _CollectionViewSectionedItem(item: item, section: section[keyPath: id])
                        }
                    )
                },
                sectionHeader: { section in
                    rowContent(section.value.value).header
                },
                sectionFooter: { section in
                    rowContent(section.value.value).footer
                },
                rowContent: { section, item  in
                    rowContent(section.value.value).content.content(item.item)
                }
            )
            .eraseToAnyView()
        )
    }

    public init<
        Data: RandomAccessCollection,
        ID: Hashable,
        Items: RandomAccessCollection,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        _ axes: Axis.Set,
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> Section<Header, ForEach<Items, Items.Element.ID, RowContent>, Footer>
    ) where Items.Element: Identifiable {
        self.init(sections: data, id: id, rowContent: rowContent)
        
        _scrollViewConfiguration.axes = axes
    }
    
    public init<
        Data: RandomAccessCollection,
        ID: Hashable,
        Items: RandomAccessCollection,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> Section<Header, ForEach<Items, Items.Element.ID, RowContent>, Footer>
    ) where Items.Element: Identifiable {
        self.init(sections: data, id: id, rowContent: rowContent)
    }
    
    @_disfavoredOverload
    public init<
        Data: RandomAccessCollection,
        ID: Hashable,
        Items: RandomAccessCollection,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> Section<Header, ForEach<Items, Items.Element, RowContent>, Footer>
    ) where Items.Element: Hashable {
        self.init(
            internalBody: _CollectionView(
                data.map { section in
                    ListSection(
                        model: _IdentifierHashedValue(
                            KeyPathHashIdentifiableValue(
                                value: section,
                                keyPath: id
                            )
                        ),
                        items: rowContent(section).content.data.map { item in
                            _CollectionViewSectionedItem(item: KeyPathHashIdentifiableValue(value: item, keyPath: \.self), section: section[keyPath: id])
                        }
                    )
                },
                sectionHeader: { section in
                    rowContent(section.value.value).header
                },
                sectionFooter: { section in
                    rowContent(section.value.value).footer
                },
                rowContent: { section, item  in
                    rowContent(section.value.value).content.content(item.item.value)
                }
            )
            .eraseToAnyView()
        )
    }
    
    public init<
        Data: RandomAccessCollection,
        ID: Hashable,
        Items: RandomAccessCollection,
        Header: View,
        RowContent: View,
        Footer: View
    >(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> Section<Header, ForEach<Items, Int, RowContent>, Footer>
    ) where Items.Element: Hashable {
        self.init(
            internalBody: _CollectionView(
                data.map { section in
                    ListSection(
                        model: _IdentifierHashedValue(
                            KeyPathHashIdentifiableValue(
                                value: section,
                                keyPath: id
                            )
                        ),
                        items: rowContent(section).content.data.map { item in
                            _CollectionViewSectionedItem(
                                item: KeyPathHashIdentifiableValue(value: item, keyPath: \.hashValue),
                                section: section[keyPath: id]
                            )
                        }
                    )
                },
                sectionHeader: { section in
                    rowContent(section.value.value).header
                },
                sectionFooter: { section in
                    rowContent(section.value.value).footer
                },
                rowContent: { section, item  in
                    rowContent(section.value.value).content.content(item.item.value)
                }
            )
            .eraseToAnyView()
        )
    }
}

// MARK: - API -

extension CollectionView {
    public func updateOnChange<T: Hashable>(of value: T) -> Self {
        then({ $0._collectionViewConfiguration.dataSourceUpdateToken = value })
    }
}

extension CollectionView {
    /// Set unsafe flags for the collection view.
    public func unsafeFlags(_ flags: _CollectionViewConfiguration.UnsafeFlags) -> Self {
        then({ $0._collectionViewConfiguration.unsafeFlags.formUnion(flags) })
    }
    
    public func _ignorePreferredCellLayoutAttributes() -> Self {
        then({ $0._collectionViewConfiguration.unsafeFlags.formUnion(.ignorePreferredCellLayoutAttributes) })
    }
    
    /// Fixes this view at its ideal size.
    public func fixedSize() -> Self {
        then({ $0._collectionViewConfiguration.fixedSize = (true, true) })
    }
}

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
    
    @available(iOS 13.4, *)
    @available(tvOS, unavailable)
    public func onDrop(delegate: CollectionViewDropDelegate) -> Self {
        then({ $0._dynamicViewContentTraitValues.collectionViewDropDelegate = delegate })
    }
    
    @available(iOS 13.4, *)
    @available(tvOS, unavailable)
    public func onDrop(
        perform action: (([DragItem], Int) -> Void)?
    ) -> Self {
        then({ $0._dynamicViewContentTraitValues.onDrop = action })
    }
    
    /// Sets whether the collection view allows multiple selection.
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        then({ $0._collectionViewConfiguration.allowsMultipleSelection = allowsMultipleSelection })
    }
    
    /// Binds the collection view's drag state to a boolean value.
    public func isDragActive(_ isDragActive: Binding<Bool>) -> Self {
        then({ $0._collectionViewConfiguration.isDragActive = isDragActive })
    }
}

extension CollectionView {
    /// Adds a condition whether for whether the collection view disables bouncing when scrolling reaches the end of the content
    public func scrollBounceDisabled(_ disabled: Bool) -> Self {
        then {
            if !disabled {
                $0._scrollViewConfiguration.alwaysBounceHorizontal = $0._scrollViewConfiguration.axes.contains(.horizontal)
                $0._scrollViewConfiguration.alwaysBounceVertical =  $0._scrollViewConfiguration.axes.contains(.vertical)
            } else {
                $0._scrollViewConfiguration.alwaysBounceHorizontal = false
                $0._scrollViewConfiguration.alwaysBounceVertical = false
            }
        }
    }
    
    /// Sets the collection view's scroll content-offset behavior.
    public func scrollContentOffsetBehavior(_ contentOffsetBehavior: ScrollContentOffsetBehavior) -> Self {
        then({ $0._scrollViewConfiguration.contentOffsetBehavior = contentOffsetBehavior })
    }
    
    /// Performs an action upon scroll content-offset change.
    public func onOffsetChange(_ body: @escaping (Offset) -> ()) -> Self {
        then({ $0._scrollViewConfiguration.onOffsetChange = body })
    }
    
    /// Sets whether the collection view animates differences in the data source.
    public func disableAnimatingDifferences(_ disableAnimatingDifferences: Bool) -> Self {
        then({ $0._collectionViewConfiguration.disableAnimatingDifferences = disableAnimatingDifferences })
    }
    
    /// Sets the collection view's reordering cadence.
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
    public func contentInsets(_ inset: EdgeInsets) -> Self {
        then({ $0._scrollViewConfiguration.contentInset = inset })
    }
    
    public func contentInsets(_ edges: Edge.Set, _ length: CGFloat?) -> Self {
        contentInsets(.init(edges, length))
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

struct _CollectionViewSectionedItem<Item: Identifiable, SectionID: Hashable>: Hashable, Identifiable {
    let item: Item
    let section: SectionID
    
    var id: some Hashable {
        hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
        hasher.combine(section)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.section == rhs.section && lhs.item.id == rhs.item.id
    }
}

struct _IdentifierHashedValue<Value: Identifiable>: CustomStringConvertible, Hashable, Identifiable {
    let value: Value
    
    var description: String {
        String(describing: value)
    }
    
    var id: Value.ID {
        value.id
    }
    
    init(_ value: Value) {
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
