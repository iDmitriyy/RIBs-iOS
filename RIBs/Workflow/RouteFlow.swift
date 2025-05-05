//
//  RouteFlow.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 05.05.2025.
//

public final actor RouteFlow {
  public func didComplete() {
    // No-op
  }

  /// Called when the `Workflow` is forked.
  ///
  /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
  /// The default implementation does nothing.
  public func didFork() {
    // No-op
  }

  /// Called when the last step observable is has error.
  ///
  /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
  /// The default implementation does nothing.
  public func didReceiveError(_: any Error) {
    // No-op
  }
  
  struct Step {
    
  }
  
  func _start() async throws {
    
  }
}

protocol RouteFlowableInteractor: AnyObject {
//  associatedtype RouteStepInput
//  associatedtype RouteStepOutput
}

extension Task where Failure == any Error {
  /// Runs the given throwing operation asynchronously as part of a new top-level task on behalf of the current actor.
  /// If the timeout expires before the operation is completed then the task is cancelled and an error is thrown.
  init(priority: TaskPriority? = nil,
       timeout: TimeInterval,
       operation: @escaping @Sendable () async throws -> Success) {
    self = Task(priority: priority) {
      try await withThrowingTaskGroup(of: Success.self) { group -> Success in
        group.addTask(operation: operation)
        group.addTask {
          try await _Concurrency.Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
          throw TimeoutError()
        }
        guard let success = try await group.next() else {
          throw _Concurrency.CancellationError()
        }
        group.cancelAll()
        return success
      }
    }
  }
}

import Foundation

private struct TimeoutError: LocalizedError {
  var errorDescription: String? = "Task timed out before completion"
}

import RxSwift

protocol RootActionableItem: AnyObject {
  func openTabBar() -> Observable<(any TabBarContainerActionableItem, Void)>
  
  func openTabBar() throws -> any TabBarContainerActionableItem
}

// MARK: - TabBarContainer

protocol TabBarContainerActionableItem: AnyObject {
  func selectMainNavigation(promoCode: String?) -> Observable<(any MainNavigationActionableItem, Void)>
//  func openCatalogNavigation() -> Observable<(any CatalogNavigationActionableItem, Void)>
//  func openCartNavigation() -> Observable<(any CartNavigationActionableItem, Void)>
//  func openBonusesNavigation(promoCode: String?) -> Observable<(any BonusesNavigationActionableItem, Void)>
//  func openProfileNavigation() -> Observable<(any ProfileNavigationActionableItem, Void)>
//  func openExpressNavigation(promoCode: String?) -> Observable<(any ExpressNavigationActionableItem, Void)>
  /// Открывает главный экран, при этом отправляя на таб-баре запрос на подтверждение почты. Хэш получаем из universal-линка
//  func openMainNavigationAndConfirmEmail(hash: String) -> Observable<(any MainNavigationActionableItem, Void)>
  func openAddressList() -> Observable<(any TabBarContainerActionableItem, Void)>
  
  func selectMainNavigation(promoCode: String?) throws -> any MainNavigationActionableItem
  func openAddressList() throws -> any TabBarContainerActionableItem
}

protocol MainNavigationActionableItem: AnyObject {}

func test(root: sending any RootActionableItem) {
  Task { @MainActor in
    do {
      try root.openTabBar()
        .openAddressList()
      
      try root
        .openTabBar()
        .selectMainNavigation(promoCode: "NEWYear")
    } catch {
      
    }
  }
}
