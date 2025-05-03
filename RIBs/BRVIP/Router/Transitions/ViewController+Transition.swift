//
//  UIViewController+Transition.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

public import class UIKit.UIViewController
import UIKit

extension UIViewController {
  /// Самый верхний в стеке презентованных контроллер
  internal var topPresentedViewController: UIViewController {
    presentedViewController?.topPresentedViewController ?? self
  }
  
  internal func present(onRoot: Bool,
                        _ viewController: UIViewController,
                        animated: Bool,
                        completion: RouteCompletion?) {
    let presentingViewController = onRoot ? self : topPresentedViewController
    presentingViewController.present(viewController, animated: animated, completion: completion)
  }
  
  internal func dismiss(toRoot: Bool,
                        animated: Bool,
                        completion: RouteCompletion?) {
    let dismissalViewController = toRoot ? self : topPresentedViewController
    dismissalViewController.dismiss(animated: animated, completion: completion)
  }
}

extension UIViewController {
  /// Метод чтобы родитель умел embed'ить дочерний экран.
  public func embed(childViewController: UIViewController,
                    in container: some EmbedingContainer,
                    completion: RouteCompletion?) {
    let containerViewController: UIViewController = container.viewController
    containerViewController.addChild(childViewController)
    
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    
    guard let containerView = container.view else {
      let text = "Unexpected nil value for container.view, container Type \(type(of: container)), vc Type \(Self.self)"
      tracing.assertionFailure(error: TextError(text: text))
      return
    }
    
    containerView.addStretchedToBounds(subview: childViewController.view)
    
    childViewController.didMove(toParent: containerViewController)
    
    completion?()
  }
  
  /// Метод, чтобы дочерний экран умел удаляться из родительского
  public func unembedFromParent(completion: RouteCompletion?) {
    guard parent != nil else {
      tracing.assertionFailure(error: TextError(text: "Unexpected non-nil value for self.parent, vc Type \(Self.self)"))
      return
    }
    
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
    completion?()
  }
}

extension UIView {
  /// Привязывает 4 стороны subview к self.
  /// left / right являются константами для leading / trailing constraint'ов.
  internal func addStretchedToBounds(subview: UIView, insets: UIEdgeInsets = .zero) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    addSubview(subview)

    let constraints: [NSLayoutConstraint] = [
      subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
      bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom),
    ]

    NSLayoutConstraint.activate(constraints)
  }
}
