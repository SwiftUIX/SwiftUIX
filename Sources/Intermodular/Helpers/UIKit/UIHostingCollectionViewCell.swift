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
    var cellPreferences = _CollectionOrListCellPreferences()
    var contentHostingController: CellContentHostingControllerType?
    var maximumSize: OptionalDimensions?
    
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
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        indexPath = nil
        itemID = nil
        cellPreferences = .init()
        
        isSelected = false
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentHostingController?.systemLayoutSizeFitting(targetSize) ?? CGSize(width: 1, height: 1)
    }
    
    override public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        return contentHostingController?.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        ) ?? CGSize(width: 1, height: 1)
    }
    
    override public func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
        
        return layoutAttributes
    }
    
    override public func setNeedsUpdateConfiguration() {
        contentHostingController?.update()
    }
}

extension UIHostingCollectionViewCell {
    func cellWillDisplay(isPrototype: Bool = false) {
        if let contentHostingController = contentHostingController {
            contentHostingController.update()
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

final class UICollectionViewCellContentHostingController<ItemType, ItemIdentifierType: Hashable, Content: View>: CocoaHostingController<UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>.RootView> {
    typealias UIHostingCollectionViewCellType = UIHostingCollectionViewCell<ItemType, ItemIdentifierType, Content>
    
    weak var base: UIHostingCollectionViewCellType?
    
    init(base: UIHostingCollectionViewCellType?) {
        self.base = base
        
        super.init(mainView: nil)
        
        update()
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize
    ) -> CGSize {
        _fixed_sizeThatFits(
            in: .init(targetSize),
            maximumSize: base?.maximumSize ?? nil
        )
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        _fixed_sizeThatFits(
            in: .init(targetSize),
            maximumSize: base?.maximumSize ?? nil
        )
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
    
    func update() {
        rootView.content = .init(base: base)
        
        view.setNeedsDisplay()
    }
}

extension UIHostingCollectionViewCell {
    public struct RootView: ExpressibleByNilLiteral, View {
        var item: ItemType?
        var itemID: ItemIdentifierType?
        var cellPreferences: Binding<_CollectionOrListCellPreferences>?
        var makeContent: ((ItemType) -> Content)?
        
        public init(nilLiteral: ()) {
            
        }
        
        init(base: UIHostingCollectionViewCell?) {
            if let base = base {
                self.item = base.item
                self.itemID = base.itemID
                self.cellPreferences = .init(get: { [weak base] in base?.cellPreferences ?? .init() }, set: { [weak base] in base?.cellPreferences = $0 })
                self.makeContent = base.makeContent
            }
        }
        
        public var body: some View {
            if let item = item, let itemID = itemID, let cellPreferences = cellPreferences, let makeContent = makeContent {
                makeContent(item)
                    .edgesIgnoringSafeArea(.all)
                    .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self, perform: { cellPreferences.wrappedValue = $0 })
                    .id(itemID)
            }
        }
    }
}

#endif
