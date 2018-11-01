<p align="center">
  <img src="https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-header-4.png" width="270" height="110" />
</p>

<p align="center">
    <strong><a href="#usage">Usage</a></strong> |
    <strong><a href="#customization">Customization</a></strong> |
    <strong><a href="#installation">Installation</a></strong>
</p>

<p align="center">
  <a href="https://circleci.com/gh/rechsteiner/Parchment"><img src="https://circleci.com/gh/rechsteiner/Parchment/tree/master.svg?style=shield&circle-token=8e4da6c8bf09271f72f32bf3c7a7c9d743ff50fb" /></a>
  <a href="https://cocoapods.org/pods/Parchment"><img src="https://img.shields.io/cocoapods/v/Parchment.svg" /></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg" /></a>
</p>

<br/>

![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-contacts.gif "Contacts Example")
![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-unsplash.gif "Unsplash Example")
![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-calendar.gif "Calendar Example")
![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-delegate.gif "Cities Example")

## Features	

Parchment is a very flexible paging view controller. It let’s you page between view controllers while showing any type of generic indicator that scrolls along with the content. Some benefits of using Parchment:

* **Memory-efficient**: <br/> Parchment only allocates view controllers when they’re needed, meaning if you have a lot of view <br/> controllers you don’t have to initialize them all up-front.

