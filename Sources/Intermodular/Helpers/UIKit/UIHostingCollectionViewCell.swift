//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingCollectionViewCell<Item: Identifiable, Content: View> : UICollectionViewCell {
    var collectionViewController: UICollectionViewController!
    var indexPath: IndexPath?
    
    var item: Item!
    var makeContent: ((Item) -> Content)!
    
    private var contentHostingController: UIHostingController<RootView>!
    private var isContentSizeCached = false
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !isContentSizeCached {
            contentHostingController?.view.setNeedsLayout()
            contentHostingController?.view.layoutIfNeeded()
            
            layoutAttributes.frame.size = contentHostingController.sizeThatFits(in: layoutAttributes.size)
            
            isContentSizeCached = true
        }
        
        return layoutAttributes
    }
    
    override public func prepareForReuse() {
        isContentSizeCached = false
        
        super.prepareForReuse()
    }
    
    public func reload() {
        guard let indexPath = indexPath else {
            return
        }
        
        collectionViewController.collectionView.reloadItems(at: [indexPath])
    }
}

extension UIHostingCollectionViewCell {
    func update() {
        if contentHostingController == nil {
            backgroundColor = .clear
            backgroundView = .init()
            contentView.backgroundColor = .clear
            contentView.bounds.origin = .zero
            layoutMargins = .zero
            selectedBackgroundView = .init()
            
            contentHostingController = UIHostingController(rootView: RootView(uiCollectionViewCell: self))
            contentHostingController.view.backgroundColor = .clear
            contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            contentHostingController.willMove(toParent: collectionViewController)
            collectionViewController.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: collectionViewController)
            
            NSLayoutConstraint.activate([
                contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            contentHostingController.rootView = RootView(uiCollectionViewCell: self)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    private struct RootView: View {
        private struct _ListRowManager: ListRowManager {
            unowned let uiCollectionViewCell: UIHostingCollectionViewCell<Item, Content>
            
            func _animate(_ action: () -> ()) {
                /*uiCollectionViewCell.tableViewController.tableView.beginUpdates()
                 action()
                 uiCollectionViewCell.tableViewController.tableView.endUpdates()*/
            }
            
            func _reload() {
                uiCollectionViewCell.reload()
            }
        }
        
        unowned let uiCollectionViewCell: UIHostingCollectionViewCell<Item, Content>
        
        var body: some View {
            uiCollectionViewCell.makeContent(uiCollectionViewCell.item)
                .environment(\.listRowManager, _ListRowManager(uiCollectionViewCell: uiCollectionViewCell))
                .id(uiCollectionViewCell.item.id)
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
