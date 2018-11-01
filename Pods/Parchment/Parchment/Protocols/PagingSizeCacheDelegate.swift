import Foundation

protocol PagingSizeCacheDelegate: class {
  func pagingSizeCache<T>(
    _ pagingSizeCache: PagingSizeCache<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat?
}
