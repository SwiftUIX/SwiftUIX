//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

final class CocoaHostingCollectionViewController<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    CellContent: View
>: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias _SwiftUIType = _CollectionView<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        CellContent
    >

    typealias CellType = CocoaHostingCollectionViewCell<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        CellContent
    >

    typealias SupplementaryViewType = CocoaHostingCollectionViewSupplementaryView<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        CellContent
    >

    typealias DataSource = _SwiftUIType.DataSource
    
    var latestRepresentableUpdate: _AppKitOrUIKitViewRepresentableUpdate?

    var dataSourceConfiguration: _SwiftUIType.DataSource.Configuration
    var dataSource: DataSource.Payload? = nil {
        didSet {
            updateDataSource(oldValue: oldValue, newValue: dataSource)
        }
    }
        
   /* var dataSource: _SwiftUIType.DataSource {
        .init(configuration: dataSourceConfiguration, payload: dataSource)
    }*/
    
    var viewProvider: _SwiftUIType.ViewProvider
    
    var _scrollViewConfiguration: CocoaScrollViewConfiguration<AnyView> = nil {
        didSet {
            collectionView.configure(with: _scrollViewConfiguration)
        }
    }
    
    var isInitialContentAlignmentSet = false
    
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
            let layout = collectionViewLayout._toUICollectionViewLayout()
            
            if let layout = layout as? UICollectionViewFlowLayout {
                if _scrollViewConfiguration.axes == [.horizontal] {
                    layout.scrollDirection = .horizontal
                } else if _scrollViewConfiguration.axes == [.vertical] {
                    layout.scrollDirection = .vertical
                }
            }
            
            collectionView.setCollectionViewLayout(layout, animated: true)
        }
    }
    
    lazy var _animateDataSourceDifferences: Bool = true
    lazy var _internalDiffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>? = nil

    lazy var cache = Cache(parent: self)
    
    #if !os(tvOS)
    lazy var dragAndDropDelegate = DragAndDropDelegate(parent: self)
    #endif
    
    lazy var collectionView: _AppKitOrUIKitCollectionView = {
        let collectionView = _AppKitOrUIKitCollectionView(parent: self)
        
        collectionView.delegate = self
        #if !os(tvOS)
        collectionView.dragDelegate = dragAndDropDelegate
        collectionView.dropDelegate = dragAndDropDelegate
        #endif
        
        view.addSubview(collectionView)
        
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 15.0, *) {
            collectionView.remembersLastFocusedIndexPath = true
            collectionView.selectionFollowsFocus = true

            let _setShouldBecomeFocusedOnSelectionSEL = Selector(("_setShouldBecomeFocusedOnSelection:"))
            
            if collectionView.responds(to: _setShouldBecomeFocusedOnSelectionSEL) {
                collectionView.perform(_setShouldBecomeFocusedOnSelectionSEL, with: true)
            }
        }
        #endif

        return collectionView
    }()
    
    private lazy var lastViewSafeAreaInsets: UIEdgeInsets = view.safeAreaInsets

    init(
        dataSourceConfiguration: _SwiftUIType.DataSource.Configuration,
        viewProvider: _SwiftUIType.ViewProvider,
        configuration: _SwiftUIType.Configuration
    ) {
        self.dataSourceConfiguration = dataSourceConfiguration
        self.viewProvider = viewProvider
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        tearDownDiffableDataSource()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCellAndSupplementaryViewTypes()
        setupDiffableDataSource()
    }
    
    private func registerCellAndSupplementaryViewTypes() {
        collectionView.register(
            SupplementaryViewType.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: .hostingCollectionViewHeaderSupplementaryViewIdentifier
        )
        
        collectionView.register(
            CellType.self,
            forCellWithReuseIdentifier: .hostingCollectionViewCellIdentifier
        )

        collectionView.register(
            SupplementaryViewType.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: .hostingCollectionViewFooterSupplementaryViewIdentifier
        )
    }
    
    private func setupDiffableDataSource() {
        let diffableDataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: collectionView) { [weak self] collectionView, indexPath, sectionIdentifier in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: .hostingCollectionViewCellIdentifier,
                for: indexPath
            ) as! CellType

            cell.parentViewController = self

            guard let cellContentConfiguration = self.contentConfiguration(
                for: indexPath,
                reuseIdentifier: .hostingCollectionViewCellIdentifier
            ) else {
                return cell
            }

            cell.cellContentConfiguration = cellContentConfiguration
            self.cache.preconfigure(cell: cell)
            
            cell.update(disableAnimation: true)

            return cell
        }
        
        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self, self.dataSource != nil else {
                return nil
            }
            
            guard (kind == UICollectionView.elementKindSectionHeader && SectionHeaderContent.self != EmptyView.self) || (kind == UICollectionView.elementKindSectionFooter && SectionFooterContent.self != EmptyView.self) else {
                return nil
            }
                        
            let reuseIdentifier = kind == UICollectionView.elementKindSectionHeader ? String.hostingCollectionViewHeaderSupplementaryViewIdentifier : String.hostingCollectionViewFooterSupplementaryViewIdentifier
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            ) as! SupplementaryViewType
            
            view.configuration = self.contentConfiguration(for: indexPath, reuseIdentifier: reuseIdentifier)
            self.cache.preconfigure(supplementaryView: view)
            
            view.update()
            
            return view
        }
        
        self._internalDiffableDataSource = diffableDataSource
    }

    private func tearDownDiffableDataSource() {
        if let dataSource = _internalDiffableDataSource {
            var snapshot = dataSource.snapshot()

            snapshot.deleteAllItems()

            dataSource.apply(snapshot)
        }

        _internalDiffableDataSource = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        applyInitialAlignment: do {
            if self._scrollViewConfiguration.initialContentAlignment == .bottom {
                if !self.isInitialContentAlignmentSet {
                    self.scrollToLast(animated: false)
                    
                    self.isInitialContentAlignmentSet = true
                }
            }
        }
        
        configurePreferredContentSize: do {
            if configuration.fixedSize.horizontal && configuration.fixedSize.vertical {
                let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
                
                if !contentSize.isAreaZero {
                    preferredContentSize = .init(
                        width: contentSize.width,
                        height: contentSize.height
                    )
                }
            }
        }
    }
        
    override public func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let newSafeAreaInsets = UIEdgeInsets(
            top: view.safeAreaInsets.top.rounded(.up),
            left: view.safeAreaInsets.left.rounded(.up),
            bottom: view.safeAreaInsets.bottom.rounded(.up),
            right: view.safeAreaInsets.right.rounded(.up)
        )
        
        guard lastViewSafeAreaInsets != newSafeAreaInsets else {
            return
        }
        
        lastViewSafeAreaInsets = newSafeAreaInsets
    }
    
    public override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        cache.invalidate()

        DispatchQueue.main.async {
            self.invalidateLayout(animated: false)
        }
    }
    
    public func invalidateLayout(animated: Bool) {
        CATransaction._withDisabledActions(!animated) {
            collectionView.collectionViewLayout.invalidateLayout()
            
            if !animated {
                CATransaction.commit()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? CellType)?.cellWillDisplay(inParent: self)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        (view as? SupplementaryViewType)?.supplementaryViewWillDisplay(inParent: self)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? CellType)?.cellDidEndDisplaying()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        (view as? SupplementaryViewType)?.supplementaryViewDidEndDisplaying()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        cellForItem(at: indexPath)?.isHighlightable ?? false
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        cellForItem(at: indexPath)?.isHighlighted = true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        cellForItem(at: indexPath)?.isHighlighted = false
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard let cell = cellForItem(at: indexPath) else {
            return false
        }
        
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            return false
        }
        
        return cell.isSelectable
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool {
        cellForItem(at: indexPath)?.isSelectable ?? true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        cellForItem(at: indexPath)?.isSelected = true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        cellForItem(at: indexPath)?.isSelected = false
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        canFocusItemAt indexPath: IndexPath
    ) -> Bool {
        cellForItem(at: indexPath)?.isFocusable ?? true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext
    ) -> Bool {
        if let previousCell = context.previouslyFocusedView as? CellType {
            if previousCell.isFocused {
                previousCell.isFocused = false
            }
        }
        
        if let nextCell = context.nextFocusedView as? CellType {
            if nextCell.isFocused {
                nextCell.isFocused = true
            }
        }
        
        return true
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator
    ) {
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
        
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if let itemSize = (collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout)?.itemSize, itemSize != AppKitOrUIKitCollectionViewFlowLayout.automaticSize {
            return itemSize
        }
        
        return cache.sizeForCellOrSupplementaryView(
            withReuseIdentifier: String.hostingCollectionViewCellIdentifier,
            at: indexPath
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .zero
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        (collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout)?.minimumLineSpacing ?? .zero
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        (collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout)?.minimumInteritemSpacing ?? .zero
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard (SectionHeaderContent.self != EmptyView.self && SectionHeaderContent.self != Never.self) else {
            return .zero
        }
        
        return cache.sizeForCellOrSupplementaryView(
            withReuseIdentifier: String.hostingCollectionViewHeaderSupplementaryViewIdentifier,
            at: IndexPath(row: -1, section: section)
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
        return cache.sizeForCellOrSupplementaryView(
            withReuseIdentifier: String.hostingCollectionViewFooterSupplementaryViewIdentifier,
            at: IndexPath(row: -1, section: section)
        )
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let _scrollViewWillBeginDragging_dismissKeyboard = "_scrollViewWillBeginDragging_dismissKeyboard"
        
        self.perform(Selector(_scrollViewWillBeginDragging_dismissKeyboard))
    }
    
    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @objc(_scrollViewWillBeginDragging_dismissKeyboard) func _scrollViewWillBeginDragging_dismissKeyboard() {
        #if os(iOS)
        if #available(iOS 13.0, *) {
            if _scrollViewConfiguration.keyboardDismissMode == .onDrag {
                Keyboard.dismiss()
            }
        }
        #endif
    }
    
    public func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        if let onOffsetChange = _scrollViewConfiguration.onOffsetChange {
            onOffsetChange(scrollView.contentOffset(forContentType: AnyView.self))
        }
        
        if let contentOffset = _scrollViewConfiguration.contentOffset {
            contentOffset.wrappedValue = collectionView.contentOffset
        }
    }
    
    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        _scrollViewConfiguration.onDragEnd?()
    }
}

