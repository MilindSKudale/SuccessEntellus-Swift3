import UIKit

/// A custom `UICollectionViewLayout` subclass responsible for
/// defining the layout for all the `PagingItem` cells. You can
/// subclass this type if you need further customization outside what
/// is provided by the `PagingOptions` protocol.
///
/// To create your own `PagingViewControllerLayout` you need to
/// override the `collectionViewLayout` property in
/// `PagingViewController`. Then you can override
/// `layoutAttributesForItem:` and `layoutAttributesForElementsInRect:`
/// to update the layout attributes for each cell.
///
/// This layout has two decoration views; one for the border at the
/// bottom and one for the view that indicates the currently selected
/// `PagingItem`. You can customize their layout attributes by
/// overriding `layoutAttributesForDecorationView:`.
open class PagingCollectionViewLayout<T: PagingItem>:
  UICollectionViewLayout where T: Hashable, T: Comparable {
  
  var state: PagingState<T>?
  var dataStructure: PagingDataStructure<T>
  var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
  
  open override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  override open class var layoutAttributesClass: AnyClass {
    return PagingCellLayoutAttributes.self
  }
  
  private var view: UICollectionView {
    return collectionView!
  }
  
  private var range: Range<Int> {
    return 0..<view.numberOfItems(inSection: 0)
  }
  
  private var adjustedMenuInsets: UIEdgeInsets {
    return UIEdgeInsets(
      top: options.menuInsets.top + safeAreaInsets.top,
      left: options.menuInsets.left + safeAreaInsets.left,
      bottom: options.menuInsets.bottom + safeAreaInsets.bottom,
      right: options.menuInsets.right + safeAreaInsets.right)
  }
  
  private var safeAreaInsets: UIEdgeInsets {
    if options.includeSafeAreaInsets, #available(iOS 11.0, *) {
      return view.safeAreaInsets
    } else {
      return .zero
    }
  }
  
  private let options: PagingOptions
  private let sizeCache: PagingSizeCache<T>
  private let indicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  private let borderLayoutAttributes: PagingBorderLayoutAttributes
  private var contentSize: CGSize = .zero
  private var invalidationSummary: InvalidationSummary = .everything
  private var currentTransition: PagingTransition? = nil
  private let PagingIndicatorKind = "PagingIndicatorKind"
  private let PagingBorderKind = "PagingBorderKind"

  init(options: PagingOptions, dataStructure: PagingDataStructure<T>, sizeCache: PagingSizeCache<T>) {
    
    self.options = options
    self.dataStructure = dataStructure
    self.sizeCache = sizeCache
    
    indicatorLayoutAttributes = PagingIndicatorLayoutAttributes(
      forDecorationViewOfKind: PagingIndicatorKind,
      with: IndexPath(item: 0, section: 0))
    
    borderLayoutAttributes = PagingBorderLayoutAttributes(
      forDecorationViewOfKind: PagingBorderKind,
      with: IndexPath(item: 1, section: 0))
    
    super.init()
    
    configure()
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate func configure() {
    register(options.indicatorClass, forDecorationViewOfKind: PagingIndicatorKind)
    register(options.borderClass, forDecorationViewOfKind: PagingBorderKind)
    indicatorLayoutAttributes.configure(options)
    borderLayoutAttributes.configure(options)
  }
  
  open override func prepare() {
    super.prepare()
    
    switch invalidationSummary {
    case .everything, .dataSourceCounts:
      layoutAttributes = [:]
      createLayoutAttributes()
    case .contentOffset:
      invalidateContentOffset()
    case .transition:
      invalidateTransition()
      invalidateContentOffset()
    case .sizes:
      layoutAttributes = [:]
      createLayoutAttributes()
      invalidateContentOffset()
    case .partial:
      break
    }
    
    updateBorderLayoutAttributes()
    updateIndicatorLayoutAttributes()
    
    invalidationSummary = .partial
  }
  
  override open func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
    super.invalidateLayout(with: context)
    invalidationSummary = invalidationSummary + InvalidationSummary(context)
  }
  
  override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = self.layoutAttributes[indexPath] else { return nil }
    layoutAttributes.progress = progressForItem(at: layoutAttributes.indexPath)
    return layoutAttributes
  }
  
  open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    switch (elementKind) {
    case PagingIndicatorKind:
      return indicatorLayoutAttributes
    case PagingBorderKind:
      return borderLayoutAttributes
    default:
      return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
  }
  
  override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes: [UICollectionViewLayoutAttributes] = Array(self.layoutAttributes.values)
    
    for attributes in layoutAttributes {
      if let pagingAttributes = attributes as? PagingCellLayoutAttributes {
        pagingAttributes.progress = progressForItem(at: attributes.indexPath)
      }
    }
    
    let indicatorAttributes = layoutAttributesForDecorationView(
      ofKind: PagingIndicatorKind,
      at: IndexPath(item: 0, section: 0))
    
    let borderAttributes = layoutAttributesForDecorationView(
      ofKind: PagingBorderKind,
      at: IndexPath(item: 1, section: 0))
    
    if let indicatorAttributes = indicatorAttributes {
      layoutAttributes.append(indicatorAttributes)
    }
    
    if let borderAttributes = borderAttributes {
      layoutAttributes.append(borderAttributes)
    }
    
    return layoutAttributes
  }
  
  // The content offset and distance between items can change while a
  // transition is in progress meaning the current transition will be
  // wrong. For instance, when hitting the edge of the collection view
  // while transitioning we need to reload all the paging items and
  // update the transition data.
  func updateCurrentTransition() {
    let oldTransition = currentTransition
    invalidateTransition()
    
    if let oldTransition = oldTransition,
      let newTransition = currentTransition {
      
      let contentOffset = CGPoint(
        x: view.contentOffset.x - (oldTransition.distance - newTransition.distance),
        y: view.contentOffset.y)
      
      currentTransition = PagingTransition(
        contentOffset: contentOffset,
        distance: oldTransition.distance)
    }
  }

  // MARK: Private
  
  private func invalidateContentOffset() {
    guard let state = state else { return }
    
    if options.menuTransition == .scrollAlongside {
      if let transition = currentTransition {
        
        // FIXME: Remove the progress check and move state into
        // invalidation context.
        if contentSize.width >= view.bounds.width && state.progress != 0 {
          let contentOffset = CGPoint(
            x: transition.contentOffset.x + (transition.distance * fabs(state.progress)),
            y: transition.contentOffset.y)
          
          // We need to use setContentOffset with no animation in
          // order to stop any ongoing scroll.
          view.setContentOffset(contentOffset, animated: false)
        }
      }
    }
  }
  
  /// In order to get the menu items to scroll alongside the content
  /// we create a transition struct to keep track of the initial
  /// content offset and the distance to the upcoming item so that we
  /// can update the content offset as the user is swiping.
  private func invalidateTransition() {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else {
        
        // When there is no upcomingIndexPath or any layout attributes
        // for that item we have no way to determine the distance.
        currentTransition = PagingTransition(
          contentOffset: view.contentOffset,
          distance: 0)
        return
    }
    
    var distance: CGFloat = 0
    
    switch (options.selectedScrollPosition) {
    case .left:
      distance = distanceToLeftAlignedItem()
    case .right:
      distance = distanceToRightAlignedItem()
    case .preferCentered:
      distance = distanceToCenteredItem()
    }
    
    // Update the distance to account for cases where the user has
    // scrolled all the way over to the other edge.
    if view.near(edge: .left, clearance: -distance) && distance < 0 && dataStructure.hasItemsBefore == false {
      distance = -(view.contentOffset.x + view.contentInset.left)
    } else if view.near(edge: .right, clearance: distance) && distance > 0 &&
      dataStructure.hasItemsAfter == false {
      
      let originalDistance = distance
      distance = view.contentSize.width - (view.contentOffset.x + view.bounds.width)
      
      if sizeCache.implementsWidthDelegate {
        let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
        distance += toWidth - to.frame.width
        
        if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
          let from = layoutAttributes[currentIndexPath] {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          distance -= from.frame.width - fromWidth
        }
        
        // If the selected cells grows so much that it will move
        // beyond the center of the view, we want to update the
        // distance after all.
        if options.selectedScrollPosition == .preferCentered {
          let center = view.bounds.midX
          let centerAfterTransition = to.frame.midX - distance
          if centerAfterTransition < center {
            distance = view.contentSize.width - (view.contentOffset.x + view.bounds.width)
          }
        }
      }
    }
    
    currentTransition = PagingTransition(
      contentOffset: view.contentOffset,
      distance: distance)
  }
  
  private func distanceToLeftAlignedItem() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    var distance = to.frame.origin.x - view.contentOffset.x
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if upcomingPagingItem > state.currentPagingItem {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          let fromDiff = from.frame.width - fromWidth
          distance -= fromDiff
        }
      }
    }
    return distance
  }
  
  private func distanceToRightAlignedItem() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    let currentPosition = to.frame.origin.x + to.frame.width
    let width = view.contentOffset.x + view.bounds.width
    var distance = currentPosition - width
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if upcomingPagingItem < state.currentPagingItem {
          let toDiff = toWidth - to.frame.width
          distance += toDiff
        } else {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          let fromDiff = from.frame.width - fromWidth
          let toDiff = toWidth - to.frame.width
          distance -= fromDiff
          distance += toDiff
        }
      } else {
        distance += toWidth - to.frame.width
      }
    }
    
    return distance
  }
  
  private func distanceToCenteredItem() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    var distance = to.frame.midX - view.bounds.midX
    
    if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
      let from = layoutAttributes[currentIndexPath] {
      
      let distanceToCenter = view.bounds.midX - from.frame.midX
      let distanceBetweenCells = to.frame.midX - from.frame.midX
      distance = distanceBetweenCells - distanceToCenter
      
      if sizeCache.implementsWidthDelegate {
        let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
        
        if upcomingPagingItem < state.currentPagingItem {
          distance = -(to.frame.width + (from.frame.midX - to.frame.maxX) - (toWidth / 2)) - distanceToCenter
        } else {
          let toDiff = (toWidth - to.frame.width) / 2
          distance = fromWidth + (to.frame.midX - from.frame.maxX) + toDiff - (from.frame.width / 2) - distanceToCenter
        }
      }
    } else if sizeCache.implementsWidthDelegate {
      let toDiff = toWidth - to.frame.width
      distance += toDiff / 2
    }
    
    return distance
  }
  
  private func createLayoutAttributes() {
    guard let state = state else { return }
    
    var layoutAttributes: [IndexPath: PagingCellLayoutAttributes] = [:]
    var previousFrame: CGRect = .zero
    previousFrame.origin.x = adjustedMenuInsets.left - options.menuItemSpacing
    
    for index in 0..<self.view.numberOfItems(inSection: 0) {
      
      let indexPath = IndexPath(item: index, section: 0)
      let attributes = PagingCellLayoutAttributes(forCellWith: indexPath)
      let x = previousFrame.maxX + options.menuItemSpacing
      let y = adjustedMenuInsets.top
      
      if sizeCache.implementsWidthDelegate {
        let pagingItem = dataStructure.pagingItemForIndexPath(indexPath)
        var width = sizeCache.itemWidth(for: pagingItem)
        let selectedWidth = sizeCache.itemWidthSelected(for: pagingItem)
        
        if state.currentPagingItem == pagingItem {
          width = tween(from: selectedWidth, to: width, progress: abs(state.progress))
        } else if state.upcomingPagingItem == pagingItem {
          width = tween(from: width, to: selectedWidth, progress: abs(state.progress))
        }
        
        attributes.frame = CGRect(x: x, y: y, width: width, height: options.menuHeight)
      } else {
        switch (options.menuItemSize) {
        case let .fixed(width, height):
          attributes.frame = CGRect(x: x, y: y, width: width, height: height)
        case let .sizeToFit(minWidth, height):
          attributes.frame = CGRect(x: x, y: y, width: minWidth, height: height)
        }
      }
      
      previousFrame = attributes.frame
      layoutAttributes[indexPath] = attributes
    }
    
    // When the menu items all can fit inside the bounds we need to
    // reposition the items based on the current options
    if previousFrame.maxX - adjustedMenuInsets.left < view.bounds.width {
      
      switch (options.menuItemSize) {
      case let .sizeToFit(_, height) where sizeCache.implementsWidthDelegate == false:
        let insets = adjustedMenuInsets.left + adjustedMenuInsets.right
        let spacing = (options.menuItemSpacing * CGFloat(range.upperBound - 1))
        let width = (view.bounds.width - insets - spacing) / CGFloat(range.upperBound)
        previousFrame = .zero
        previousFrame.origin.x = adjustedMenuInsets.left - options.menuItemSpacing
        
        for attributes in layoutAttributes.values.sorted(by: { $0.indexPath < $1.indexPath }) {
          let x = previousFrame.maxX + options.menuItemSpacing
          let y = adjustedMenuInsets.top
          attributes.frame = CGRect(x: x, y: y, width: width, height: height)
          previousFrame = attributes.frame
        }
        
      // When using sizeToFit the content will always be as wide as
      // the bounds so there is not possible to center the items. In
      // all the other cases we want to center them if the menu
      // alignment is set to .center
      default:
        if case .center = options.menuHorizontalAlignment {
          
          // Subtract the menu insets as they should not have an effect on
          // whether or not we should center the items.
          let offset = (view.bounds.width - previousFrame.maxX - adjustedMenuInsets.left) / 2
          for attributes in layoutAttributes.values {
            attributes.frame = attributes.frame.offsetBy(dx: offset, dy: 0)
          }
        }
      }
    }
    
    contentSize = CGSize(
      width: previousFrame.maxX + adjustedMenuInsets.right,
      height: view.bounds.height)
    
    self.layoutAttributes = layoutAttributes
  }
  
  private func updateBorderLayoutAttributes() {
    borderLayoutAttributes.update(
      contentSize: collectionViewContentSize,
      bounds: collectionView?.bounds ?? .zero,
      safeAreaInsets: safeAreaInsets)
  }
  
  private func updateIndicatorLayoutAttributes() {
    guard let state = state else { return }
    
    let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem)
    let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath)
    
    if let upcomingIndexPath = upcomingIndexPath {
      let progress = fabs(state.progress)
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(upcomingIndexPath.item),
        insets: indicatorInsetsForIndex(upcomingIndexPath.item),
        spacing: indicatorSpacingForIndex(upcomingIndexPath.item))
      
      if let currentIndexPath = currentIndexPath {
        let from = PagingIndicatorMetric(
          frame: indicatorFrameForIndex(currentIndexPath.item),
          insets: indicatorInsetsForIndex(currentIndexPath.item),
          spacing: indicatorSpacingForIndex(currentIndexPath.item))
        
        indicatorLayoutAttributes.update(from: from, to: to, progress: progress)
      } else if let from = indicatorMetricForFirstItem() {
        indicatorLayoutAttributes.update(from: from, to: to, progress: progress)
      } else if let from = indicatorMetricForLastItem() {
        indicatorLayoutAttributes.update(from: from, to: to, progress: progress)
      }
    } else if let metric = indicatorMetricForFirstItem() {
      indicatorLayoutAttributes.update(to: metric)
    } else if let metric = indicatorMetricForLastItem() {
      indicatorLayoutAttributes.update(to: metric)
    }
  }
  
  fileprivate func indicatorMetricForFirstItem() -> PagingIndicatorMetric? {
    guard let state = state else { return nil }
    if let first = dataStructure.sortedItems.first {
      if state.currentPagingItem < first {
        return PagingIndicatorMetric(
          frame: indicatorFrameForIndex(-1),
          insets: indicatorInsetsForIndex(-1),
          spacing: indicatorSpacingForIndex(-1))
      }
    }
    return nil
  }
  
  fileprivate func indicatorMetricForLastItem() -> PagingIndicatorMetric? {
    guard let state = state else { return nil }
    if let last = dataStructure.sortedItems.last {
      if state.currentPagingItem > last {
        return PagingIndicatorMetric(
          frame: indicatorFrameForIndex(dataStructure.visibleItems.count),
          insets: indicatorInsetsForIndex(dataStructure.visibleItems.count),
          spacing: indicatorSpacingForIndex(dataStructure.visibleItems.count))
      }
    }
    return nil
  }
  
  fileprivate func progressForItem(at indexPath: IndexPath) -> CGFloat {
    guard let state = state else { return 0 }
    
    let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem)
    
    if let currentIndexPath = currentIndexPath {
      if indexPath.item == currentIndexPath.item {
        return 1 - fabs(state.progress)
      }
    }
    
    if let upcomingIndexPath = upcomingIndexPathForIndexPath(currentIndexPath) {
      if indexPath.item == upcomingIndexPath.item {
        return fabs(state.progress)
      }
    }
    
    return 0
  }
  
  fileprivate func upcomingIndexPathForIndexPath(_ indexPath: IndexPath?) -> IndexPath? {
    guard let state = state else { return indexPath }
    
    if let upcomingPagingItem = state.upcomingPagingItem, let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem) {
      return upcomingIndexPath
    } else if let indexPath = indexPath {
      if indexPath.item == range.lowerBound {
        return IndexPath(item: indexPath.item - 1, section: 0)
      } else if indexPath.item == range.upperBound - 1 {
        return IndexPath(item: indexPath.item + 1, section: 0)
      }
    }
    return indexPath
  }
    
  fileprivate func indicatorSpacingForIndex(_ index: Int) -> UIEdgeInsets {
    if case let .visible(_, _, insets, _) = options.indicatorOptions {
      return insets
    }
    return UIEdgeInsets.zero
  }
  
  fileprivate func indicatorInsetsForIndex(_ index: Int) -> PagingIndicatorMetric.Inset {
    if case let .visible(_, _, _, insets) = options.indicatorOptions {
      if index == range.lowerBound {
        return .left(insets.left)
      } else if index >= range.upperBound - 1 {
        return .right(insets.right)
      }
    }
    return .none
  }
  
  fileprivate func indicatorFrameForIndex(_ index: Int) -> CGRect {
    if index < range.lowerBound {
      let frame = frameForIndex(0)
      return frame.offsetBy(dx: -frame.width, dy: 0)
    } else if index > range.upperBound - 1 {
      let frame = frameForIndex(dataStructure.visibleItems.count - 1)
      return frame.offsetBy(dx: frame.width, dy: 0)
    }
    
    return frameForIndex(index)
  }
  
  fileprivate func frameForIndex(_ index: Int) -> CGRect {
    guard let state = state else { return .zero }
    let currentIndexPath = IndexPath(item: index, section: 0)
    var frame = layoutAttributes[currentIndexPath]?.frame ?? .zero

    if sizeCache.implementsWidthDelegate {
      let indexPath = IndexPath(item: index, section: 0)
      let pagingItem = dataStructure.pagingItemForIndexPath(indexPath)

      if state.upcomingPagingItem == pagingItem || state.currentPagingItem == pagingItem  {
        frame.size.width = sizeCache.itemWidthSelected(for: pagingItem)
      }
    }

    return frame
  }
}
