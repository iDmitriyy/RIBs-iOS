//
//  Routing+Helpers.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

import UIKit

extension Routing {
  /// корневой роутер дерева рибов
  var topRouter: any Routing {
    fatalError() // TODO: - .
//    parent?.topRouter ?? self
  }
  
  /// Возвращает иерархию RIB'ов в виде строки
  var hierarchyDebugDescription: String {
    var descriptionStrings = [String]()
    
    func traverseSubtree(root: any Routing) {
      if root.children.isEmpty {
        // выход из рекурсии
        descriptionStrings.append("\n>>>")
      } else {
        descriptionStrings.append("->")
        for child in root.children {
          // TODO: - interactable.debugDescription
//          descriptionStrings.append(child.interactable.debugDescription)
          traverseSubtree(root: child)
        }
      }
    }
    
    traverseSubtree(root: topRouter)
    
    return descriptionStrings.joined()
  }
  
  /// Поиск роутеров в дереве рибов
  /// - Parameter predicate: предикат поиска
  func findRouterInTree(predicate: (any Routing) -> (Bool)) -> (any Routing)? {
    findRoutersInSubtree(root: topRouter, predicate: predicate)
  }
  
  /// Поиск роутеров в поддереве
  /// - Parameters:
  ///   - root: корневой роутер поддерева (может совпадать с корневым роутром дерева в частном случае)
  ///   - predicate: предикат поиска
  func findRoutersInSubtree(root: any Routing, predicate: (any Routing) -> (Bool)) -> (any Routing)? {
    if predicate(root) { return root }
    
    for child in root.children {
      if let router = findRoutersInSubtree(root: child, predicate: predicate) {
        return router
      }
    }
    
    return nil
  }
  
  /// Поиск роутеров, ассоциированных с контроллерами в дереве рибов
  /// - Parameter viewControllers: контроллеры, на которые держат ссылки искомые роутеры
  func findRouters(for viewControllers: [UIViewController]) -> [any Routing] {
    viewControllers
      .map { viewController in
        findRouterInTree { router in
          if let viewableRouter = router as? any ViewableRouting {
            viewableRouter.viewControllable.uiviewController === viewController
          } else {
            false
          }
        }
      }
      .compactMap { $0 }
  }
  
  /// Поиск роутера, ассоциированного с контроллером в дереве рибов
  /// - Parameter viewController: контроллер, на который держит ссылку искомый роутер
  func findRouter(for viewController: UIViewController) -> (any Routing)? {
    findRouters(for: [viewController]).first
  }
  
  /// Возвращает все презентованные по цепочке контроллеры
  /// - Parameter presentingViewController: контроллер, с которого начинается цепочка
  func getPresentedControllersStack(for presentingViewController: UIViewController) -> [UIViewController] {
    var presentedControllers = [UIViewController]()
    
    func addPresentedViewController(from viewController: UIViewController) {
      if let presentedViewController = viewController.presentedViewController {
        presentedControllers.append(presentedViewController)
        addPresentedViewController(from: presentedViewController)
      } else {
        return
      }
    }
    
    addPresentedViewController(from: presentingViewController)
    
    return presentedControllers
  }
  
  /// Метод для детача self-роутера из родительского роутера
  func detachFromParent() {
    fatalError() // TODO: - .
//    parent?.detachChild(self)
  }
}
