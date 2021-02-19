//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingCollectionViewController {
    typealias _SwiftUIType = _CollectionView<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeader, SectionFooter, RowContent>
    typealias UICollectionViewCellType = UIHostingCollectionViewCell<ItemType, ItemIdentifierType, RowContent>
    
    public enum DataSource {
        public struct IdentifierMap {
            var getSectionID: (SectionType) -> SectionIdentifierType
            var getSectionFromID: (SectionIdentifierType) -> SectionType
            var getItemID: (ItemType) -> ItemIdentifierType
            var getItemFromID: (ItemIdentifierType) -> ItemType
            
            subscript(_ section: SectionType) -> SectionIdentifierType {
                getSectionID(section)
            }
            
            subscript(_ sectionID: SectionIdentifierType) -> SectionType {
                getSectionFromID(sectionID)
            }
            
            subscript(_ item: ItemType) -> ItemIdentifierType {
                getItemID(item)
            }
            
            subscript(_ itemID: ItemIdentifierType) -> ItemType {
                getItemFromID(itemID)
            }
        }
        
        case dynamic(Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>)
        case `static`(AnyRandomAccessCollection<ListSection<SectionType, ItemType>>)
    }
}

public final class UIHostingCollectionViewController<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    fileprivate lazy var _animateDataSourceDifferences: Bool = true
    fileprivate lazy var _internalDiffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>? = nil
    fileprivate lazy var cellContentSizeCache: CellContentSizeCache = .init(parent: self)
    
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
        
        let diffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: collectionView) { [weak self] collectionView, indexPath, sectionID in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            let item: ItemType = self._unsafelyUnwrappedItem(at: indexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .hostingCollectionViewCellIdentifier, for: indexPath) as! UICollectionViewCellType
            
            cell.parentViewController = self
            cell.indexPath = indexPath
            cell.item = item
            cell.itemID = self.dataSourceConfiguration.dataSourceIdentifierMap.getItemID(item)
            cell.makeContent = self.viewProvider.rowContent
            
            cell.cellWillDisplay()
            
            return cell
        }
        
        self._internalDiffableDataSource = diffableDataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewSafeAreaInsetsDidChange()  {
        super.viewSafeAreaInsetsDidChange()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDelegate -
    
    public func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        /*guard !(collectionView.collectionViewLayout is UICollectionViewFlowLayout) else {
         return proposedIndexPath
         }
         
         if originalIndexPath.section != proposedIndexPath.section {
         return originalIndexPath
         }
         
         if originalIndexPath.item == proposedIndexPath.item {
         return originalIndexPath
         }
         
         let cellContentSizeCache = self.cellContentSizeCache
         
         cellContentSizeCache.invalidateIndexPath(originalIndexPath)
         cellContentSizeCache.invalidateIndexPath(proposedIndexPath)*/
        
        return proposedIndexPath
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! UIHostingCollectionViewCell<ItemType, ItemIdentifierType, RowContent>).cellWillDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! UICollectionViewCellType).cellDidEndDisplaying()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        cell(for: indexPath)?.cellPreferences.isHighlightable ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isSelected = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isSelected = false
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    private let prototypeCell = UICollectionViewCellType()
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cellContentSizeCache.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension UIHostingCollectionViewController {
    class CellContentSizeCache {
        unowned let parent: UIHostingCollectionViewController
        
        private var identifierBasedCache: [SectionIdentifierType: [ItemIdentifierType: CGSize]] = [:]
        private var indexPathBasedCache: [Int: [Int: CGSize]] = [:]
        private var indexPathToIdentifierMap: [IndexPath: (SectionIdentifierType, ItemIdentifierType)] = [:]
        
        private let prototypeCell = UICollectionViewCellType()
        
        init(parent: UIHostingCollectionViewController) {
            self.parent = parent
        }
        
        func invalidateCachedSize(forIndexPath indexPath: IndexPath) {
            guard let (sectionID, itemID) = indexPathToIdentifierMap[indexPath] else {
                return
            }
            
            identifierBasedCache[sectionID, default: [:]][itemID] = nil
            indexPathBasedCache[indexPath] = nil
        }
        
        func invalidateIndexPath(_ indexPath: IndexPath) {
            invalidateCachedSize(forIndexPath: indexPath)
            
            indexPathToIdentifierMap[indexPath] = nil
        }
        
        private func sizeForItem(
            _ item: ItemType,
            withID itemID: ItemIdentifierType,
            inSection section: SectionType,
            withID sectionID: SectionIdentifierType,
            atIndexPath indexPath: IndexPath
        ) -> CGSize {
            prototypeCell.indexPath = indexPath
            prototypeCell.item = item
            prototypeCell.itemID = parent.dataSourceConfiguration.dataSourceIdentifierMap.getItemID(item)
            prototypeCell.makeContent = parent.viewProvider.rowContent
            prototypeCell.maximumSize = parent.maximumCellSize
            
            prototypeCell.cellWillDisplay(isPrototype: true)
            
            let size = prototypeCell
                .contentHostingController!
                .systemLayoutSizeFitting(
                    parent.maximumCellSize != nil
                        ? UIView.layoutFittingExpandedSize
                        : UIView.layoutFittingCompressedSize
                )
            
            identifierBasedCache[sectionID, default: [:]][itemID] = size
            indexPathBasedCache[indexPath] = size
            indexPathToIdentifierMap[indexPath] = (sectionID, itemID)
            
            return size
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            guard parent.dataSource != nil else {
                return .init(width: 1.0, height: 1.0)
            }
            
            let section = parent._unsafelyUnwrappedSection(from: indexPath)
            let sectionID = parent.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID(section)
            let item = parent._unsafelyUnwrappedItem(at: indexPath)
            let itemID = parent.dataSourceConfiguration.dataSourceIdentifierMap.getItemID(item)
            
            let indexPathBasedSize = indexPathBasedCache[indexPath]
            let identifierBasedSize = identifierBasedCache[sectionID, default: [:]][itemID]
            
            if let size = identifierBasedSize, indexPathBasedSize == nil {
                indexPathBasedCache[indexPath] = size
                
                return size
            } else if let size = indexPathBasedSize, size == identifierBasedSize {
                return size
            } else {
                invalidateCachedSize(forIndexPath: indexPath)
                
                return sizeForItem(
                    item, withID: itemID,
                    inSection: section,
                    withID: sectionID,
                    atIndexPath: indexPath
                )
            }
        }
    }
}

