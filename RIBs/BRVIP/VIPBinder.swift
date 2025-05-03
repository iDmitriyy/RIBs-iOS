//
//  VIPBinder.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

public import class UIKit.UIViewController

public protocol IOTransformer: AnyObject {
  associatedtype Input
  associatedtype Output
  
  func transform(input: Input) -> Output
}

public protocol BindableView: AnyObject {
  associatedtype Input
  associatedtype Output

  func getOutput() -> Output
  func bindWith(input: Input)
}

public struct VIPOutput<VOutput, IOutput, POutput> {
  public let viewOutput: VOutput
  public let interactorOutput: IOutput
  public let presenterOutput: POutput
}

public enum VIPBinder { // Namespace
  public typealias VIOutput<V, I> = (viewOutput: V, interactorOutput: I)
  
  /// Новый вариант биндинга, без принудительной загрузки вью. Название временное, поменять после рефакторинга.
  @discardableResult @MainActor
  public static func bind<V, I, P>(viewController: V, interactor: I, presenter: P) -> VIPOutput<V.Output, I.Output, P.Output>
    where V: BindableView, I: IOTransformer, P: IOTransformer,
    V.Output == I.Input, I.Output == P.Input, P.Output == V.Input {
    let viewOutput = viewController.getOutput()
    let interactorOutput = interactor.transform(input: viewOutput)
    let presenterOutput = presenter.transform(input: interactorOutput)
    viewController.bindWith(input: presenterOutput)

    return VIPOutput(viewOutput: viewOutput, interactorOutput: interactorOutput, presenterOutput: presenterOutput)
  }

  @discardableResult @MainActor
  public static func bindWithForcedViewLoading<V, I, P>(viewController: V, interactor: I, presenter: P)
    -> VIPOutput<V.Output, I.Output, P.Output>
    where V: BindableView & UIViewController, I: IOTransformer, P: IOTransformer,
    V.Output == I.Input, I.Output == P.Input, P.Output == V.Input {
    viewController.loadViewIfNeeded()
    let viewOutput = viewController.getOutput()
    let interactorOutput = interactor.transform(input: viewOutput)
    let presenterOutput = presenter.transform(input: interactorOutput)
    viewController.bindWith(input: presenterOutput)

    return VIPOutput(viewOutput: viewOutput, interactorOutput: interactorOutput, presenterOutput: presenterOutput)
  }

  /// Вариант биндинга, когда в модуле отсутствует Preseneter
  @discardableResult @MainActor
  public static func bind<V, I>(view: V, interactor: I) -> VIOutput<V.Output, I.Output>
  where V: UIViewController & BindableView, I: IOTransformer, V.Output == I.Input, I.Output == V.Input {
    let viewOutput = view.getOutput()
    let interactorOutput = interactor.transform(input: viewOutput)
    view.bindWith(input: interactorOutput)

    return (viewOutput: viewOutput, interactorOutput: interactorOutput)
  }
}
