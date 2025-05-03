//
//  UINavigationController+RouterTransition.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import UIKit

/// workaround для установки completion в стандартные транзишены UINavigationController
/// https://stackoverflow.com/questions/12904410/completion-block-for-popviewcontroller

extension UINavigationController {
  internal func push(_ viewController: UIViewController,
                     animated: Bool,
                     completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      pushViewController(viewController, animated: animated)
    }
    
    CATransaction.commit()
  }
  
  internal func pop(toRoot: Bool,
                    animated: Bool,
                    completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      if toRoot {
        popToRootViewController(animated: animated)
      } else {
        popViewController(animated: animated)
      }
    }
    
    CATransaction.commit()
  }
  
  internal func pop(to viewController: UIViewController,
                    animated: Bool,
                    completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      _ = popToViewController(viewController, animated: animated)
    }
    
    CATransaction.commit()
  }
  
  internal func set(_ viewControllers: [UIViewController],
                    animated: Bool,
                    completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      setViewControllers(viewControllers, animated: animated)
    }
    
    CATransaction.commit()
  }
}
