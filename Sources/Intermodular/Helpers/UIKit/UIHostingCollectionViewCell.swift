//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingCollectionViewCell<Item: Identifiable, Content: View> : UICollectionViewCell {
    var item: Item!
    var makeContent: ((Item) -> Content)!
    var useAutoLayout = true
    
    private var contentHostingController: AppKitOrUIKitHostingControllerProtocol!
    private var isContentSizeCached = false
    
    private var rootView: some View {
        self.makeContent(item).id(item.id)
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
        
        super.prepareForReuse()
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
            
            contentHostingController = UIHostingController(rootView: rootView)
            contentHostingController.view.backgroundColor = .clear
            
            if useAutoLayout {
                contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            contentView.addSubview(contentHostingController.view)
            
            if useAutoLayout {
                NSLayoutConstraint.activate([
                    contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            }
        } else {
            (contentHostingController as? UIHostingController)?.rootView = rootView
        }
        
        if !useAutoLayout {
            contentHostingController.view.frame.size.width = bounds.width // FIXME!
            contentHostingController.view.frame.size.height = contentHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
