//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
public import class UIKit.UIWindow

/// The root `Router` of an application.
@MainActor public protocol LaunchRouting: ViewableRouting {
  /// Launches the router tree.
  ///
  /// - parameter window: The application window to launch from.
  func launch(from window: UIWindow)
}

/// Тип роутера для старта приложения. Предполагается использование одного экземпляра такого типа на всё приложение
open class LaunchRouter<InteractorType, ViewControllerType, RouteType: RouteProtocol>: ViewableRouter
<InteractorType, ViewControllerType, LaunchTransition, RouteType> {
  private var window: UIWindow?
  
  // MARK: - Public
  
  public final func launch(from window: UIWindow) {
    self.window = window
    
    window.rootViewController = viewControllable.uiviewController
    window.makeKeyAndVisible()
    
    interactable.activate()
    load()
  }
  
  // MARK: - Overriden
  
  open override func prepareTransition(for _: RouteType) -> LaunchTransition {
    fatalError("Please override the \(#function) method.")
  }
  
  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }
  
  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case let .setAsRoot(router):
      detachAllChildren()
      
      attachChild(router)
      
      window?.rootViewController = router.viewControllable.uiviewController
      window?.makeKeyAndVisible()
      
      completion?()
    // TODO: - .
//      interactable.routed(to: router)
    case .reset:
      detachAllChildren()
      window?.rootViewController = viewControllable.uiviewController
      window?.makeKeyAndVisible()
      completion?()
    case let .present(router, animated):
      super.present(router, animated: animated, completion: completion)
    case let .dismiss(toRoot, animated):
      super.dismiss(toRoot: toRoot, animated: animated, completion: completion)
    case let .embed(router, container):
      super.embed(router, in: container, completion: completion)
    case let .unembed(router):
      super.unembed(router, completion: completion)
    case .none:
      break
    }
  }
}

// MARK: - LaunchTransition

public enum LaunchTransition: RouterTransition {
  case setAsRoot(any ViewableRouting)
  case reset
  
  // common
  case present(any ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case embed(any EmbedRouting, in: any EmbedingContainer)
  case unembed(any EmbedRouting)
  case none
}

///// The application root router base class, that acts as the root of the router tree.
// open class LaunchRouter<InteractorType, ViewControllerType>: ViewableRouter<InteractorType, ViewControllerType>, LaunchRouting {
//  /// Initializer.
//  ///
//  /// - parameter interactor: The corresponding `Interactor` of this `Router`.
//  /// - parameter viewController: The corresponding `ViewController` of this `Router`.
//  public override init(interactor: InteractorType, viewController: ViewControllerType) {
//    super.init(interactor: interactor, viewController: viewController)
//  }
//
//  /// Launches the router tree.
//  ///
//  /// - parameter window: The window to launch the router tree in.
//  public final func launch(from window: UIWindow) {
//    window.rootViewController = viewControllable.uiviewController
//    window.makeKeyAndVisible()
//
//    interactable.activate()
//    load()
//  }
// }
