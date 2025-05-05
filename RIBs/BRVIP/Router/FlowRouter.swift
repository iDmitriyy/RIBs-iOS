//
//  FlowRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import UIKit

open class FlowRouter<InteractorType, ViewControllerType, RouteType: RouteVariantProtocol>: ViewableRouter
<InteractorType, ViewControllerType, FlowTransition, RouteType>, FlowRouting {
  // MARK: - Overriden

  open override func prepareTransition(for _: RouteType) -> FlowTransition {
    fatalError("Please override the \(#function) method.")
  }

  public override init(interactor: InteractorType, viewController: ViewControllerType) {
    super.init(interactor: interactor, viewController: viewController)
  }

  public override func close(animated _: Bool = true, completion _: RouteCompletion? = nil) {
    DispatchQueue.main.async { [weak self] in
      self?.detachFromParent()
    }
  }

  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
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
}

// MARK: - FlowTransition

public enum FlowTransition: RouterTransition {
  case present(any ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case attachFlow(any FlowRouting)
  case none
}

// MARK: - FlowRouting

public protocol FlowRouting: ViewableRouting {}
