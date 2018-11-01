import Foundation

/// The `PagingViewControllerDelegate` gives you the opportunity to
/// manually control the width of your menu items. Parchment does not
/// support self-sizing cells at the moment, so you have to use this
/// if you have a cell that you want to size based on its content.
public protocol PagingViewControllerDelegate: class {
  
  /// The width for a given `PagingItem`
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Parameter pagingItem: The `PagingItem` instance
  /// - Parameter isSelected: A boolean that indicates whether the
  /// given `PagingItem` is selected
  /// - Returns: The width for the `PagingItem`
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat
}
