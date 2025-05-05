//
//  AnyRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import Foundation

private class AbstractAnyRouter<RouteVariant: RouteVariantProtocol>: Routable {
  func trigger(_: RouteVariant, completion _: @escaping RouteCompletion) {
    fatalError("This method is abstract")
  }
  
  func trigger(_: RouteVariant) {
    fatalError("This method is abstract")
  }
}

private class AnyRouterWrapper<Base: Routable>: AbstractAnyRouter<Base.RouteVariant> {
  private let _base: Base
  
  init(_ base: Base) {
    _base = base
  }
  
  override func trigger(_ route: RouteVariant, completion: @escaping RouteCompletion) {
    _base.trigger(route, completion: completion)
  }
  
  override func trigger(_ route: RouteVariant) {
    _base.trigger(route)
  }
}

/// Type erasure-обертка для использования инстансов дженерик-протокола Routable
final class AnyRouter<RouteVariant: RouteVariantProtocol>: Routable {
  private let _box: AbstractAnyRouter<RouteVariant>
  
  init<RoutableType: Routable>(_ routable: RoutableType) where RoutableType.RouteVariant == RouteVariant {
    _box = AnyRouterWrapper(routable)
  }
  
  func trigger(_ route: RouteVariant, completion: @escaping RouteCompletion) {
    _box.trigger(route, completion: completion)
  }
  
  func trigger(_ route: RouteVariant) {
    _box.trigger(route)
  }
}
