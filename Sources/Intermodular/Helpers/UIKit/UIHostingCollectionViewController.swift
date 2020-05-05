//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public final class UIHostingCollectionViewController<SectionModel: Identifiable, Item: Identifiable, Data: RandomAccessCollection, SectionHeader: View, SectionFooter: View, RowContent: View>: UICollectionViewController, UICollectionViewDelegateFlowLayout where Data.Element == ListSection<SectionModel, Item> {
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
    
    // MARK: - UICollectionViewDataSource -
    
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
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }
    
    // MARK: - UICollectionViewDelegate -
    
    override public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cell(for: indexPath)?.update()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        cell(for: indexPath)?.listRowPreferences?.isHighlightable ?? false
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = true
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.isHighlighted = false
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.listRowPreferences?.onSelect?.perform()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cell(for: indexPath)?.listRowPreferences?.onDeselect?.perform()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    /*public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let result = UIHostingController(rootView: rowContent(data[indexPath])).sizeThatFits(in: UIView.layoutFittingCompressedSize)
        
        if result == .zero {
            return .init(width: 1, height: 1)
        }
        
        return result
    }*/
}

extension UIHostingCollectionViewController {
    public func cell(for indexPath: IndexPath) -> UIHostingCollectionViewCell<Item, RowContent>? {
        collectionView.visibleCells.compactMap({ $0 as? UIHostingCollectionViewCell<Item, RowContent> }).first(where: { $0.indexPath == indexPath }) ?? collectionView.dequeueReusableCell(withReuseIdentifier: .hostingCollectionViewCellIdentifier, for: indexPath) as! UIHostingCollectionViewCell<Item, RowContent>
    }
    
    public func reloadData() {
        if _isDataDirty {
            collectionView.reloadData()
            
            _isDataDirty = false
        }
    }
}

#endif