extension CocoaHostingCollectionViewController {
    func refreshVisibleCellsAndSupplementaryViews() {
        for view in collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) {
            guard let view = view as? SupplementaryViewType, view.latestRepresentableUpdate != latestRepresentableUpdate else {
                continue
            }

            view.cache.content = nil
            
            view.update(disableAnimation: true)
        }

        for cell in collectionView.visibleCells {
            guard let cell = cell as? CellType, cell.latestRepresentableUpdate != latestRepresentableUpdate else {
                continue
            }

            cell.contentCache.content = nil
        
            cell.update(disableAnimation: true)
        }
        
        for view in collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter) {
            guard let view = view as? SupplementaryViewType, view.latestRepresentableUpdate != latestRepresentableUpdate else {
                continue
            }

            view.cache.content = nil
            
            view.update(disableAnimation: true)
        }
    }
}

extension CocoaHostingCollectionViewController {
    func contentConfiguration(
        for indexPath: IndexPath,
        reuseIdentifier: String
    ) -> CellType.ContentConfiguration? {
        let item = self.item(at: indexPath)
        let dataSourceConfiguration = self.dataSourceConfiguration
        let viewProvider = self.viewProvider

        guard let section = self.section(from: indexPath) else {
            return nil
        }
        
        switch reuseIdentifier {
            case .hostingCollectionViewHeaderSupplementaryViewIdentifier:
                return SupplementaryViewType.ContentConfiguration(
                    reuseIdentifier: reuseIdentifier,
                    item: item,
                    section: section,
                    itemIdentifier: item.map({ dataSourceConfiguration.identifierMap[$0] }),
                    sectionIdentifier: dataSourceConfiguration.identifierMap[section],
                    indexPath: indexPath,
                    makeContent: { .init(viewProvider.sectionContent(for: UICollectionView.elementKindSectionHeader)?(section)) },
                    maximumSize: maximumCollectionViewCellSize
                )
            case .hostingCollectionViewCellIdentifier:
                guard let item = item else {
                    return nil
                }
                
                return CellType.ContentConfiguration(
                    reuseIdentifier: reuseIdentifier,
                    item: item,
                    section: section,
                    itemIdentifier: dataSourceConfiguration.identifierMap[item],
                    sectionIdentifier: dataSourceConfiguration.identifierMap[section],
                    indexPath: indexPath,
                    makeContent: { .init(viewProvider.rowContent(section, item)) },
                    maximumSize: maximumCollectionViewCellSize
                )
            case .hostingCollectionViewFooterSupplementaryViewIdentifier:
                return SupplementaryViewType.ContentConfiguration(
                    reuseIdentifier: reuseIdentifier,
                    item: item,
                    section: section,
                    itemIdentifier: item.map({ dataSourceConfiguration.identifierMap[$0] }),
                    sectionIdentifier: dataSourceConfiguration.identifierMap[section],
                    indexPath: indexPath,
                    makeContent: { .init(viewProvider.sectionContent(for: UICollectionView.elementKindSectionFooter)?(section)) },
                    maximumSize: maximumCollectionViewCellSize
                )
            default:
                assertionFailure()

                return nil
        }
    }
    
