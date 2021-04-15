//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

protocol _opaque_UIHostingCollectionViewController: UIViewController {
    func scrollToTop(anchor: UnitPoint?, animated: Bool)
    
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func scrollTo<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint?)
    func scrollTo<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint?)
    
    func select<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
    func select<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint?)
    func select<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint?)
    
    func selectNextItem(anchor: UnitPoint?)
    func selectPreviousItem(anchor: UnitPoint?)
    
    func deselect<ID: Hashable>(_ id: ID)
    
    func selection<ID: Hashable>(for id: ID) -> Binding<Bool>
}

public final class UIHostingCollectionViewController<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    CellContent: View
>: UIViewController, _opaque_UIHostingCollectionViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias _SwiftUIType = _CollectionView<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, CellContent>
    typealias UICollectionViewCellType = UIHostingCollectionViewCell<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        CellContent
    >
    
    typealias UICollectionViewSupplementaryViewType = UIHostingCollectionViewSupplementaryView<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        CellContent
    >
    
    var dataSource: DataSource? = nil {
        didSet {
            updateDataSource(oldValue: oldValue, newValue: dataSource)
        }
    }
    
    var dataSourceConfiguration: _SwiftUIType.DataSourceConfiguration
    var viewProvider: _SwiftUIType.ViewProvider
    
    var _scrollViewConfiguration = CocoaScrollViewConfiguration<AnyView>() {
        didSet {
            collectionView.configure(with: _scrollViewConfiguration)
        }
    }
    
    var _dynamicViewContentTraitValues = _DynamicViewContentTraitValues() {
        didSet {
            #if !os(tvOS)
            collectionView.dragInteractionEnabled = _dynamicViewContentTraitValues.onMove != nil
            #endif
        }
    }
    
    var configuration: _SwiftUIType.Configuration {
        didSet {
            collectionView.allowsMultipleSelection = configuration.allowsMultipleSelection
            #if !os(tvOS)
            collectionView.reorderingCadence = configuration.reorderingCadence
            #endif
        }
    }
    
    var collectionViewLayout: CollectionViewLayout = FlowCollectionViewLayout() {
        didSet {
            collectionView.setCollectionViewLayout(collectionViewLayout._toUICollectionViewLayout(), animated: true)
        }
    }
    
    lazy var _animateDataSourceDifferences: Bool = true
    lazy var _internalDiffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>? = nil
    
    lazy var cache = Cache(parent: self)
    
    #if !os(tvOS)
    fileprivate lazy var dragAndDropDelegate = DragAndDropDelegate(parent: self)
    #endif
    
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout._toUICollectionViewLayout())
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        
        #if !os(tvOS)
        collectionView.dragDelegate = dragAndDropDelegate
        collectionView.dropDelegate = dragAndDropDelegate
        #endif
        
        return collectionView
    }()
    
    var maximumCellSize: OptionalDimensions {
        let result = OptionalDimensions(
            width: max(collectionView.contentSize.width - 0.001, 0),
            height: max(collectionView.contentSize.height - 0.001, 0)
        )
        
        guard (result.width != 0 && result.height != 0) else {
            return nil
        }
        
        return result
    }
    
    init(
        dataSourceConfiguration: _SwiftUIType.DataSourceConfiguration,
        viewProvider: _SwiftUIType.ViewProvider,
        configuration: _SwiftUIType.Configuration
    ) {
        self.dataSourceConfiguration = dataSourceConfiguration
        self.viewProvider = viewProvider
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView()
        collectionView.backgroundView?.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(
            UICollectionViewCellType.self,
            forCellWithReuseIdentifier: .hostingCollectionViewCellIdentifier
        )
        
        collectionView.register(
            UICollectionViewSupplementaryViewType.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: .hostingCollectionViewSupplementaryViewIdentifier
        )
        
        collectionView.register(
            UICollectionViewSupplementaryViewType.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: .hostingCollectionViewSupplementaryViewIdentifier
        )
        
        let diffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: collectionView) { [weak self] collectionView, indexPath, sectionIdentifier in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: .hostingCollectionViewCellIdentifier,
                for: indexPath
            ) as! UICollectionViewCellType
            
            guard let item = self.item(at: indexPath), let section = self.section(from: indexPath) else {
                return cell
            }
            
            cell.configuration = .init(
                item: item,
                section: section,
                itemIdentifier: self.dataSourceConfiguration.identifierMap[item],
                sectionIdentifier: self.dataSourceConfiguration.identifierMap[section],
                indexPath: indexPath,
                viewProvider: self.viewProvider,
                maximumSize: self.maximumCellSize
            )
            
            self.cache.preconfigure(cell: cell)
            
            cell.update()
            
            return cell
        }
        
        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            guard (kind == UICollectionView.elementKindSectionHeader && SectionHeaderContent.self != EmptyView.self) || (kind == UICollectionView.elementKindSectionFooter && SectionFooterContent.self != EmptyView.self) else {
                return nil
            }
            
            let item = self.item(at: indexPath)
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: .hostingCollectionViewSupplementaryViewIdentifier,
                for: indexPath
            ) as! UICollectionViewSupplementaryViewType
            
            guard let section = self.section(from: indexPath) else {
                return view
            }
            
            view.configuration = .init(
                kind: kind,
                item: item,
                section: section,
                itemIdentifier: self.dataSourceConfiguration.identifierMap[item],
                sectionIdentifier: self.dataSourceConfiguration.identifierMap[section],
                indexPath: indexPath,
                viewProvider: self.viewProvider,
                maximumSize: self.maximumCellSize
            )
            
            view.supplementaryViewWillDisplay(inParent: self)
            
            return view
        }
        
        self._internalDiffableDataSource = diffableDataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewSafeAreaInsetsDidChange()  {
        super.viewSafeAreaInsetsDidChange()
        
        invalidateLayout(includingCache: false)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        invalidateLayout(includingCache: true)
    }
    
    public func invalidateLayout(includingCache: Bool) {
        if includingCache {
            cache.invalidate()
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDelegate -
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? UICollectionViewCellType)?.cellWillDisplay(inParent: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? UICollectionViewCellType)?.cellDidEndDisplaying()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isHighlightable ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isHighlighted = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isHighlighted = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = cellForItem(at: indexPath) else {
            return false
        }
        
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            return false
        }
        
        return cell.isSelectable
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isSelectable ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isSelected = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cellForItem(at: indexPath)?.isSelected = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        cellForItem(at: indexPath)?.isFocusable ?? true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        if let previousCell = context.previouslyFocusedView as? UICollectionViewCellType {
            previousCell.isFocused = false
        }
        
        if let nextCell = context.nextFocusedView as? UICollectionViewCellType {
            nextCell.isFocused = true
        }
        
        return true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    private let prototypeCell = UICollectionViewCellType()
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        cache.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard (SectionHeaderContent.self != EmptyView.self && SectionHeaderContent.self != Never.self) else {
            return .zero
        }
        
        return cache.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderOrFooterInSection: section,
            kind: UICollectionView.elementKindSectionHeader
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard (SectionFooterContent.self != EmptyView.self && SectionFooterContent.self != Never.self) else {
            return .zero
        }
        
        return cache.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderOrFooterInSection: section,
            kind: UICollectionView.elementKindSectionFooter
        )
    }
}

