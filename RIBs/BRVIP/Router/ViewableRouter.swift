//
//  ViewableRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import RxSwift
public import protocol SafariServices.SFSafariViewControllerDelegate
import class SafariServices.SFSafariViewController
import UIKit

public typealias RouteCompletion = () -> Void

/// The base protocol for all routers that own their own view controllers.
public protocol ViewableRouting: Routing {
  // The following methods must be declared in the base protocol, since `Router` internally invokes these methods.
  // In order to unit test router with a mock child router, the mocked child router first needs to conform to the
  // custom subclass routing protocol, and also this base protocol to allow the `Router` implementation to execute
  // base class logic without error.
  
  /// The base view controllable associated with this `Router`.
  var viewControllable: any ViewControllable { get }
  
  func close()
  
  // ⚠️ @iDmitriyy
  // _TODO: - нужно пересмотреть этот метод / дизайн интерфейса. Кажется, что не любой роутер может иметь метод close()
  // Понятным образом могут закрыть себя экран из navigation стека, модалки.
  // FlowRouter может иметь метод close(), однако флоу рибы часто имеют конкретную логику, нужно иметь возможность
  // кастомизировать логику в конкретных флоу роутерах.
  // Не понятно, как это делать правильно для: TabBarRouter, NavigationControllerRouter, LaunchRouter, EmbedRouter.
  func close(animated: Bool, completion: RouteCompletion?)
  
  /// Открывает ссылку в SFSafariViewController, который отображается модально. При этом RIB модуль и полноценный роутинг
  /// не производится.
  func openSafariInsideApp(url: URL)
  
  /// Открывает ссылку в SFSafariViewController, который отображается модально. При этом RIB модуль и полноценный роутинг
  /// не производится.
  func openSafariInsideApp(url: URL,
                           animated: Bool,
                           completion: RouteCompletion?,
                           delegate: (any SFSafariViewControllerDelegate)?)
}

extension ViewableRouting {
  public func close() {
    close(animated: true, completion: nil)
  }
  
  public func openSafariInsideApp(url: URL) {
    openSafariInsideApp(url: url, animated: true, completion: nil, delegate: nil)
  }
}

// MARK: - RouterTransition

public protocol RouterTransition {}

// MARK: - TransitionPerformer

protocol TransitionPerformer: AnyObject {
  associatedtype TransitionType: RouterTransition
  
  func perform(transition: TransitionType, completion: RouteCompletion?)
}

// MARK: - RouteProtocol

public protocol RouteProtocol {}

// MARK: - Routable

public protocol Routable: AnyObject {
  associatedtype RouteType: RouteProtocol
  
  func trigger(_ route: RouteType, completion: @escaping RouteCompletion)
  
  func trigger(_ route: RouteType)
}

/// The base class of all routers that owns view controllers, representing application states.
///
/// A `Router` acts on inputs from its corresponding interactor, to manipulate application state and view state,
/// forming a tree of routers that drives the tree of view controllers. Router drives the lifecycle of its owned
/// interactor. `Router`s should always use helper builders to instantiate children `Router`s.
open class ViewableRouter<InteractorType, ViewControllerType, TransitionType: RouterTransition, RouteType: RouteProtocol>: Router
<InteractorType>, ViewableRouting, TransitionPerformer, Routable {
  // MARK: - Public
  
  /// The corresponding `ViewController` owned by this `Router`.
  public let viewController: ViewControllerType
  
  /// The base `ViewControllable` associated with this `Router`.
  public let viewControllable: any ViewControllable
  
  /// Initializer.
  ///
  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
  public init(interactor: InteractorType, viewController: ViewControllerType) {
    self.viewController = viewController
    
    guard let viewControllable = viewController as? any ViewControllable else {
      fatalError("\(viewController) should conform to \((any ViewControllable).self)")
    }
    self.viewControllable = viewControllable
    
    super.init(interactor: interactor)
  }
  
  open func prepareTransition(for route: RouteType) -> TransitionType {
    fatalError("Please override the \(#function) method.")
  }
  
  public func close(animated: Bool, completion: RouteCompletion?) {}
  
  public func openSafariInsideApp(url: URL,
                                  animated: Bool = true,
                                  completion: RouteCompletion? = nil,
                                  delegate: (any SFSafariViewControllerDelegate)? = nil) {
    DispatchQueue.main.async { [weak self] in
      guard UIApplication.shared.canOpenURL(url) else {
        return logError(AppLinkError(errorCode: .cantOpenURL, url: url))
      }
      
      let safari = SFSafariViewController(url: url)
      safari.delegate = delegate
      self?.viewControllable.uiviewController.present(safari, animated: animated, completion: completion)
    }
  }
  
  // MARK: - Routable
  
  public func trigger(_ route: RouteType, completion: @escaping RouteCompletion) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return assertionFailure(error: ConditionalError(code: .unexpectedCodeEntrance)) }
      
      let transition = self.prepareTransition(for: route)
      self.perform(transition: transition, completion: completion)
    }
  }
  
  public func trigger(_ route: RouteType) {
    trigger(route) {}
  }
  
  // MARK: - Overriden
  
  override func internalDidLoad() {
    super.internalDidLoad()
  }
  
  // MARK: - Internal
  
  let disposeBag = DisposeBag()
  
  func perform(transition: TransitionType, completion: RouteCompletion?) {
    fatalError("Please override the \(#function) method.")
  }
  
  func present(_ router: any ViewableRouting, animated: Bool, completion: RouteCompletion?) {
    attachChild(router)
    
    detachWhenClosed(child: router, disposedBy: disposeBag)
    
    viewControllable.uiviewController.present(onRoot: false,
                                              router.viewControllable.uiviewController,
                                              animated: animated,
                                              completion: completion)
  }
  
  func dismiss(toRoot: Bool, animated: Bool, completion: RouteCompletion?) {
    /// контроллеры, которые будут удалены из стека, в зависимости от того, до какой глубины происходит dismiss
    let dismissingViewControllers: [UIViewController] = if toRoot {
      getPresentedControllersStack(for: viewControllable.uiviewController)
    } else {
      [viewControllable.uiviewController.topPresentedViewController]
    }
    
    /// связанные с контроллерами для удаления роутеры
    let routersForDetach: [any Routing] = findRouters(for: dismissingViewControllers)
    
    viewControllable.uiviewController.dismiss(toRoot: toRoot, animated: animated) {
      routersForDetach.forEach { $0.detachFromParent() }
      completion?()
    }
  }
  
  func attachFlow(_ router: any FlowRouting) {
    attachChild(router)
  }
}

// MARK: - Embed (композиция экранов)

extension ViewableRouter {
  public func embed(_ router: any ViewableRouting, in container: any Container, completion: RouteCompletion?) {
    attachChild(router)
    
    // 📝 @iDmitriyy
    // TODO: - проверить, будет ли корректно отрабатывать метод detachWhenClosed для embed экранов
    detachWhenClosed(child: router, disposedBy: disposeBag)
    
    viewControllable.uiviewController.embed(childViewController: router.viewControllable.uiviewController,
                                            in: container,
                                            completion: completion)
  }
  
  public func unembed(_ router: any EmbedRouting, completion: RouteCompletion?) {
    router.viewControllable.uiviewController.unembedFromParent(completion: completion)
  }
}
