//
//  Router+Rx.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

public import class RxSwift.DisposeBag
import UIKit

// TODO: - .
extension Router {
  /// Метод для детача модуля из дерева RIB(ов), когда необходимо выполнить какие-то действия во время детача
  public func detachWhenClosed(child: some ViewableRouting,
                               disposedBy disposeBag: DisposeBag,
                               detachAction: (() -> Void)? = nil) {
    let vc = child.viewControllable.uiviewController
    vc.viewDidDisappearEvent.subscribe(onNext: { [weak self, weak child, weak vc] in
      /*
       (vc.isBeingDismissed || (vc.navigationController?.isBeingDismissed ?? false))
       необходимо для проверки что именно дисмиситься: UINavigationController или UIViewController
       */
      
      if let vc, let child,
        vc.isBeingDismissed
          || vc.navigationController?.isBeingDismissed ?? false
          || vc.isMovingFromParent
          || vc.navigationController?.isMovingFromParent ?? false {
        
        detachAction?()
        self?.detachChild(child)
      }
    }).disposed(by: disposeBag)
  }
}
