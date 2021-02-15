//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingCollectionViewCell<ItemType, ItemIdentifierType: Hashable, Content: View>: UICollectionViewCell {
    typealias CellContentHostingControllerType = UICollectionViewCellContentHostingController<ItemType, ItemIdentifierType, Content>
    
    var parentViewController: UIViewController?
    var indexPath: IndexPath?
    var item: ItemType?
    var itemID: ItemIdentifierType?
    var makeContent: ((ItemType) -> Content)!
    var listRowPreferences: _ListRowPreferences?
    
    var contentHostingController: CellContentHostingControllerType?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        backgroundView = .init()
        contentView.backgroundColor = .clear
        contentView.bounds.origin = .zero
        layoutMargins = .zero
        selectedBackgroundView = .init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame != contentView.bounds {
                contentHostingController.view.frame = contentView.bounds
                contentHostingController.view.setNeedsLayout()
            }
            
            contentHostingController.view.layoutIfNeeded()
        }
    }
    
    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
        
        return layoutAttributes
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        indexPath = nil
        itemID = nil
        listRowPreferences = nil
        
        isSelected = false
    }
    
    override public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        guard let contentHostingController = contentHostingController else  {
            return CGSize(width: 1, height: 1)
        }
        
        return contentHostingController.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    func cellWillDisplay(isPrototype: Bool = false) {
        if let contentHostingController = contentHostingController {
            contentHostingController.rootView.itemID = itemID
        } else {
            contentHostingController = UICollectionViewCellContentHostingController(base: self)
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController?.parent == nil {
                contentHostingController?.move(toParent: parentViewController, ofCell: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func cellDidEndDisplaying() {
        contentHostingController?.move(toParent: nil, ofCell: self)
    }
}

// MARK: - Auxiliary Implementation -

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

final class UICollectionViewCellContentHostingController<ItemType, ItemIdentifierType: Hashable, Content: View>: UIHostingController<UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>.RootView> {
    weak var base: UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>?
    
    init(base: UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>?) {
        self.base = base
        
        super.init(rootView: .init(base: base))
        
        view.backgroundColor = .clear
        view.insetsLayoutMarginsFromSafeArea = false
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.backgroundColor = .clear
        view.insetsLayoutMarginsFromSafeArea = false
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        return _fixed_sizeThatFits(in: targetSize)
    }
    
    func move(toParent parent: UIViewController?, ofCell cell: UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>) {
        if let parent = parent {
            if let existingParent = self.parent, existingParent !== parent {
                move(toParent: nil, ofCell: cell)
            }
            
            if self.parent == nil {
                self.willMove(toParent: parent)
                parent.addChild(self)
                cell.contentView.addSubview(view)
                view.frame = cell.contentView.bounds
                didMove(toParent: parent)
            } else {
                assertionFailure()
            }
        } else {
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
        }
    }
}

extension UIHostingCollectionViewCell {
    public struct RootView: View {
        weak var base: UIHostingCollectionViewCell?
        
        var itemID: ItemIdentifierType?
        
        init(base: UIHostingCollectionViewCell?) {
            self.base = base
        }
        
        public var body: some View {
            if let base = self.base, let item = base.item {
                base.makeContent(item)
                    .edgesIgnoringSafeArea(.all)
                    .onPreferenceChange(_ListRowPreferencesKey.self, perform: { base.listRowPreferences = $0 })
            }
        }
    }
}

#endif
