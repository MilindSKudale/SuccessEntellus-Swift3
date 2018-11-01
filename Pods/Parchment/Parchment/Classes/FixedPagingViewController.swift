import UIKit

/// A subclass of `PagingViewController` that can be used when you
/// have a fixed array of view controllers. It will setup a data
/// source for all the view controllers and display the menu items
/// with the view controllers title.
///
/// Using this class requires you to allocate all the view controllers
/// up-front, which in some cases might be to expensive. If that is
/// the case, take a look at `PagingViewController` on how to create
/// your own implementation that matches your needs.
open class FixedPagingViewController: PagingViewController<ViewControllerItem> {
  
  /// An array of `PagingItem`s that contains a reference to the view
  /// controller and title for that item. If you need to call
  /// `selectPagingItem:` you can read from this to get the item you
  /// want to select.
  open let items: [ViewControllerItem]
  open weak var itemDelegate: FixedPagingViewControllerDelegate?
  
  /// Creates an instance of `FixedPagingViewController`. By default,
  /// it will select the first view controller in the array. You can
  /// also call `selectPagingItem:` if you need select something else.
  ///
  /// - Parameter viewControllers: An array of view controllers
  /// - Parameter options: An instance used to customize how the
  /// paging view controller should look and behave.
  public init(viewControllers: [UIViewController], options: PagingOptions = DefaultPagingOptions()) {
    
    items = viewControllers.enumerated().map {
      ViewControllerItem(viewController: $1, index: $0)
    }
    
    super.init(options: options)
    dataSource = self
    
    if let item = items.first {
      selectPagingItem(item)
    }
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: EMPageViewControllerDelegate
  
  open override func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    super.em_pageViewController(pageViewController, didFinishScrollingFrom: startingViewController, destinationViewController: destinationViewController, transitionSuccessful: transitionSuccessful)
    
    if transitionSuccessful {
      if let index = items.index(where: { $0.viewController == destinationViewController }) {
        itemDelegate?.fixedPagingViewController(
          fixedPagingViewController: self,
          didScrollToItem: items[index],
          atIndex: index)
      }
    }
  }
  
  open override func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
    if let index = items.index(where: { $0.viewController == destinationViewController }) {
      itemDelegate?.fixedPagingViewController(
        fixedPagingViewController: self,
        willScrollToItem: items[index],
        atIndex: index)
    }
  }
  
}

extension FixedPagingViewController: PagingViewControllerDataSource {
  
  public func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem pagingItem: T) -> UIViewController {
    let index = items.index(of: pagingItem as! ViewControllerItem)!
    return items[index].viewController
  }
  
  public func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T) -> T? {
    guard let index = items.index(of: pagingItem as! ViewControllerItem) else { return nil }
    if index > 0 {
      return items[index - 1] as? T
    }
    return nil
  }
  
  public func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T) -> T? {
    guard let index = items.index(of: pagingItem as! ViewControllerItem) else { return nil }
    if index < items.count - 1 {
      return items[index + 1] as? T
    }
    return nil
  }
  
}
