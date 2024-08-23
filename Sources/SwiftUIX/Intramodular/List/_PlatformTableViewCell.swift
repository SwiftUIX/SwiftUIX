//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@_documentation(visibility: internal)
public class _PlatformTableViewCell<ItemType: Identifiable, Content: View>: UITableViewCell {
    struct State: Hashable {
        let isFocused: Bool
        let isHighlighted: Bool
        let isSelected: Bool
    }
    
    var tableViewController: UITableViewController!
    var indexPath: IndexPath?
    
    var item: ItemType!
    var makeContent: ((ItemType) -> Content)!
    
    var state: State {
        .init(
            isFocused: isFocused,
            isHighlighted: isHighlighted,
            isSelected: isSelected
        )
    }
    
    var contentHostingController: UIHostingController<RootView>!
    
    override public func awakeFromNib() {
        #if !os(visionOS)
        super.awakeFromNib()
        #endif
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reload(with animation: UITableView.RowAnimation) {
        guard let indexPath = indexPath else {
            return
        }
        
        tableViewController.tableView.reloadRows(at: [indexPath], with: animation)
    }
}

extension _PlatformTableViewCell {
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
            
            contentHostingController.willMove(toParent: tableViewController)
            tableViewController.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: tableViewController)
            
            NSLayoutConstraint.activate([
                contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            contentHostingController.rootView = RootView(base: self)
            contentHostingController.view.invalidateIntrinsicContentSize()
        }
    }
    
    func reset() {
        contentHostingController.willMove(toParent: nil)
        contentHostingController.view.removeFromSuperview()
        contentHostingController.removeFromParent()
        contentHostingController = nil
        
        update()
    }
}

// MARK: - Auxiliary

extension _PlatformTableViewCell {
    struct RootView: View {
        private struct _CellProxyBase: SwiftUIX._CellProxyBase {
            weak var base: _PlatformTableViewCell<ItemType, Content>?
            
            var globalFrame: CGRect {
                guard let base = base, let parentViewController = base._parentViewController, let coordinateSpace = parentViewController.view.window?.coordinateSpace else {
                    return .zero
                }
                
                return parentViewController.view.convert(base.frame, to: coordinateSpace)
            }
            
            func invalidateLayout(with context: CellProxy.InvalidationContext) {
                fatalError("unimplemented")
            }
            
            func select() {
                base?.isSelected = true
            }
            
            func deselect() {
                base?.isSelected = false
            }

            private func performWithAnimation(
                _ action: () -> ()
            ) {
                base?.tableViewController.tableView.beginUpdates()
                action()
                base?.tableViewController.tableView.endUpdates()
            }
        }
        
        private let _cellProxyBase: _CellProxyBase
        private let id: AnyHashable
        private let content: Content
        private let state: State
        
        init(
            base: _PlatformTableViewCell<ItemType, Content>
        ) {
            self._cellProxyBase = .init(base: base)
            self.id = base.item.id
            self.content = base.makeContent(base.item)
            self.state = base.state
        }
        
        var body: some View {
            content
                .environment(\._cellProxy, .init(base: _cellProxyBase))
                .environment(\.isCellFocused, state.isFocused)
                .environment(\.isCellHighlighted, state.isHighlighted)
                .environment(\.isCellSelected, state.isSelected)
                .id(id)
        }
    }
}

// MARK: - Helpers

extension String {
    static let hostingTableViewCellIdentifier = "_PlatformTableViewCell"
}

#endif
