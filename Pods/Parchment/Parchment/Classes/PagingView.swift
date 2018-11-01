import UIKit

/// A custom `UIView` subclass used by `PagingViewController`,
/// responsible for setting up the view hierarchy and its layout
/// constraints.
///
/// If you need additional customization, like changing the
/// constraints, you can subclass `PagingView` and override
/// `loadView:` in `PagingViewController` to use your subclass.
open class PagingView: UIView {
  
  open let pageView: UIView
  open let collectionView: UICollectionView
  open let options: PagingOptions
  
  /// Creates an instance of `PagingView`.
  ///
  /// - Parameter pageView: The view assosicated with the
  /// `EMPageViewController`.
  /// - Parameter collectionView: The collection view used to display
  /// the menu items.
  /// - Parameter options: The `PagingOptions` passed into the
  /// `PagingViewController`.
  public init(pageView: UIView, collectionView: UICollectionView, options: PagingOptions) {
    self.pageView = pageView
    self.collectionView = collectionView
    self.options = options
    super.init(frame: .zero)
    configure()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Configures the view hierarchy, sets up the layout constraints
  /// and does any other customization based on the `PagingOptions`.
  /// Override this if you need any custom behavior.
  open func configure() {
    collectionView.backgroundColor = options.theme.headerBackgroundColor
    addSubview(pageView)
    addSubview(collectionView)
    setupConstraints()
  }
  
  /// Sets up all the layout constraints. Override this if you need to
  /// make changes to how the views are layed out.
  open func setupConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pageView.translatesAutoresizingMaskIntoConstraints = false
    
    let metrics = [
      "height": options.menuHeight]
    
    let views = [
      "collectionView": collectionView,
      "pageView": pageView]
    
    let horizontalCollectionViewContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[collectionView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    let horizontalPagingContentViewContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[pageView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    let verticalContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|[collectionView(==height)][pageView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    addConstraints(horizontalCollectionViewContraints)
    addConstraints(horizontalPagingContentViewContraints)
    addConstraints(verticalContraints)
  }
  
}
