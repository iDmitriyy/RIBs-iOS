//
//  RetainBag.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 04.05.2025.
//

/// Хранит сильные ссылки на объекты, которые должны иметь такое же время жизни как и RIB модуль, при этом нужно скрыть Тип
/// объекта.
/// Идея возникла, когда понадобилось хранить сильную ссылку на класс, занимающийся сбором статистики экрана.
public final class RetainBag {
  private var retainedObjects: [AnyObject] = []
  
  internal init() {}
  
  public func add(object: any AnyObject) {
    guard !retainedObjects.contains(where: { $0 === object }) else {
      return assertionFailure(error: ConditionalError(code: .valueCollision, info: ["object": "\(object)"]))
    }
    
    retainedObjects.append(object)
  }
}
