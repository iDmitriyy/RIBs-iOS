//
//  LoyaltyUserInfoProtocols.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 05.05.2025.
//

import Observation

protocol BindableSUIView {
  
}

struct LoyaltyCardFormViewOutput {
  
}

struct LoyaltyCardFormPresenterOutput {
  
}

struct LoyaltyCardFormInteractorOutput {
  
}

struct LoyaltyCardFormDataModel {
  var firstName: String
  var lastName: String
  var isSubscriptionConsent: Bool
}

@MainActor @Observable
final class TestScreenDataModel {
  var firstName: String = "" {
    didSet {
      print("nameText: \(nameText)")
      if nameText.count > 3 {
        nameText = "" // no updates in ui
      }
    }
  }
  
  var lastName: String = ""
  
  var isSubscriptionConsent: Bool
  
  init() {
    Task {
      try? await Task.sleep(for: .seconds(10))
      nameText = "_"
    }
  }
  
  func test() {}
}

struct LoyaltyCardUserInfo {
  let firstName: String
  let lastName: String
//  let birthDate: CalendarDay
//  let email: Email?
  let isSubscriptionConsent: Bool
}

//public struct CalendarDay: Hashable, CustomStringConvertible, Sendable {
//  public let year: Int
//  public let month: Int
//  public let day: Int
//  
//  public var description: String {
//    "year: \(year) month: \(month) day: \(day)"
//  }
//  
//  public init(year: Int,
//              month: Int,
//              day: Int,
//              file: StaticString = #fileID,
//              line: UInt = #line) throws {
//    guard 1...12 ~= month, 1...31 ~= day else {
//      let debugMessage = "month: \(month), day: \(day)"
//      throw MappingError(errorCode: .formatLogicalControl,
//                         localizedMessage: "Ошибка создания CalendarDay",
//                         debugMessage: debugMessage,
//                         file: file,
//                         line: line)
//    }
//    self.year = year
//    self.month = month
//    self.day = day
//  }
//}