extension UIHostingCollectionViewController {
    #if !os(tvOS)
    class DragAndDropDelegate: NSObject, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
        unowned let parent: UIHostingCollectionViewController
        
        init(parent: UIHostingCollectionViewController) {
            self.parent = parent
        }
        
        // MARK: - UICollectionViewDragDelegate -
        
        func collectionView(
            _ collectionView: UICollectionView,
            itemsForBeginning session: UIDragSession,
            at indexPath: IndexPath
        ) -> [UIDragItem] {
            if let dragItems = parent.cache.preferences(itemAt: indexPath).wrappedValue?.dragItems {
                return dragItems.map(UIDragItem.init)
            }
            
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
        
        func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
            .init()
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            dragSessionAllowsMoveOperation session: UIDragSession
        ) -> Bool {
            true
        }
        
        // MARK: - UICollectionViewDropDelegate -
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            performDropWith coordinator: UICollectionViewDropCoordinator
        ) {
            if let onMove = parent._dynamicViewContentTraitValues.onMove {
                if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath, var destinationIndexPath = coordinator.destinationIndexPath {
                    parent.cache.invalidateCachedContentSize(forIndexPath: sourceIndexPath)
                    parent.cache.invalidateCachedContentSize(forIndexPath: destinationIndexPath)
                    
                    if sourceIndexPath.item < destinationIndexPath.item {
                        destinationIndexPath.item += 1
                    }
                    
                    onMove(
                        IndexSet([sourceIndexPath.item]),
                        destinationIndexPath.item
                    )
                }
            }
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidUpdate session: UIDropSession,
            withDestinationIndexPath destinationIndexPath: IndexPath?
        ) -> UICollectionViewDropProposal {
            if session.localDragSession == nil {
                return .init(operation: .cancel, intent: .unspecified)
            }
            
            if collectionView.hasActiveDrag {
                return .init(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            
            return .init(operation: .cancel)
        }
        
        @objc
        func collectionView(
            _ collectionView: UICollectionView,
            dropSessionDidEnd session: UIDropSession
        ) {
            
        }
    }
    #endif
}

