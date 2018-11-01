import Foundation

class PagingSizeCache<T: PagingItem>  where T: Hashable, T: Comparable {
  
  var implementsWidthDelegate: Bool = false
  weak var delegate: PagingSizeCacheDelegate?
  
  private let options: PagingOptions
  private var widthCache: [T: CGFloat] = [:]
  private var selectedWidthCache: [T: CGFloat] = [:]
  
  init(options: PagingOptions) {
    self.options = options
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(applicationDidEnterBackground(notification:)),
      name: NSNotification.Name.UIApplicationDidEnterBackground,
      object: nil)
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(didReceiveMemoryWarning(notification:)),
      name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
      object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func clear() {
    self.widthCache =  [:]
    self.selectedWidthCache = [:]
  }
  
  func itemWidth(for pagingItem: T) -> CGFloat {
    if let width = widthCache[pagingItem] {
      return width
    } else {
      let width = delegate?.pagingSizeCache(self, widthForPagingItem: pagingItem, isSelected: false)
      widthCache[pagingItem] = width
      return width ?? options.estimatedItemWidth
    }
  }
  
  func itemWidthSelected(for pagingItem: T) -> CGFloat {
    if let width = selectedWidthCache[pagingItem] {
      return width
    } else {
      let width = delegate?.pagingSizeCache(self, widthForPagingItem: pagingItem, isSelected: true)
      selectedWidthCache[pagingItem] = width
      return width ?? options.estimatedItemWidth
    }
  }
  
  @objc private func didReceiveMemoryWarning(notification: NSNotification) {
    self.clear()
  }
  
  @objc private func applicationDidEnterBackground(notification: NSNotification) {
    self.clear()
  }
  
}
