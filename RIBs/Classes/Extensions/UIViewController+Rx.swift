//
//  UIViewController+Rx.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

public import struct RxCocoa.ControlEvent
public import class UIKit.UIViewController
import RxSwift
import UIKit

public protocol ViewControllerLifeCycleObservable: AnyObject {
  var viewDidLoadEvent: ControlEvent<Void> { get }
  var viewWillAppearEvent: ControlEvent<Void> { get }
  var viewDidAppearEvent: ControlEvent<Void> { get }
  var viewWillDisappearEvent: ControlEvent<Void> { get }
  var viewDidDisappearEvent: ControlEvent<Void> { get }
}

extension ViewControllerLifeCycleObservable where Self: UIViewController {
  /// Признак того, что ViewController виден. В основе лежат события viewWillAppear и viewWillDisappear
  public var isVisibleBasedOnWillEvents: ControlEvent<Bool> {
    var connectDisposable: (any Disposable)?

    let source = Observable.merge(viewWillAppearEvent.map { true }, viewWillDisappearEvent.map { false })
      .startWith(false)
      .distinctUntilChanged()
      .do(onDispose: {
        connectDisposable?.dispose()
      })
      .replay(1)
    // .share(replay: 1, scope: .forever) // Do not work
    // 📝 @iDmitriyy
    // iDmitriyy_TODO: - подумать как сделать HotObservable корректно. Подробно описать.
    // Подумать над другими местами.

    connectDisposable = source.connect()

    return ControlEvent(events: source)
  }
}

/// Скрываем детали реализации возможностей подписки на события жизненного цикла ViewController'a за интерфейсом.
/// Конформим UIViewController'у протокол ViewControllerLifeCycle и создаём дефолтную реализацию.
/// Наследники UIViewController могут переопределить любую проперти при необходимости.
///
/// За основу было взято решение:
/// https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Traits.md#controlproperty--controlevent
extension Reactive where Base: UIViewController {
  fileprivate var viewDidLoad: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    return ControlEvent(events: source)
  }

  fileprivate var viewWillAppear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewWillAppear)).map { _ in Void() }
    return ControlEvent(events: source)
  }

  fileprivate var viewDidAppear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidAppear)).map { _ in Void() }
    return ControlEvent(events: source)
  }

  fileprivate var viewWillDisappear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewWillDisappear)).map { _ in Void() }
    return ControlEvent(events: source)
  }

  fileprivate var viewDidDisappear: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidDisappear)).map { _ in Void() }
    return ControlEvent(events: source)
  }
}

// TODO: - .
//extension UIViewController: ViewControllerLifeCycleObservable {
//  public var viewDidLoadEvent: ControlEvent<Void> { rx.viewDidLoad }
//  public var viewWillAppearEvent: ControlEvent<Void> { rx.viewWillAppear }
//  public var viewDidAppearEvent: ControlEvent<Void> { rx.viewDidAppear }
//  public var viewWillDisappearEvent: ControlEvent<Void> { rx.viewWillDisappear }
//  public var viewDidDisappearEvent: ControlEvent<Void> { rx.viewDidDisappear }
//}
