//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol _opaque_UIHostingCollectionViewController: UIViewController {
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func select<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func deselect<ID: Hashable>(_ id: ID)
}

extension UIHostingCollectionViewController {
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cellMetadataCache.firstIndexPath(for: id) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.deselectItem(
            at: indexPath,
            animated: true
        )
    }
    
    private func indexPath<ID: Hashable>(for id: ID) -> IndexPath? {
        cellMetadataCache.firstIndexPath(for: id)
    }
}

public final class UIHostingCollectionViewController<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    CellContent: View
>: UIViewController, _opaque_UIHostingCollectionViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias _SwiftUIType = _CollectionView<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, CellContent>
    typealias UICollectionViewCellType = UIHostingCollectionViewCell<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, CellContent>
    
    public enum DataSource {
        public struct IdentifierMap {
            var getSectionID: (SectionType) -> SectionIdentifierType
            var getSectionFromID: (SectionIdentifierType) -> SectionType
            var getItemID: (ItemType) -> ItemIdentifierType
            var getItemFromID: (ItemIdentifierType) -> ItemType
            
            subscript(_ section: SectionType) -> SectionIdentifierType {
                getSectionID(section)
            }
            
            subscript(_ sectionIdentifier: SectionIdentifierType) -> SectionType {
                getSectionFromID(sectionIdentifier)
            }
            
            subscript(_ item: ItemType) -> ItemIdentifierType {
                getItemID(item)
            }
            
            subscript(_ itemID: ItemIdentifierType) -> ItemType {
                getItemFromID(itemID)
            }
        }
        
        case diffableDataSource(Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>)
        case `static`(AnyRandomAccessCollection<ListSection<SectionType, ItemType>>)
        
        func contains(_ indexPath: IndexPath) -> Bool {
            switch self {
                case .static(let data): do {
                    guard indexPath.section < data.count else {
                        return false
                    }
                    
                    let section = data[data.index(data.startIndex, offsetBy: indexPath.section)]
                    
                    guard indexPath.row < section.items.count else {
                        return false
                    }
                    
                    return true
                }
                
                case .diffableDataSource(let dataSource): do {
                    guard let dataSource = dataSource.wrappedValue else {
                        return false
                    }
                    
                    let snapshot = dataSource.snapshot()
                    
                    guard indexPath.section < snapshot.numberOfSections else {
                        return false
                    }
                    
                    guard indexPath.row < snapshot.numberOfItems(inSection: snapshot.sectionIdentifiers[indexPath.section]) else {
                        return false
                    }
                    
                    return true
                }
            }
        }
    }
    
    var dataSource: DataSource? = nil {
        didSet {
            updateDataSource(oldValue: oldValue, dataSource: dataSource)
        }
    }
    
    var dataSourceConfiguration: _SwiftUIType.DataSourceConfiguration {
        didSet {
            
        }
    }
    
    var viewProvider: _SwiftUIType.ViewProvider {
        didSet {
            
        }
    }
    
    var _scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>() {
        didSet {
            collectionView.configure(with: _scrollViewConfiguration)
        }
    }
    
    var _dynamicViewContentTraitValues = _DynamicViewContentTraitValues() {
        didSet {
            #if !os(tvOS)
            collectionView.dragInteractionEnabled = _dynamicViewContentTraitValues.onMove != nil
            #endif
        }
    }
    
    var configuration: _SwiftUIType.Configuration {
        didSet {
            collectionView.allowsMultipleSelection = configuration.allowsMultipleSelection
            #if !os(tvOS)
            collectionView.reorderingCadence = configuration.reorderingCadence
            #endif
        }
    }
    
    var collectionViewLayout: CollectionViewLayout = FlowCollectionViewLayout() {
        didSet {
            collectionView.setCollectionViewLayout(collectionViewLayout._toUICollectionViewLayout(), animated: true)
        }
    }
    
    private lazy var _animateDataSourceDifferences: Bool = true
    private lazy var _internalDiffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>? = nil
    
    lazy var cellMetadataCache = CellMetadataCache(parent: self)
    
    #if !os(tvOS)
    fileprivate lazy var dragAndDropDelegate = DragAndDropDelegate(parent: self)
    #endif
    
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout._toUICollectionViewLayout())
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        
        #if !os(tvOS)
        collectionView.dragDelegate = dragAndDropDelegate
        collectionView.dropDelegate = dragAndDropDelegate
        #endif
        
        return collectionView
    }()
    
    var maximumCellSize: OptionalDimensions {
        let result = OptionalDimensions(
            width: max(collectionView.contentSize.width - 0.001, 0),
            height: max(collectionView.contentSize.height - 0.001, 0)
        )
        
        guard (result.width != 0 && result.height != 0) else {
            return nil
        }
        
        return result
    }
    
    init(
        dataSourceConfiguration: _SwiftUIType.DataSourceConfiguration,
        viewProvider: _SwiftUIType.ViewProvider,
        configuration: _SwiftUIType.Configuration
    ) {
        self.dataSourceConfiguration = dataSourceConfiguration
        self.viewProvider = viewProvider
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.backgroundColor = .clear
        
        collectionView.register(UICollectionViewCellType.self, forCellWithReuseIdentifier: .hostingCollectionViewCellIdentifier)
        
        let diffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: collectionView) { [weak self] collectionView, indexPath, sectionIdentifier in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            let item = self._unsafelyUnwrappedItem(at: indexPath)
            let section = self._unsafelyUnwrappedSection(from: indexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .hostingCollectionViewCellIdentifier, for: indexPath) as! UICollectionViewCellType
            
            cell.configuration = .init(
                item: item,
                itemIdentifier: self.dataSourceConfiguration.identifierMap[item],
                sectionIdentifier: self.dataSourceConfiguration.identifierMap[section],
                indexPath: indexPath,
                makeContent: self.viewProvider.rowContent,
                maximumSize: self.maximumCellSize
            )
            
            cell.cellWillDisplay(inParent: self)
            
            return cell
        }
        
        self._internalDiffableDataSource = diffableDataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewSafeAreaInsetsDidChange()  {
        super.viewSafeAreaInsetsDidChange()
        
        invalidateLayout(includingCellMetadataCache: false)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        invalidateLayout(includingCellMetadataCache: true)
    }
    
    public func invalidateLayout(includingCellMetadataCache: Bool) {
        if includingCellMetadataCache {
            cellMetadataCache.invalidate()
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDelegate -
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? UICollectionViewCellType)?.cellWillDisplay(inParent: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? UICollectionViewCellType)?.cellDidEndDisplaying()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isHighlightable ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isHighlighted = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isHighlighted = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = cellForItem(at: indexPath) else {
            return false
        }
        
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            return false
        }
        
        return cell.isSelectable
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isSelectable ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isSelected = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isSelected = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isFocusable ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    private let prototypeCell = UICollectionViewCellType()
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellMetadataCache.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension UIHostingCollectionViewController {
    #if !os(tvOS)
    class DragAndDropDelegate: NSObject, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
        unowned let parent: UIHostingCollectionViewController
        
        init(parent: UIHostingCollectionViewController) {
            self.parent = parent
        }
        
        // MARK: - UICollectionViewDragDelegate -
        
        func collectionView(
            _ collectionView: UICollectionView,
            itemsForBeginning session: UIDragSession,
            at indexPath: IndexPath
        ) -> [UIDragItem] {
            [UIDragItem(itemProvider: NSItemProvider())]
        }
        
        // MARK: - UICollectionViewDropDelegate -
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            performDropWith coordinator: UICollectionViewDropCoordinator
        ) {
            if let onMove = parent._dynamicViewContentTraitValues.onMove {
                if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath, var destinationIndexPath = coordinator.destinationIndexPath {
                    parent.cellMetadataCache.invalidateCachedContentSize(forIndexPath: sourceIndexPath)
                    parent.cellMetadataCache.invalidateCachedContentSize(forIndexPath: destinationIndexPath)
                    
                    if sourceIndexPath.item < destinationIndexPath.item {
                        destinationIndexPath.item += 1
                    }
                    
                    onMove(
                        IndexSet([sourceIndexPath.item]),
                        destinationIndexPath.item
                    )
                }
            }
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidUpdate session: UIDropSession,
            withDestinationIndexPath destinationIndexPath: IndexPath?
        ) -> UICollectionViewDropProposal {
            if session.localDragSession == nil {
                return .init(operation: .forbidden, intent: .unspecified)
            }
            
            if collectionView.hasActiveDrag {
                return .init(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            
            return .init(operation: .forbidden)
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidEnd session: UIDropSession
        ) {
            
        }
    }
    #endif
}

