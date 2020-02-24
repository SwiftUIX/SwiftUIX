//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class UIHostingTableViewHeaderFooterView<Content: View> : UITableViewHeaderFooterView {
    var contentHostingController: UIHostingController<Content>?
    
    var content: Content? {
        get {
            contentHostingController?.rootView
        } set {
            guard let content = newValue else {
                return
            }
            
            if let contentHostingController = contentHostingController {
                contentHostingController.rootView = content
            } else {
                contentHostingController = UIHostingController(rootView: content)
                
                let view = contentHostingController!.view!

                view.backgroundColor = .clear
                view.translatesAutoresizingMaskIntoConstraints = false

                contentView.addSubview(view)

                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
                
                contentView.backgroundColor = .clear
            }
        }
    }
            
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.constraints.forEach(contentView.removeConstraint)
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        contentHostingController = nil
    }
}

extension String {
    static let hostingTableViewHeaderViewIdentifier = "UIHostingTableViewHeaderView"
    static let hostingTableViewFooterViewIdentifier = "UIHostingTableViewFooterView"
}

#endif
