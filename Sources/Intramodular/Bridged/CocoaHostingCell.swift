//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaHostingCell<Content: View> : UITableViewCell {
    var rowContentHostingController: UIHostingController<Content>?
    
    var rowContent: Content? {
        get {
            rowContentHostingController?.rootView
        } set {
            guard let content = newValue else {
                return
            }
            
            if let rowContentHostingController = rowContentHostingController {
                rowContentHostingController.rootView = content
            } else {
                rowContentHostingController = UIHostingController(rootView: content)
                
                let view = rowContentHostingController!.view!
                let margins = contentView.layoutMarginsGuide
                
                view.translatesAutoresizingMaskIntoConstraints = false
                
                contentView.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                    view.topAnchor.constraint(equalTo: margins.topAnchor),
                    view.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                    view.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
                ])
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    static let hostingCellIdentifier = "HostingCell"
}

#endif