* **Infinite scrolling**: <br /> Because view controllers are only allocated as you are scrolling, you can create data sources that are <br/> infinitely large. This is perfect for things like [calendars](#calendar-example).

* **Highly customizable** <br/> The menu items are built using
`UICollectionView`, which means you can display pretty much whatever you want. Check out the [`PagingOptions`]() protocol on how to customize the layout.

## Usage

The easiest way to use Parchment is using the `FixedPagingViewController`. Just
pass in an array of view controllers and it will set up everything for you.

```Swift
let firstViewController = UIViewController()
let secondViewController = UIViewController()

let pagingViewController = FixedPagingViewController(viewControllers: [
  firstViewController,
  secondViewController
])
```

Then add the paging view controller as a child view controller:

```Swift
addChildViewController(pagingViewController)
view.addSubview(pagingViewController.view)
pagingViewController.didMove(toParentViewController: self)
```

Parchment will then generate menu items for each view controller using their
`title` property. You can customize how the menu items will look, or even create
your completely custom subclass. See [Customization](#customization).

_Check out `ViewController.swift` in the `Example` target for more details._

## Custom Data Source

Parchment supports adding your own custom data sources. This allows you to
allocate view controllers only when they are needed, and can even be used to
create infinitely scrolling data sources ✨

To add your own data source, you need to conform to the
`PagingViewControllerDataSource` protocol:

```Swift
protocol PagingViewControllerDataSource: class {

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    viewControllerForPagingItem: T) -> UIViewController

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    pagingItemBeforePagingItem: T) -> T?

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    pagingItemAfterPagingItem: T) -> T?
}
```

If you've ever used
[UIPageViewController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPageViewControllerClassReferenceClassRef/)
this should seem familiar. The main difference is that instead of returning view
controllers directly, you return a object conforming to `PagingItem`.
`PagingItem` is used to generate menu items for all the view controllers,
without having to actually allocate them before they are needed.

### Calendar Example

Let’s take a look at an example of how you can create your own calendar data
source. This is what we want to achieve:

![](https://s3-us-west-1.amazonaws.com/parchment-swift/parchment-calendar.gif "Calendar Example")

First thing we need to do is create our own `PagingItem` that will hold our
date. We also need to make sure it conforms to both `Hashable` and `Comparable`:

```Swift
struct CalendarItem: PagingItem, Hashable, Comparable {
  let date: Date

  var hashValue: Int {
    return date.hashValue
  }
}

func ==(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
  return lhs.date == rhs.date
}

func <(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
  return lhs.date < rhs.date
}
```

We need to conform to `PagingViewControllerDataSource` in order to implement our
custom data source. Every time `pagingItemBeforePagingItem:` or
`pagingItemAfterPagingItem:` is called, we either subtract or append the time
interval equal to one day. This means our paging view controller will show one
menu item for each day.

```Swift
extension ViewController: PagingViewControllerDataSource {

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    viewControllerForPagingItem pagingItem: T) -> UIViewController {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarViewController(date: calendarItem.date)
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    pagingItemBeforePagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(-86400)) as? T
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    pagingItemAfterPagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarItem(date: calendarItem.date.addingTimeInterval(86400)) as? T
  }

}
```

Then we simply need to create our `PagingViewController` and specify our custom
`PagingItem`:

```Swift
let pagingViewController = PagingViewController<CalendarItem>()
pagingViewController.dataSource = self
```

That’s all you need to create your own infinitely paging calendar ✨🚀

_Check out the `CalendarExample` target for more details._

## Delegate

You can use the `PagingViewControllerDelegate` to manually control the width of
your menu items. Parchment does not support self-sizing cells at the moment, so
you have to use this if you have a custom cell that you want to size based on
its content.

```Swift
public protocol PagingViewControllerDelegate: class {
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat
}
```

_Check out `DelegateExample` to see how to create dynamically sized cells._

## Customization

Parchment is build to be very flexible. All customization is handled by the
`PagingOptions` protocol. Just create your own struct that conforms to this
protocol, and override the values you want.

```Swift
protocol PagingOptions {
  var menuItemSize: PagingMenuItemSize { get }
  var menuItemClass: PagingCell.Type { get }
  var menuItemSpacing: CGFloat { get }
  var menuInsets: UIEdgeInsets { get }
  var menuHorizontalAlignment: PagingMenuHorizontalAlignment { get }
  var menuTransition: PagingMenuTransition { get }
  var menuInteraction: PagingMenuInteraction { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
  var indicatorOptions: PagingIndicatorOptions { get }
  var indicatorClass: PagingIndicatorView.Type { get }
  var borderOptions: PagingBorderOptions { get }
  var borderClass: PagingBorderView.Type { get }
  var theme: PagingTheme { get }
}
```

If you have any requests for additional customizations, issues and pull-requests
are very much welcome 🙌.

#### `menuItemSize`

The size for each of the menu items.

```Swift
enum PagingMenuItemSize {
  case fixed(width: CGFloat, height: CGFloat)

  // Tries to fit all menu items inside the bounds of the screen.
  // If the items can't fit, the items will scroll as normal and
  // set the menu items width to `minWidth`.
  case sizeToFit(minWidth: CGFloat, height: CGFloat)
}
```

_Default: `.sizeToFit(minWidth: 150, height: 40)`_

#### `menuItemClass`

The class type for the menu item. Override this if you want your own custom menu
items.

_Default: `PagingTitleCell.self`_

#### `menuItemSpacing`

The spacing between the menu items.

_Default: `0`_

#### `menuInsets`

The insets around all of the menu items.

_Default: `UIEdgeInsets()`_

#### `menuHorizontalAlignment`

```Swift
enum PagingMenuHorizontalAlignment {
  case `default`

  // Allows all paging items to be centered within the paging menu
  // when PagingMenuItemSize is .Fixed and the sum of the widths
  // of all the paging items are less than the paging menu
  case center
}
```

_Default: `.default`_

#### `menuTransition`

Determine the transition behaviour of menu items while scrolling the content.

```Swift
enum PagingMenuTransition {
  // Update scroll offset based on how much the content has
  // scrolled. Makes the menu items transition smoothly as you scroll.
  case scrollAlongside

  // Animate the menu item position after a transition has completed.
  case animateAfter
}
```

_Default: .scrollAlongside_

#### `menuInteraction`

Determine how users can interact with the menu items.

```Swift
enum PagingMenuInteraction {
  case scrolling
  case swipe
  case none
}
```

_Default: .scrolling_

#### `selectedScrollPosition`

The scroll position of the selected menu item:

```Swift
enum PagingSelectedScrollPosition {
  case left
  case right

  // Centers the selected menu item where possible. If the item is
  // to the far left or right, it will not update the scroll position.
  // Effectivly the same as .centeredHorizontally on UIScrollView.
  case preferCentered
}
```

_Default: `.preferCentered`_

#### `indicatorOptions`

Add a indicator view to the selected menu item. The indicator width will be
equal to the selected menu items width. Insets only apply horizontally.

```Swift
enum PagingIndicatorOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    spacing: UIEdgeInsets,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 4,
  zIndex: Int.max,
  spacing: UIEdgeInsets.zero,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `indicatorClass`

The class type for the indicator view. Override this if you want your use your
own subclass of `PagingIndicatorView`.

_Default: `PagingIndicatorView.self`_

#### `borderOptions`

Add a border at the bottom of the menu items. The border will be as wide as all
the menu items. Insets only apply horizontally.

```Swift
enum PagingBorderOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 1,
  zIndex: Int.max - 1,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `borderClass`

The class type for the border view. Override this if you want your use your own
subclass of `PagingBorderView`.

_Default: `PagingBorderView.self`_

#### `includeSafeAreaInsets`

Updates the content inset for the menu items based on the `.safeAreaInsets`
property.

_Default: `true`_

#### `theme`

The visual theme of the paging view controller.

```Swift
protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var backgroundColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
  var borderColor: UIColor { get }
  var indicatorColor: UIColor { get }
}
```

_Default:_

```Swift
extension PagingTheme {

  var font: UIFont {
    return UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
  }

  var textColor: UIColor {
    return UIColor.black
  }

  var selectedTextColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }

  var backgroundColor: UIColor {
    return UIColor.white
  }

  var headerBackgroundColor: UIColor {
    return UIColor.white
  }

  var indicatorColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }

  var borderColor: UIColor {
    return UIColor(white: 0.9, alpha: 1)
  }

}
```

## Installation

Parchment will be compatible with the lastest public release of Swift.

### CocoaPods

Parchment is available through [CocoaPods](https://cocoapods.org). To install it, add the following to your `Podfile`:

`pod 'Parchment'`

### Carthage

Parchment also supports [Carthage](https://github.com/Carthage/Carthage). To install it, you need to do the following steps: 

1. Add `github "rechsteiner/Parchment"` to your `Cartfile`
2. Run `carthage update`
3. Link `Parchment.framework` with you target
4. Add `$(SRCROOT)/Carthage/Build/iOS/Parchment.framework` to your
   `copy-frameworks` script phase
   
See [this guide](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for more details on using Carthage.

## Requirements
* iOS 8.2+
* Xcode 8.0+

## Acknowledgements
* Parchment uses [`EMPageViewController`](https://github.com/emalyak/EMPageViewController) as a replacement for `UIPageViewController`.

## Author
* Martin Rechsteiner ([@rechsteiner]())

## Changelog
This can be found in the CHANGELOG file.
 
## Licence

Parchment is released under the MIT license. See LICENSE for details.