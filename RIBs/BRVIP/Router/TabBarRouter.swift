//
//  TabBarRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import RxCocoa
import RxSwift
public import class UIKit.UITabBarController
import UIKit

open class TabBarRouter<InteractorType, ViewControllerType, RouteType: RouteVariantProtocol>: ViewableRouter
<InteractorType, ViewControllerType, TabBarTransition, RouteType>, TabBarRouting {
  // MARK: - Public
  
  public var tabBarController: UITabBarController {
    guard let tabBarController = viewControllable.uiviewController as? UITabBarController else {
      fatalError("Root controller for TabBarRouter need to be inherited from UITabBarController")
    }
    
    return tabBarController
  }
  
  // MARK: - Overriden
  
  open override func prepareTransition(for _: RouteType) -> TabBarTransition {
    fatalError("Please override the \(#function) method.")
  }
  
  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case let .setChildren(routers, selected, animated):
      findRouters(for: tabBarController.viewControllers ?? []).forEach { $0.detachFromParent() }
      
      routers.forEach {
        attachChild($0)
        detachWhenClosed(child: $0, disposedBy: disposeBag)
      }
      
      tabBarController.set(routers.map { $0.viewControllable.uiviewController },
                           selected: selected?.viewControllable.uiviewController,
                           animated: animated,
                           completion: completion)
    case .selectAt(let index):
      tabBarController.select(index: index, completion: completion)
    case .select(let router):
      tabBarController.select(router.viewControllable.uiviewController, completion: { [weak self] in
        completion?()
//        self?.interactable.routed(to: router) // TODO: - .
      })
    case let .present(router, animated):
      super.present(router, animated: animated, completion: completion)
    case let .dismiss(toRoot, animated):
      super.dismiss(toRoot: toRoot, animated: animated, completion: completion)
    case let .attachFlow(router):
      super.attachFlow(router)
    case .none:
      break
    }
  }
  
  /// ситуация: UINavigationController является рутовым во вкладке таббара, когда пользователь повторно нажимает на вкладку,
  /// в которой находится, автоматически вызывается popToRootViewController(:) у рутового UINavigationController
  /// код ниже автоматически детачит все дочерние роутеры при таком кейсе
  public func willSelect(viewController: UIViewController) {
    guard tabBarController.selectedViewController == viewController,
          let navigationController: UINavigationController = viewController as? UINavigationController,
          let first: UIViewController = navigationController.viewControllers.first else { return }
    findRouter(for: first)?.detachAllChildren()
  }
}

// MARK: - AsossiatedTypes

public enum TabBarTransition: RouterTransition {
  case setChildren(routers: [any ViewableRouting], selected: (any ViewableRouting)?, animated: Bool = true)
  case selectAt(index: Int)
  case select(any ViewableRouting)
  
  // common
  case present(any ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case attachFlow(any FlowRouting)
  case none
}

// MARK: - TabBarRouting

public protocol TabBarRouting: ViewableRouting {
  var tabBarController: UITabBarController { get }
}
