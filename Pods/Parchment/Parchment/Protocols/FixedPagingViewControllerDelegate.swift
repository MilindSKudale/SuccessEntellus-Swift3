import Foundation

/// The `FixedPagingViewControllerDelegate` protocol defines methods
/// for when the user navigates to new view controllers.
public protocol FixedPagingViewControllerDelegate : class {
  
  /// Called before scrolling to a new view controller.
  ///
  /// - Parameter fixedPagingViewController: The
  /// `FixedPagingViewController` instance
  /// - Parameter willScrollToItem: The `ViewControllerItem` instance
  /// that will be scrolled to
  /// - Parameter index: The index of that view controller
  func fixedPagingViewController(
    fixedPagingViewController: FixedPagingViewController,
    willScrollToItem: ViewControllerItem,
    atIndex index: Int)
  
  /// Called after a transition has completed.
  ///
  /// - Parameter fixedPagingViewController: The
  /// `FixedPagingViewController` instance
  /// - Parameter didScrollToItem: The `ViewControllerItem` instance
  /// that has been scrolled to
  /// - Parameter index: The index of that view controller
  func fixedPagingViewController(
    fixedPagingViewController: FixedPagingViewController,
    didScrollToItem: ViewControllerItem,
    atIndex index: Int)
}