extension UIHostingCollectionViewController {
    private func _unsafelyUnwrappedSection(from indexPath: IndexPath) -> SectionType {
        if case .static(let data) = dataSource {
            return data[data.index(data.startIndex, offsetBy: indexPath.section)].model
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.snapshot().sectionIdentifiers[indexPath.section]]
        }
    }
    
    private func _unsafelyUnwrappedItem(at indexPath: IndexPath) -> ItemType {
        if case .static(let data) = dataSource {
            return data[indexPath]
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.itemIdentifier(for: indexPath)!]
        }
    }
    
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCellType? {
        let result = collectionView
            .visibleCells
            .compactMap({ $0 as? UICollectionViewCellType})
            .first(where: { $0.configuration?.indexPath == indexPath })
        
        if let dataSource = dataSource, !dataSource.contains(indexPath) {
            return nil
        }
        
        return result ?? (_internalDiffableDataSource?.collectionView(collectionView, cellForItemAt: indexPath) as? UICollectionViewCellType)
    }
    
    private func updateDataSource(oldValue: DataSource?, dataSource: DataSource?) {
        if configuration.disableAnimatingDifferences {
            _animateDataSourceDifferences = false
        }
        
        defer {
            _animateDataSourceDifferences = true
        }
        
        guard let _internalDataSource = _internalDiffableDataSource else {
            return
        }
        
        if case .diffableDataSource(let binding) = dataSource {
            DispatchQueue.main.async {
                if binding.wrappedValue !== _internalDataSource {
                    binding.wrappedValue = _internalDataSource
                }
            }
            
            return
        }
        
        guard oldValue != nil else {
            guard case let .static(data) = self.dataSource else {
                return
            }
            
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItems()
            snapshot.appendSections(data.map({ dataSourceConfiguration.identifierMap[$0.model] }))
            
            for element in data {
                snapshot.appendItems(element.items.map({ dataSourceConfiguration.identifierMap[$0] }), toSection: dataSourceConfiguration.identifierMap[element.model])
            }
            
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            
            return
        }
        
        guard case let (.static(data), .static(oldValue)) = (self.dataSource, oldValue) else {
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.deleteAllItems()
            
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
            
            return
        }
        
        let oldSections = oldValue.lazy.map({ $0.model })
        let sections = data.lazy.map({ $0.model })
        
        var snapshot = _internalDataSource.snapshot()
        
        let sectionDifference = sections.lazy.map({ self.dataSourceConfiguration.identifierMap[$0] }).difference(from: oldSections.lazy.map({ self.dataSourceConfiguration.identifierMap[$0] }))
        
        snapshot.loadSectionDifference(sectionDifference)
        
        var hasDataSourceChanged: Bool = false
        
        if !(sectionDifference.isEmpty) {
            hasDataSourceChanged = true
        }
        
        for sectionData in data {
            let section = sectionData.model
            let sectionItems = sectionData.items
            let oldSectionData = oldValue.first(where: { self.dataSourceConfiguration.identifierMap[$0.model] == self.dataSourceConfiguration.identifierMap[sectionData.model] })
            let oldSectionItems = oldSectionData?.items ?? AnyRandomAccessCollection([])
            
            let difference = sectionItems.lazy.map({ self.dataSourceConfiguration.identifierMap[$0] }).difference(from: oldSectionItems.lazy.map({ self.dataSourceConfiguration.identifierMap[$0] }))
            
            if !difference.isEmpty {
                snapshot.loadItemDifference(difference, inSection: self.dataSourceConfiguration.identifierMap[section])
                
                hasDataSourceChanged = true
            }
        }
        
        if hasDataSourceChanged {
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewController {
    class CellMetadataCache {
        unowned let parent: UIHostingCollectionViewController
        
        private var identifierBasedPreferenceValuesCache: [SectionIdentifierType: [ItemIdentifierType: UICollectionViewCellType.PreferenceValues]] = [:]
        private var identifierBasedContentSizeCache: [SectionIdentifierType: [ItemIdentifierType: CGSize]] = [:]
        
        private var indexPathBasedContentSizeCache: [IndexPath: CGSize] = [:]
        private var identifierToIndexPathMap: [SectionIdentifierType: [ItemIdentifierType: IndexPath]] = [:]
        private var indexPathToIdentifierMap: [IndexPath: (SectionIdentifierType, ItemIdentifierType)] = [:]
        private var itemIdentifierHashToIndexPathMap: [Int: IndexPath] = [:]
        
        private let prototypeCell = UICollectionViewCellType()
        
        init(parent: UIHostingCollectionViewController) {
            self.parent = parent
        }
        
        func firstIndexPath(for identifier: AnyHashable) -> IndexPath? {
            if let itemIdentifier = identifier as? ItemIdentifierType {
                return identifierToIndexPathMap.first(where: { $0.value[itemIdentifier] != nil })?.value[itemIdentifier]
            } else if let indexPath = itemIdentifierHashToIndexPathMap[identifier.hashValue] {
                return indexPath
            } else {
                return nil
            }
        }
        
        subscript(
            section sectionIdentifier: SectionIdentifierType,
            item itemIdentifier: ItemIdentifierType
        ) -> UICollectionViewCellType.PreferenceValues? {
            get {
                identifierBasedPreferenceValuesCache[sectionIdentifier, default: [:]][itemIdentifier]
            } set {
                identifierBasedPreferenceValuesCache[sectionIdentifier, default: [:]][itemIdentifier] = newValue
            }
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            guard let dataSource = parent.dataSource, dataSource.contains(indexPath) else {
                return .init(width: 1.0, height: 1.0)
            }
            
            let section = parent._unsafelyUnwrappedSection(from: indexPath)
            let sectionIdentifier = parent.dataSourceConfiguration.identifierMap[section]
            let item = parent._unsafelyUnwrappedItem(at: indexPath)
            let itemID = parent.dataSourceConfiguration.identifierMap[item]
            
            let indexPathBasedSize = indexPathBasedContentSizeCache[indexPath]
            let identifierBasedSize = identifierBasedContentSizeCache[sectionIdentifier, default: [:]][itemID]
            
            if let size = identifierBasedSize, indexPathBasedSize == nil {
                indexPathBasedContentSizeCache[indexPath] = size
                return size
            } else if let size = indexPathBasedSize, size == identifierBasedSize {
                return size
            } else {
                invalidateCachedContentSize(forIndexPath: indexPath)
                
                return sizeForItem(
                    atIndexPath: indexPath,
                    withCellConfiguration: .init(
                        item: item,
                        itemIdentifier: itemID,
                        sectionIdentifier: sectionIdentifier,
                        indexPath: indexPath,
                        makeContent: parent.viewProvider.rowContent,
                        maximumSize: parent.maximumCellSize
                    )
                )
            }
        }
        
        private func sizeForItem(
            atIndexPath indexPath: IndexPath,
            withCellConfiguration cellConfiguration: UICollectionViewCellType.Configuration
        ) -> CGSize {
            prototypeCell.configuration = cellConfiguration
            
            prototypeCell.cellWillDisplay(inParent: nil, isPrototype: true)
            
            let size = prototypeCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if !(size.width == 1 && size.height == 1) {
                identifierBasedContentSizeCache[cellConfiguration.sectionIdentifier, default: [:]][cellConfiguration.itemIdentifier] = size
                
                indexPathBasedContentSizeCache[cellConfiguration.indexPath] = size
                indexPathToIdentifierMap[cellConfiguration.indexPath] = (cellConfiguration.sectionIdentifier, cellConfiguration.itemIdentifier)
                identifierToIndexPathMap[cellConfiguration.sectionIdentifier, default: [:]][cellConfiguration.itemIdentifier] = indexPath
                itemIdentifierHashToIndexPathMap[cellConfiguration.itemIdentifier.hashValue] = indexPath
            }
            
            return size
        }
        
        func invalidateCachedContentSize(forIndexPath indexPath: IndexPath) {
            guard let (sectionIdentifier, itemID) = indexPathToIdentifierMap[indexPath] else {
                return
            }
            
            identifierBasedContentSizeCache[sectionIdentifier, default: [:]][itemID] = nil
            indexPathBasedContentSizeCache[indexPath] = nil
        }
        
        func invalidateIndexPath(_ indexPath: IndexPath) {
            invalidateCachedContentSize(forIndexPath: indexPath)
            
            if let (sectionIdentifier, itemIdentifier) = indexPathToIdentifierMap[indexPath] {
                itemIdentifierHashToIndexPathMap[itemIdentifier.hashValue] = nil
                identifierToIndexPathMap[sectionIdentifier, default: [:]][itemIdentifier] = nil
                indexPathToIdentifierMap[indexPath] = nil
            }
        }
        
        func invalidate() {
            identifierBasedContentSizeCache = [:]
            indexPathBasedContentSizeCache = [:]
            identifierToIndexPathMap = [:]
            indexPathToIdentifierMap = [:]
        }
    }
}

fileprivate extension Dictionary where Key == Int, Value == [Int: CGSize] {
    subscript(_ indexPath: IndexPath) -> CGSize? {
        get {
            self[indexPath.section, default: [:]][indexPath.row]
        } set {
            self[indexPath.section, default: [:]][indexPath.row] = newValue
        }
    }
}

fileprivate extension CollectionDifference where ChangeElement: Equatable {
    var singleItemReorder: (source: Int, target: Int)? {
        guard count == 2 else {
            return nil
        }
        
        guard case .remove(let sourceOffset, let removedElement, _) = first(where: {
            if case .remove = $0 {
                return true
            } else {
                return false
            }
        }) else {
            return nil
        }
        
        guard case .insert(var targetOffset, let insertedElement, _) = first(where: {
            if case .insert = $0 {
                return true
            } else {
                return false
            }
        }) else {
            return nil
        }
        
        guard insertedElement == removedElement else {
            return nil
        }
        
        if sourceOffset < targetOffset {
            targetOffset += 1
        }
        
        return (sourceOffset, targetOffset)
    }
}

fileprivate extension NSDiffableDataSourceSnapshot {
    mutating func loadSectionDifference(_ difference: CollectionDifference<SectionIdentifierType>) {
        difference.forEach({ loadSectionChanges($0) })
    }
    
    mutating func loadSectionChanges(_ change: CollectionDifference<SectionIdentifierType>.Change) {
        switch change {
            case .insert(offset: sectionIdentifiers.count, let element, _):
                appendSections([element])
            case .insert(let offset, let element, _):
                insertSections([element], beforeSection: sectionIdentifiers[offset])
            case .remove(_, let element, _):
                deleteSections([element])
        }
    }
    
    mutating func loadItemDifference(
        _ difference: CollectionDifference<ItemIdentifierType>, inSection section: SectionIdentifierType
    ) {
        difference.forEach({ loadItemChanges($0, inSection: section) })
    }
    
    mutating func loadItemChanges(_ change: CollectionDifference<ItemIdentifierType>.Change, inSection section: SectionIdentifierType) {
        switch change {
            case .insert(itemIdentifiers(inSection: section).count, let element, _):
                appendItems([element], toSection: section)
            case .insert(let offset, let element, _):
                insertItems([element], beforeItem: itemIdentifiers(inSection: section)[offset])
            case .remove(_, let element, _):
                deleteItems([element])
        }
    }
}

extension UICollectionView.ScrollPosition {
    init(_ unitPoint: UnitPoint?) {
        switch (unitPoint ?? .zero) {
            case .zero:
                self = [.left, .top]
            case .center:
                self = [.centeredHorizontally, .centeredVertically]
            case .leading:
                self = [.left, .centeredVertically]
            case .trailing:
                self = [.right, .centeredVertically]
            case .top:
                self = [.top, .centeredVertically]
            case .bottom:
                self = [.bottom, .centeredVertically]
            case .topLeading:
                self = [.left, .top]
            case .topTrailing:
                self = [.right, .top]
            case .bottomLeading:
                self = [.right, .bottom]
            case .bottomTrailing:
                self = [.right, .bottom]
            default:
                assertionFailure()
                self = []
        }
    }
}

#endif