extension UIHostingCollectionViewController {
    func refreshVisibleCellsAndSupplementaryViews() {
        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).forEach {
            guard let view = $0 as? UICollectionViewSupplementaryViewType else {
                return
            }
            
            view.configuration?.viewProvider = viewProvider
            view.update(forced: true)
        }
        
        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).forEach {
            guard let view = $0 as? UICollectionViewSupplementaryViewType else {
                return
            }
            
            view.configuration?.viewProvider = viewProvider
            view.update(forced: true)
        }
    }
}

extension UIHostingCollectionViewController {
    func section(from indexPath: IndexPath) -> SectionType? {
        guard let dataSource = dataSource, dataSource.contains(indexPath) else {
            return nil
        }
        
        return _unsafelyUnwrappedSection(from: indexPath)
    }
    
    func item(at indexPath: IndexPath) -> ItemType? {
        guard let dataSource = dataSource, dataSource.contains(indexPath) else {
            return nil
        }
        
        return _unsafelyUnwrappedItem(at: indexPath)
    }
    
    func _unsafelyUnwrappedSection(from indexPath: IndexPath) -> SectionType {
        if case .static(let data) = dataSource {
            return data[data.index(data.startIndex, offsetBy: indexPath.section)].model
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.snapshot().sectionIdentifiers[indexPath.section]]
        }
    }
    
    func _unsafelyUnwrappedItem(at indexPath: IndexPath) -> ItemType {
        if case .static(let data) = dataSource {
            return data[indexPath]
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.itemIdentifier(for: indexPath)!]
        }
    }
    
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCellType? {
        let result = collectionView
            .visibleCells
            .compactMap({ $0 as? UICollectionViewCellType})
            .first(where: { $0.configuration?.indexPath == indexPath })
        
        if let dataSource = dataSource, !dataSource.contains(indexPath) {
            return nil
        }
        
        return result ?? (_internalDiffableDataSource?.collectionView(collectionView, cellForItemAt: indexPath) as? UICollectionViewCellType)
    }
}

// MARK: - Extensions -

