//
//  UITabBarController+Transition..swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

import UIKit

/// workaround для установки completion в стандартные транзишены UITabBarController
/// https://stackoverflow.com/questions/12904410/completion-block-for-popviewcontroller

extension UITabBarController {
  internal func set(_ viewControllers: [UIViewController],
                    selected: UIViewController?,
                    animated: Bool,
                    completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      setViewControllers(viewControllers, animated: animated)
      
      if let selectedVC = selected {
        selectedViewController = selectedVC
      }
    }
    
    CATransaction.commit()
  }
  
  internal func select(_ viewController: UIViewController,
                       completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      selectedViewController = viewController
    }
    
    CATransaction.commit()
  }
  
  internal func select(index: Int,
                       completion: RouteCompletion?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    
    autoreleasepool {
      selectedIndex = index
    }
    
    CATransaction.commit()
  }
}