    private func section(from indexPath: IndexPath) -> SectionType? {
        guard let dataSource = dataSource, dataSource.contains(indexPath) else {
            return nil
        }
        
        if case .static(let data) = dataSource {
            return data[data.index(data.startIndex, offsetBy: indexPath.section)].model
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.snapshot().sectionIdentifiers[indexPath.section]]
        }
    }
    
    private func item(at indexPath: IndexPath) -> ItemType? {
        guard indexPath.row >= 0, let dataSource = dataSource, dataSource.contains(indexPath) else {
            return nil
        }
        
        if case .static(let data) = dataSource {
            return data[indexPath]
        } else {
            return dataSourceConfiguration.identifierMap[_internalDiffableDataSource!.itemIdentifier(for: indexPath)!]
        }
    }
}

extension CocoaHostingCollectionViewController {
    func cellForItem(at indexPath: IndexPath) -> CellType? {
        let result = collectionView
            .visibleCells
            .compactMap({ $0 as? CellType})
            .first(where: { $0.cellContentConfiguration?.indexPath == indexPath })
        
        if let dataSource = dataSource, !dataSource.contains(indexPath) {
            return nil
        }
        
        return result ?? (_internalDiffableDataSource?.collectionView(collectionView, cellForItemAt: indexPath) as? CellType)
    }
}

