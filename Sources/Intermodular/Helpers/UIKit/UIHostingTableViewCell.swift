//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewCell<Content: View> : UITableViewCell {
    var contentHostingController: UIHostingController<Content>?
    
    var content: Content! {
        get {
            contentHostingController?.rootView
        } set {
            let _contentView: UIView
            
            if let contentHostingController = contentHostingController {
                contentHostingController.rootView = newValue
                
                _contentView = contentHostingController.view
            } else {
                contentHostingController = UIHostingController(rootView: newValue)
                
                _contentView = contentHostingController!.view!
                
                _contentView.backgroundColor = .clear
                _contentView.translatesAutoresizingMaskIntoConstraints = false
                
                contentView.addSubview(_contentView)
                
                NSLayoutConstraint.activate([
                    _contentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    _contentView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    _contentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    _contentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            }
            
            backgroundColor = .clear
            backgroundView = .init()
            contentView.backgroundColor = .clear
            contentView.bounds.origin = .zero
            layoutMargins = .zero
            selectedBackgroundView = .init()
            
            _contentView.setNeedsLayout()
            _contentView.layoutIfNeeded()
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    static let hostingTableViewCellIdentifier = "UIHostingTableViewCell"
}

#endif
