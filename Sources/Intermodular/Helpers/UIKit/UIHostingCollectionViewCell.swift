//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol _opaque_UIHostingCollectionViewCell {
    
}

public class UIHostingCollectionViewCell<ItemType, ItemIdentifierType: Hashable, Content: View>: UICollectionViewCell, _opaque_UIHostingCollectionViewCell {
    typealias CellContentHostingControllerType = UICollectionViewCellContentHostingController<ItemType, ItemIdentifierType, Content>
    
    struct State {
        var isHighlighted: Bool
        var isSelected: Bool
    }
    
    struct Configuration {
        private struct ID: Hashable {
            let item: ItemIdentifierType
            let section: AnyHashable
        }
        
        let item: ItemType
        let itemIdentifier: ItemIdentifierType
        let sectionIdentifier: AnyHashable
        let indexPath: IndexPath
        let makeContent: (ItemType) -> Content
        let maximumSize: OptionalDimensions?
        
        var id: some Hashable {
            ID(item: itemIdentifier, section: sectionIdentifier)
        }
    }
    
    var configuration: Configuration?
    var cellPreferences = _CollectionOrListCellPreferences()
    
    private var contentHostingController: CellContentHostingControllerType?
    
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
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .required
        )
    }
    
    override public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        contentHostingController?.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        ) ?? CGSize(width: 1, height: 1)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        isHighlighted = false
        isSelected = false
    }
    
    override public func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
        
        return layoutAttributes
    }
}

extension UIHostingCollectionViewCell {
    func cellWillDisplay(inParent parentViewController: UIViewController?, isPrototype: Bool = false) {
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
            maximumSize: base?.configuration?.maximumSize ?? nil
        )
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        _fixed_sizeThatFits(
            in: .init(targetSize),
            maximumSize: base?.configuration?.maximumSize ?? nil
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
        var configuration: Configuration?
        var cellPreferences: Binding<_CollectionOrListCellPreferences>?
        
        init(base: UIHostingCollectionViewCell?) {
            configuration = base?.configuration
            cellPreferences = .init(get: { [weak base] in base?.cellPreferences ?? .init() }, set: { [weak base] in base?.cellPreferences = $0 })
        }
        
        public init(nilLiteral: ()) {
            
        }
        
        public var body: some View {
            if let configuration = configuration {
                configuration
                    .makeContent(configuration.item)
                    .edgesIgnoringSafeArea(.all)
                    .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self, perform: { cellPreferences?.wrappedValue = $0 })
                    .id(configuration.id)
            }
        }
    }
}

#endif
