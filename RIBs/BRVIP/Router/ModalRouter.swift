//
//  ModalRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import UIKit

open class ModalRouter<InteractorType, ViewControllerType, RouteType: RouteVariantProtocol>: ViewableRouter
<InteractorType, ViewControllerType, ModalTransition, RouteType>, ModalRouting {
  // MARK: - Overriden

  /// Метод необходимо переопределить при наследовании.
  /// Вызывать super.prepareTransition(for :) не нужно.
  open override func prepareTransition(for _: RouteType) -> ModalTransition {
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

  open override func close(animated: Bool = true, completion: RouteCompletion? = nil) {
    DispatchQueue.main.async { [weak self] in
      self?.perform(transition: .dismiss(toRoot: false, animated: animated), completion: completion)
    }
  }

  override func perform(transition: TransitionType, completion: RouteCompletion?) {
    switch transition {
    case let .present(router, animated):
      super.present(router, animated: animated, completion: completion)
    case let .dismiss(toRoot, animated):
      super.dismiss(toRoot: toRoot, animated: animated, completion: completion)
    case let .embed(router, container):
      super.embed(router, in: container, completion: completion)
    case let .unembed(router):
      super.unembed(router, completion: completion)
    case let .attachFlow(router):
      super.attachFlow(router)
    case .none:
      break
    }
  }
}

// MARK: - ModalTransition

public enum ModalTransition: RouterTransition {
  case present(any ModalRouting, animated: Bool = true)
  case dismiss(toRoot: Bool = false, animated: Bool = true)
  case embed(any EmbedRouting, in: any EmbedingContainer)
  case unembed(any EmbedRouting)
  case attachFlow(any FlowRouting)
  case none
}

// MARK: - ModalRouting

public protocol ModalRouting: ViewableRouting {}
