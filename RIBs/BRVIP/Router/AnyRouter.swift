//
//  AnyRouter.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import Foundation

private class AbstractAnyRouter<RouteType: RouteProtocol>: Routable {
  func trigger(_ route: RouteType, completion: @escaping RouteCompletion) {
    fatalError("This method is abstract")
  }
  
  func trigger(_ route: RouteType) {
    fatalError("This method is abstract")
  }
}

private class AnyRouterWrapper<Base: Routable>: AbstractAnyRouter<Base.RouteType> {
  private let _base: Base
  
  init(_ base: Base) {
    _base = base
  }
  
  override func trigger(_ route: RouteType, completion: @escaping RouteCompletion) {
    _base.trigger(route, completion: completion)
  }
  
  override func trigger(_ route: RouteType) {
    _base.trigger(route)
  }
}

/// Type erasure-обертка для использования инстансов дженерик-протокола Routable
final class AnyRouter<RouteType: RouteProtocol>: Routable {
  private let _box: AbstractAnyRouter<RouteType>
  
  init<RoutableType: Routable>(_ routable: RoutableType) where RoutableType.RouteType == RouteType {
    _box = AnyRouterWrapper(routable)
  }
  
  func trigger(_ route: RouteType, completion: @escaping RouteCompletion) {
    _box.trigger(route, completion: completion)
  }
  
  func trigger(_ route: RouteType) {
    _box.trigger(route)
  }
}
