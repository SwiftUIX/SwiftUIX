//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct UICollectionViewCellRootView<Item: Identifiable, Content: View>: View {
    struct _ListRowManager: ListRowManager {
        weak var base: UIHostingCollectionViewCell<Item, Content>?
        
        var isHighlighted: Bool = false
        
        func _animate(_ action: () -> ()) {
            base?.collectionViewController.collectionViewLayout.invalidateLayout()
        }
        
        func _reload() {
            base?.reload()
        }
    }
    
    var manager: _ListRowManager
    
    init(base: UIHostingCollectionViewCell<Item, Content>?) {
        self.manager = .init(base: base)
    }
    
    public var body: some View {
        manager.base.ifSome { base in
            base
                .makeContent(base.item)
                .environment(\.listRowManager, manager)
                .onPreferenceChange(_ListRowPreferencesKey.self, perform: { base.listRowPreferences = $0 })
                .id(base.item.id)
        }
    }
}

open class UICollectionViewCellContentHostingController<Item: Identifiable, Content: View>: UIHostingController<UICollectionViewCellRootView<Item, Content>> {
    unowned let base: UIHostingCollectionViewCell<Item, Content>
    
    init(base: UIHostingCollectionViewCell<Item, Content>) {
        self.base = base
        
        super.init(rootView: .init(base: base))
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let indexPath = base.indexPath {
            if let cell = base.collectionViewController.collectionView.cellForItem(at: indexPath), cell.frame.size != sizeThatFits(in: .greatestFiniteSize) {
                base.collectionViewController.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class UIHostingCollectionViewCell<Item: Identifiable, Content: View> : UICollectionViewCell {
    var collectionViewController: (UICollectionViewController & UICollectionViewDelegateFlowLayout)!
    var indexPath: IndexPath?
    
    var item: Item!
    var makeContent: ((Item) -> Content)!
    
    private var contentHostingController: UICollectionViewCellContentHostingController<Item, Content>!
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
            
            if layoutAttributes.frame.size == .zero {
                layoutAttributes.frame.size = .init(width: 1, height: 1)
            } else {
                isContentSizeCached = true
            }
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
            
            contentHostingController = .init(base: self)
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
            contentHostingController.rootView = .init(base: self)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