// MARK: - Auxiliary

extension CocoaHostingCollectionViewController {
    var maximumCollectionViewCellSize: OptionalDimensions {
        let targetCollectionViewSize = collectionView.frame.size
        var baseContentSize = collectionView.contentSize
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout {
            if collectionViewLayout.scrollDirection == .vertical {
                if (baseContentSize.width == 0 && targetCollectionViewSize.width > 0) || targetCollectionViewSize != collectionView.frame.size {
                    baseContentSize.width = targetCollectionViewSize.width - collectionView.adjustedContentInset.horizontal
                }
            } else if collectionViewLayout.scrollDirection == .horizontal {
                if (baseContentSize.height == 0 && targetCollectionViewSize.height > 0) || targetCollectionViewSize != collectionView.frame.size {
                    baseContentSize.height = targetCollectionViewSize.height - collectionView.adjustedContentInset.vertical
                }
            }
        }
        
        let contentSize = CGSize(
            width: (baseContentSize.width - ((collectionView.collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout)?.sectionInset.horizontal ?? 0)) - collectionView.contentInset.horizontal,
            height: (baseContentSize.height - ((collectionView.collectionViewLayout as? AppKitOrUIKitCollectionViewFlowLayout)?.sectionInset.vertical ?? 0)) - collectionView.contentInset.vertical
        )
        
        var result = OptionalDimensions(
            width: max(floor(contentSize.width - 0.001), 0),
            height: max(floor(contentSize.height - 0.001), 0)
        )
        
        if !_scrollViewConfiguration.axes.contains(.vertical) || result.width == 0 {
            result.width = AppKitOrUIKitView.layoutFittingExpandedSize.width
        }
        
        if !_scrollViewConfiguration.axes.contains(.horizontal) || result.height == 0 {
            result.height = AppKitOrUIKitView.layoutFittingExpandedSize.height
        }
        
        return result
    }
}

extension CocoaHostingCollectionViewController {
    class _AppKitOrUIKitCollectionView: AppKitOrUIKitCollectionView, UICollectionViewDelegateFlowLayout {
        weak var parent: CocoaHostingCollectionViewController?
        
        init(parent: CocoaHostingCollectionViewController) {
            self.parent = parent
            
            super.init(
                frame: parent.view.bounds,
                collectionViewLayout: parent.collectionViewLayout._toUICollectionViewLayout()
            )
            
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundColor = nil
            backgroundView = nil
            isPrefetchingEnabled = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            guard let parent = parent else {
                return AppKitOrUIKitCollectionViewFlowLayout.automaticSize
            }
            
            return parent.collectionView(
                self,
                layout: collectionViewLayout,
                sizeForItemAt: indexPath
            )
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
            guard let parent = parent else {
                return AppKitOrUIKitCollectionViewFlowLayout.automaticSize
            }
            
            return parent.collectionView(
                self,
                layout: collectionViewLayout,
                referenceSizeForHeaderInSection: section
            )
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForFooterInSection section: Int
        ) -> CGSize {
            guard let parent = parent else {
                return AppKitOrUIKitCollectionViewFlowLayout.automaticSize
            }
            
            return parent.collectionView(
                self,
                layout: collectionViewLayout,
                referenceSizeForFooterInSection: section
            )
        }
    }
}

#endif
