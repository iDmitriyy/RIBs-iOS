//
//  NavigationRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

public import class UIKit.UINavigationController
import class UIKit.UIViewController
import class UIKit.UIWindow

open class RootNavigationRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, NavigationTransition, RouteType>, NavigationRouting {
  // MARK: - Public
  
  public var navigationController: UINavigationController? {
    let navController: UINavigationController?
    if let navigationController = viewController as? UINavigationController {
      navController = navigationController
    } else if let uiViewController = viewController as? UIViewController {
      if let navigationController = uiViewController.navigationController {
        navController = navigationController
      } else {
        let message: String =
          ["uiViewController.navigationController is nil in \(self) / \(viewController)",
           ", parent: \(String(describing: parent))\n\n"].joined()
        
        let errorInfo: ErrorInfo = ["message": message,
                                    "RIBs tree": "\(hierarchyDebugDescription)",
                                    "ViewControllers tree": "\(UIWindow.vcsHierarchyDebugDescription())"]
        logError(ConditionalError(code: .unexpectedNilValue, info: errorInfo))
        
        navController = nil
      }
    } else {
      let message: String =
        ["ViewControllerType is neither UINavigationController nor UIViewController in \(self) / \(viewController)",
         ", parent: \(String(describing: parent))\n\n"].joined()
      
      let errorInfo: ErrorInfo = ["message": message,
                                  "RIBs tree": "\(hierarchyDebugDescription)",
                                  "ViewControllers tree": "\(UIWindow.vcsHierarchyDebugDescription())"]
      logError(ConditionalError(code: .unexpectedNilValue, info: errorInfo))

      navController = nil
    }
    return navController
  }
  
  // MARK: - Overriden
  
  open override func prepareTransition(for _: RouteType) -> NavigationTransition {
    let message = "Please override the \(#function) method. in \(self)."
    #if DEBUG
      fatalError(message)
    #else
      let error = ConditionalError(code: .unexpectedCodeEntrance, debugMessage: message)
      assertionFailure(error: error)
      return .none
    #endif
  }
  
  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    // временное решение с опционалом, логируется сверху
    // сделать guard let navigationController = navigationController нельзя тк пораждает утечку,
    // лучше давать ему закрывать иерархию роутеров.
    // вью может выгружаться раньше чем нужно, поэтому время жизни роутера увеличено не будет,
    // тк когда мы открываем диплинк, или программно говорим приложению "нужно перезагрузится" мы рубим стек рибов под корень.
    // когда будем переделывать роутинг этот момент нужно пересмотреть!
    switch transition {
    case let .push(router, animated):
      attachChild(router)
      
      detachWhenClosed(child: router, disposedBy: disposeBag)
      
      navigationController?.push(router.viewControllable.uiviewController, animated: animated) { [weak self] in
        completion?()
        self?.interactable.routed(to: router)
      }
      
    case let .pop(kind, animated):
      let toRoot: Bool = switch kind {
      case .toRoot: true
      case .last: false
      }
      
      /// закрываем открытые в стеке модальные экраны
      navigationController?.view.window?.rootViewController?.dismiss(animated: animated, completion: nil)
      
      /// контроллеры, которые будут удалены из стека, в зависимости от того, до какой глубины происходит pop
      let droppedControllers: [UIViewController]
      if toRoot {
        droppedControllers = navigationController.map { Array($0.viewControllers.dropFirst()) } ?? []
      } else {
        droppedControllers = navigationController?.viewControllers.last.map { [$0] } ?? []
      }
      
      /// связанные с контроллерами для удаления роутеры
      let routersForDetach = findRouters(for: droppedControllers)
      
      navigationController?.pop(toRoot: toRoot, animated: animated) {
        routersForDetach.forEach { $0.detachFromParent() }
        completion?()
      }
      
    case let .popTo(router, animated):
      /// закрываем открытые в стеке модальные экраны
      navigationController?.view.window?.rootViewController?.dismiss(animated: animated, completion: nil)
      
      /// целевой контроллер, до которого происходит pop
      let targetController = router.viewControllable.uiviewController
      
      /// все контроллеры в стеке
      let controllersStack = navigationController?.viewControllers ?? []
      
      /// индекс следующего за целевым контроллером
      guard let nextToTargetControllerIndex: Int = controllersStack.firstIndex(of: targetController)?.advanced(by: 1) else { break }
      
      /// контроллеры, которые будут удалены из стека
      let droppedControllers = Array(controllersStack[nextToTargetControllerIndex...])
      
      /// связанные с контроллерами для удаления роутеры
      let routersForDetach = findRouters(for: droppedControllers)
      
      navigationController?.pop(to: targetController, animated: animated) {
        routersForDetach.forEach { $0.detachFromParent() }
        completion?()
      }
      
    case let .present(router, animated):
      present(router, animated: animated, completion: completion)
      
    case let .dismiss(kind, animated):
      let toRoot: Bool = switch kind {
      case .toRoot: true
      case .last: false
      }
      dismiss(toRoot: toRoot, animated: animated, completion: completion)
      
    case let .attachFlow(router):
      attachFlow(router)
      
    case let .embed(router, container):
      embed(router, in: container, completion: completion)
      
    case let .unembed(router):
      unembed(router, completion: completion)
      
    case .none:
      break
    }
  }
}

open class NavigationRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>:
  RootNavigationRouter<InteractorType, ViewControllerType, RouteType> {
  public override func close(animated: Bool = true, completion: RouteCompletion? = nil) {
    DispatchQueue.main.async { [weak self] in
      self?.perform(transition: .pop(.last, animated: animated), completion: completion)
    }
  }
}

open class NavigationControllerRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>:
  RootNavigationRouter<InteractorType, ViewControllerType, RouteType> {
  /// Be careful – it will replace entire navigation stack.
  public func setInitial(router firstChild: some NavigationRouting, animated: Bool, completion: RouteCompletion?) {
    /// закрываем открытые в стеке модальные экраны
    navigationController?.view.window?.rootViewController?.dismiss(animated: animated, completion: nil)
    
    detachAllChildren()
    
    attachChild(firstChild)
    detachWhenClosed(child: firstChild, disposedBy: disposeBag)
    
    navigationController?.set([firstChild.viewControllable.uiviewController], animated: animated, completion: completion)
  }
}

// MARK: - NavigationTransition

public enum NavigationTransition: RouterTransition {
  // 📝 @levkachev
  // TODO: - заменить ViewableRouting на NavigationRouting для применения ограничений
  // - нужны 2 разных роутера:
  // 1. для экранов которые лежат в Navigation стеке
  // 2. для самого NavigationController'а – case setChildren можнт быть только у него
  
  case push(any NavigationRouting, animated: Bool = true)
  /// toRoot: false  - вернет на предыдущий экран, toRoot: true -  вернет к началу
//  case pop(toRoot: Bool = false, animated: Bool = true)
  case pop(_ kind: PopKind, animated: Bool = true)
  case popTo(any NavigationRouting, animated: Bool = true)
  
  // common
  case present(any ModalRouting, animated: Bool = true)
//  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case dismiss(_ kind: DismissKind, animated: Bool = true)
  case attachFlow(any FlowRouting)
  
  // embed
  case embed(any ViewableRouting, in: any EmbedingContainer)
  case unembed(any EmbedRouting)
  
  // none
  case none
  
  public enum PopKind {
    case last
    case toRoot
  }
  
  public enum DismissKind {
    case last
    case toRoot
  }
}

// MARK: - NavigationRouting

public protocol NavigationRouting: ViewableRouting {
  var navigationController: UINavigationController? { get }
}
