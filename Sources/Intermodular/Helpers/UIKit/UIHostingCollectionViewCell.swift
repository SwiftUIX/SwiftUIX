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
    
    var listRowPreferences: _ListRowPreferences?
    
    override public var isHighlighted: Bool {
        didSet {
            contentHostingController.rootView.manager.isHighlighted = isHighlighted
        }
    }
    
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
        listRowPreferences = nil
        
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
            
            contentHostingController = UIHostingController(rootView: RootView(base: self))
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
            contentHostingController.rootView = RootView(base: self)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    private struct RootView: View {
        struct _ListRowManager: ListRowManager {
            weak var base: UIHostingCollectionViewCell<Item, Content>?
            
            var isHighlighted: Bool = false

            func _animate(_ action: () -> ()) {
                // FIXME!!!
            }
            
            func _reload() {
                base?.reload()
            }
        }
        
        var manager: _ListRowManager
        
        init(base: UIHostingCollectionViewCell<Item, Content>?) {
            self.manager = .init(base: base)
        }
        
        var body: some View {
            manager.base.ifSome { base in
                base
                    .makeContent(base.item)
                    .environment(\.listRowManager, manager)
                    .onPreferenceChange(_ListRowPreferencesKey.self, perform: { base.listRowPreferences = $0 })
                    .id(base.item.id)
            }
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