extension UIHostingCollectionViewController {
    public func scrollToTop(anchor: UnitPoint? = nil, animated: Bool = true) {
        collectionView.setContentOffset(.zero, animated: animated)
    }
    
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func scrollTo<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(before:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func scrollTo<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(after:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func select<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(before:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func select<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(after:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func selectNextItem(anchor: UnitPoint?) {
        guard !configuration.allowsMultipleSelection else {
            assertionFailure("selectNextItem(anchor:) is unavailable when multiple selection is allowed.")
            
            return
        }
        
        guard let indexPathForSelectedItem = collectionView.indexPathsForSelectedItems?.first else {
            if let indexPath = collectionView.indexPathsForVisibleItems.sorted().first {
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .init(anchor)
                )
            }
            
            return
        }
        
        let indexPath = collectionView.indexPath(after: indexPathForSelectedItem)
        
        guard collectionView.contains(indexPath) else {
            return collectionView.deselectItem(at: indexPathForSelectedItem, animated: true)
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func selectPreviousItem(anchor: UnitPoint?) {
        guard !configuration.allowsMultipleSelection else {
            assertionFailure("selectPreviousItem(anchor:) is unavailable when multiple selection is allowed.")
            
            return
        }
        
        guard let indexPathForSelectedItem = collectionView.indexPathsForSelectedItems?.first else {
            if let indexPath = collectionView.indexPathsForVisibleItems.sorted().last {
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .init(anchor)
                )
            }
            
            return
        }
        
        let indexPath = collectionView.indexPath(before: indexPathForSelectedItem)
        
        guard collectionView.contains(indexPath) else {
            return collectionView.deselectItem(at: indexPathForSelectedItem, animated: true)
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.deselectItem(
            at: indexPath,
            animated: true
        )
    }
    
    private func indexPath<ID: Hashable>(for id: ID) -> IndexPath? {
        cache.firstIndexPath(for: id)
    }
    
    public func selection<ID: Hashable>(for id: ID) -> Binding<Bool> {
        let indexPath = cache.firstIndexPath(for: id)
        
        return .init(
            get: { indexPath.flatMap({ [weak self] in self?.collectionView.cellForItem(at: $0)?.isSelected }) ?? false },
            set: { [weak self] newValue in
                guard let indexPath = indexPath else {
                    return
                }
                
                self?.collectionView.deselectItem(at: indexPath, animated: true)
            }
        )
    }
}

// MARK: - Auxiliary Implementation -

fileprivate extension Dictionary where Key == Int, Value == [Int: CGSize] {
    subscript(_ indexPath: IndexPath) -> CGSize? {
        get {
            self[indexPath.section, default: [:]][indexPath.row]
        } set {
            self[indexPath.section, default: [:]][indexPath.row] = newValue
        }
    }
}

fileprivate extension UICollectionView {
    func contains(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section < numberOfSections, indexPath.row >= 0, indexPath.row < numberOfItems(inSection: indexPath.section) else {
            return false
        }
        
        return true
    }
    
    func indexPath(before indexPath: IndexPath) -> IndexPath {
        IndexPath(row: indexPath.row - 1, section: indexPath.section)
    }
    
    func indexPath(after indexPath: IndexPath) -> IndexPath {
        IndexPath(row: indexPath.row + 1, section: indexPath.section)
    }
}

fileprivate extension UICollectionView.ScrollPosition {
    init(_ unitPoint: UnitPoint?) {
        switch (unitPoint ?? .zero) {
            case .zero:
                self = [.left, .top]
            case .center:
                self = [.centeredHorizontally, .centeredVertically]
            case .leading:
                self = [.left, .centeredVertically]
            case .trailing:
                self = [.right, .centeredVertically]
            case .top:
                self = [.top, .centeredVertically]
            case .bottom:
                self = [.bottom, .centeredVertically]
            case .topLeading:
                self = [.left, .top]
            case .topTrailing:
                self = [.right, .top]
            case .bottomLeading:
                self = [.right, .bottom]
            case .bottomTrailing:
                self = [.right, .bottom]
            default:
                assertionFailure()
                self = []
        }
    }
}

#endif
