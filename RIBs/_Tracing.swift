//
//  Tracing.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 02.05.2025.
//

public struct Tracing: Sendable {
  private let logError_: @Sendable (any Error, _ file: StaticString, _ line: UInt) -> Void
  private let assertError_: @Sendable (any Error, _ file: StaticString, _ line: UInt) -> Void
  
  init(logError: @Sendable @escaping (any Error, _ file: StaticString, _ line: UInt) -> Void,
       assertError: @Sendable @escaping (any Error, _ file: StaticString, _ line: UInt) -> Void) {
    logError_ = logError
    assertError_ = assertError
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

internal let _tracing = OSAllocatedUnfairLock(initialState: Tracing(logError: { _, _, _ in },
                                                                    assertError: { _, _, _ in }))
