//
//  Tracing.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

public struct Tracing: Sendable {
  private let logError_: @Sendable (any Error, _ file: StaticString, _ line: UInt) -> Void
  private let assertError_: @Sendable (any Error, _ file: StaticString, _ line: UInt) -> Void
  private let leakDetected_: @Sendable () -> Void
  
  init(logError: @Sendable @escaping (any Error, _ file: StaticString, _ line: UInt) -> Void,
       assertError: @Sendable @escaping (any Error, _ file: StaticString, _ line: UInt) -> Void,
       leakDetected: @Sendable @escaping () -> Void) {
    logError_ = logError
    assertError_ = assertError
    leakDetected_ = leakDetected
    // +
    // leakDetected
  }
  
  internal func assertionFailure(error: any Error, file: StaticString = #file, line: UInt = #line) {
    assertError_(error, file, line)
  }
  
  internal func assertError(_ condition: Bool, _ error: any Error, file: StaticString = #file, line: UInt = #line) {
    if !condition { assertError_(error, file, line) }
  }
  
  internal func logError(_ error: any Error, file: StaticString = #file, line: UInt = #line) {
    logError_(error, file, line)
  }
}

import os

internal var tracing: Tracing { fatalError() }

internal let _tracing = OSAllocatedUnfairLock(initialState: Tracing(logError: { _, _, _ in },
                                                                    assertError: { _, _, _ in },
                                                                    leakDetected: {}))

import struct SwiftyKit.StaticFileLine

internal struct TextError: Error, CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String { text }
  public var debugDescription: String { text }
  
  package let text: String
  package let source: StaticFileLine
  
  public init(text: String, source: StaticFileLine = .this()) {
    self.text = text
    self.source = source
  }
}

//@_spi(SwiftyKitBuiltinTypes) import SwiftyKit
//
//internal typealias TextError = SwiftyKit.TextError

//struct TextError {
//  
//}
