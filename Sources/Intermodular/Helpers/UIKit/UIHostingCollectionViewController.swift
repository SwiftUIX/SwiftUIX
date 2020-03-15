//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public final class UIHostingCollectionViewController<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UICollectionViewController where Data.Element == ListSection<SectionModel, Item> {
    private var _isDataDirty: Bool
    
    var data: Data {
        didSet {
            if !data.isIdentical(to: oldValue) {
                _isDataDirty = true
            }
        }
    }
    
    var sectionHeader: (SectionModel) -> SectionHeader
    var sectionFooter: (SectionModel) -> SectionFooter
    var rowContent: (Item) -> RowContent
    
    private var _rowContentHeightCache: [Item.ID: CGFloat] = [:]
    private var _prototypeCell: UIHostingTableViewCell<Item, RowContent>?
    
    public init(
        _ data: Data,
        collectionViewLayout: UICollectionViewLayout,
        sectionHeader: @escaping (SectionModel) -> SectionHeader,
        sectionFooter: @escaping (SectionModel) -> SectionFooter,
        rowContent: @escaping (Item) -> RowContent
    ) {
        self._isDataDirty = true
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = rowContent
        
        super.init(collectionViewLayout: collectionViewLayout)
        
        
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.backgroundColor = .clear
        
        collectionView.register(UIHostingCollectionViewCell<Item, RowContent>.self, forCellWithReuseIdentifier: .hostingCollectionViewCellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[data.index(data.startIndex, offsetBy: section)].items.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .hostingCollectionViewCellIdentifier, for: indexPath) as! UIHostingCollectionViewCell<Item, RowContent>
        
        cell.collectionViewController = self
        cell.indexPath = indexPath
        cell.item = data[indexPath]
        cell.makeContent = rowContent
        
        cell.update()
        
        return cell
    }
    
    public func reloadData() {
        if _isDataDirty {
            collectionView.reloadData()
            
            _isDataDirty = false
        }
    }
}

#endif
