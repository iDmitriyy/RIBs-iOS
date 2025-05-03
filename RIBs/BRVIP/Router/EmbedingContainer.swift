//
//  EmbedingContainer.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 03.05.2025.
//

public import class UIKit.UIView
public import class UIKit.UIViewController
import class UIKit.UIResponder

/// Taken from XCoordinator

///
/// EmbedingContainer abstracts away from the difference of `UIView` and `UIViewController`
///
/// With the EmbedingContainer protocol, `UIView` and `UIViewController` objects can be used interchangeably,
/// e.g. when embedding containers into containers.
///
@MainActor
public protocol EmbedingContainer: AnyObject {
  /// The view of the EmbedingContainer.
  ///
  /// - Note:
  ///     It might not exist for a `UIViewController`.
  var view: UIView! { get }
  
  /// The viewController of the EmbedingContainer.
  ///
  /// - Note:
  ///     It might not exist for a `UIView`.
  var viewController: UIViewController! { get }
}

// MARK: - Extensions

extension UIViewController: EmbedingContainer {
  public var viewController: UIViewController! { self }
}

extension UIView: EmbedingContainer {
  public var viewController: UIViewController! { viewController(for: self) }

  public var view: UIView! { self }
}

extension UIView {
  private func viewController(for responder: UIResponder) -> UIViewController? {
    if let viewController = responder as? UIViewController {
      return viewController
    }

    if let nextResponser = responder.next {
      return viewController(for: nextResponser)
    }

    return nil
  }
}