extension UIHostingCollectionViewController {
    private func _unsafelyUnwrappedSection(from indexPath: IndexPath) -> SectionType {
        if case .static(let data) = dataSource {
            return data[data.index(data.startIndex, offsetBy: indexPath.section)].model
        } else {
            return dataSourceConfiguration.dataSourceIdentifierMap.getSectionFromID(_internalDiffableDataSource!.snapshot().sectionIdentifiers[indexPath.section])
        }
    }
    
    private func _unsafelyUnwrappedItem(at indexPath: IndexPath) -> ItemType {
        if case .static(let data) = dataSource {
            return data[indexPath]
        } else {
            return dataSourceConfiguration.dataSourceIdentifierMap.getItemFromID(_internalDiffableDataSource!.itemIdentifier(for: indexPath)!)
        }
    }
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCellType? {
        let result = collectionView
            .visibleCells
            .compactMap({ $0 as? UICollectionViewCellType})
            .first(where: { $0.indexPath == indexPath })
        
        return result ?? _internalDiffableDataSource?.collectionView(collectionView, cellForItemAt: indexPath) as! UICollectionViewCellType
    }
}

extension UIHostingCollectionViewController {
    private func updateDataSource(oldValue: DataSource?, dataSource: DataSource?) {
        defer {
            _animateDataSourceDifferences = true
        }
        
        guard let _internalDataSource = _internalDiffableDataSource else {
            return
        }
        
        if case .dynamic(let binding) = dataSource {
            DispatchQueue.main.async {
                if binding.wrappedValue !== _internalDataSource {
                    binding.wrappedValue = _internalDataSource
                }
            }
        }
        
        guard oldValue != nil else {
            guard case let .static(data) = self.dataSource else {
                return
            }
            
            var snapshot = _internalDataSource.snapshot()
            
            snapshot.appendSections(data.map({ dataSourceConfiguration.dataSourceIdentifierMap.getSectionID($0.model) }))
            
            for element in data {
                snapshot.appendItems(element.data.map({ dataSourceConfiguration.dataSourceIdentifierMap.getItemID($0) }), toSection: dataSourceConfiguration.dataSourceIdentifierMap.getSectionID(element.model))
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
        
        let sectionDifference = sections.lazy.map({ self.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID($0) }).difference(from: oldSections.lazy.map({ self.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID($0) }))
        
        snapshot.loadSectionDifference(sectionDifference)
        
        var dataSourceHasChanged = !sectionDifference.isEmpty
        
        for sectionData in data {
            let section = sectionData.model
            let sectionItems = sectionData.data
            let oldSectionData = oldValue.first(where: { self.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID($0.model) == self.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID(sectionData.model) })
            let oldSectionItems = oldSectionData?.data ?? AnyRandomAccessCollection([])
            
            let difference = sectionItems.lazy.map({ self.dataSourceConfiguration.dataSourceIdentifierMap.getItemID($0) }).difference(from: oldSectionItems.lazy.map({ self.dataSourceConfiguration.dataSourceIdentifierMap.getItemID($0) }))
            
            if !difference.isEmpty {
                snapshot.loadItemDifference(difference, inSection: self.dataSourceConfiguration.dataSourceIdentifierMap.getSectionID(section))
                
                dataSourceHasChanged = true
            }
        }
        
        if dataSourceHasChanged {
            _internalDataSource.apply(snapshot, animatingDifferences: _animateDataSourceDifferences)
        }
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
                    parent.cellContentSizeCache.invalidateCachedSize(forIndexPath: sourceIndexPath)
                    parent.cellContentSizeCache.invalidateCachedSize(forIndexPath: destinationIndexPath)
                    
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

// MARK: - Auxiliary Implementation -

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
    
    mutating func loadItemDifference(_ difference: CollectionDifference<ItemIdentifierType>, inSection section: SectionIdentifierType) {
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

fileprivate extension Dictionary where Key == Int, Value == [Int: CGSize] {
    subscript(_ indexPath: IndexPath) -> CGSize? {
        get {
            self[indexPath.section, default: [:]][indexPath.row]
        } set {
            self[indexPath.section, default: [:]][indexPath.row] = newValue
        }
    }
}

#endif
