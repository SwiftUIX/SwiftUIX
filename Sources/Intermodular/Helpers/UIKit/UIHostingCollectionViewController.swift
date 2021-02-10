//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public final class UIHostingCollectionViewController<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeader: View,
    SectionFooter: View,
    RowContent: View
>: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public typealias UICollectionViewCellType = UIHostingCollectionViewCell<ItemType, ItemIdentifierType, RowContent>
    
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
    
    fileprivate private(set) var _internalDiffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?
    
    var dataSource: DataSource? = nil {
        didSet {
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
                
                snapshot.appendSections(data.map({ dataSourceIdentifierMap.getSectionID($0.model) }))
                
                for element in data {
                    snapshot.appendItems(element.data.map({ dataSourceIdentifierMap.getItemID($0) }), toSection: dataSourceIdentifierMap.getSectionID(element.model))
                }
                
                _internalDataSource.apply(snapshot, animatingDifferences: true)
                
                return
            }
            
            guard case let (.static(data), .static(oldValue)) = (self.dataSource, oldValue) else {
                var snapshot = _internalDataSource.snapshot()
                
                snapshot.deleteAllItems()
                
                _internalDataSource.apply(snapshot, animatingDifferences: true)
                
                return
            }
            
            let oldSections = oldValue.lazy.map({ $0.model })
            let sections = data.lazy.map({ $0.model })
            
            var snapshot = _internalDataSource.snapshot()
            
            let sectionDifference = sections.lazy.map({ self.dataSourceIdentifierMap.getSectionID($0) }).difference(from: oldSections.lazy.map({ self.dataSourceIdentifierMap.getSectionID($0) }))
            
            snapshot.loadSectionDifference(sectionDifference)
            
            for sectionData in data {
                let section = sectionData.model
                let sectionItems = sectionData.data
                let oldSectionData = oldValue.first(where: { self.dataSourceIdentifierMap.getSectionID($0.model) == self.dataSourceIdentifierMap.getSectionID(sectionData.model) })
                let oldSectionItems = oldSectionData?.data ?? AnyRandomAccessCollection([])
                
                snapshot.loadItemDifference(sectionItems.lazy.map({ self.dataSourceIdentifierMap.getItemID($0) }).difference(from: oldSectionItems.lazy.map({ self.dataSourceIdentifierMap.getItemID($0) })), inSection: self.dataSourceIdentifierMap.getSectionID(section))
            }
            
            _internalDataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    let dataSourceIdentifierMap: DataSource.IdentifierMap
    var sectionHeader: (SectionType) -> SectionHeader
    var sectionFooter: (SectionType) -> SectionFooter
    var rowContent: (ItemType) -> RowContent
    
    var collectionViewLayout: UICollectionViewLayout = UICollectionViewLayout() {
        didSet {
            collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        }
    }
    
    private var _rowContentSizeCache: [ItemIdentifierType: CGSize] = [:]
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        return collectionView
    }()
    
    public init(
        dataSource: Binding<UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>?>,
        dataSourceIdentifierMap: DataSource.IdentifierMap,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) {
        self.dataSource = .dynamic(dataSource)
        self.dataSourceIdentifierMap = dataSourceIdentifierMap
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(
        dataSourceIdentifierMap: DataSource.IdentifierMap,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (ItemType) -> RowContent
    ) {
        self.dataSourceIdentifierMap = dataSourceIdentifierMap
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
        
        super.init(nibName: nil, bundle: nil)
    }
    
    func _unsafelyUnwrappedItem(at indexPath: IndexPath) -> ItemType {
        if case .static(let data) = dataSource {
            return data[indexPath]
        } else {
            return dataSourceIdentifierMap.getItemFromID(_internalDiffableDataSource!.itemIdentifier(for: indexPath)!)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.backgroundColor = .clear
        
        collectionView.register(UICollectionViewCellType.self, forCellWithReuseIdentifier: .hostingCollectionViewCellIdentifier)
        
        _internalDiffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: collectionView) { [weak self] collectionView, indexPath, sectionID in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            let item: ItemType = self._unsafelyUnwrappedItem(at: indexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .hostingCollectionViewCellIdentifier, for: indexPath) as! UICollectionViewCellType
            
            cell.parentViewController = self
            cell.indexPath = indexPath
            cell.item = item
            cell.itemID = self.dataSourceIdentifierMap.getItemID(item)
            cell.makeContent = self.rowContent
            
            cell.willDisplay()
            
            return cell
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewSafeAreaInsetsDidChange()  {
        super.viewSafeAreaInsetsDidChange()
        
        collectionViewLayout.invalidateLayout() // WORKAROUND (for rotation animation)
    }
    
    // MARK: - UICollectionViewDelegate -
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! UIHostingCollectionViewCell<ItemType, ItemIdentifierType, RowContent>).willDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! UICollectionViewCellType).didEndDisplaying()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        cell(for: indexPath)?.listRowPreferences?.isHighlightable ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.listRowPreferences?.onSelect?.perform()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.listRowPreferences?.onDeselect?.perform()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard dataSource != nil else {
            return .zero
        }
        
        let item = _unsafelyUnwrappedItem(at: indexPath)
        
        if let size = _rowContentSizeCache[dataSourceIdentifierMap.getItemID(item)] {
            return size
        } else {
            let size = UIHostingController(rootView: rowContent(item)).sizeThatFits(in: UIView.layoutFittingExpandedSize)
            
            _rowContentSizeCache[dataSourceIdentifierMap.getItemID(item)] = size
            
            return size
        }
    }
}

extension UIHostingCollectionViewController {
    public func cell(for indexPath: IndexPath) -> UICollectionViewCellType? {
        let result = collectionView
            .visibleCells
            .compactMap({ $0 as? UICollectionViewCellType})
            .first(where: { $0.indexPath == indexPath })
        
        return result ?? _internalDiffableDataSource?.collectionView(collectionView, cellForItemAt: indexPath) as! UICollectionViewCellType
    }
}

#endif

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
    
    mutating func append(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) {
        appendSections(snapshot.sectionIdentifiers)
        
        for section in snapshot.sectionIdentifiers {
            appendItems(snapshot.itemIdentifiers(inSection: section), toSection: section)
        }
    }
    
    mutating func append(_ snapshots: [NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>]) {
        for snapshot in snapshots {
            append(snapshot)
        }
    }
    
    mutating func reloadValidItems(_ changedObjects: [ItemIdentifierType]) {
        reloadItems(changedObjects.filter { self.itemIdentifiers.contains($0) })
    }
}
