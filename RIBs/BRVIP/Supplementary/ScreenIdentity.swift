//
//  ScreenIdentity.swift
//  RIBs
//
//  Created by Dmitriy Ignatyev on 04.05.2025.
//

public import struct SwiftyKit.Empty

// Serizalization / Deserizalization

public protocol ScreenIdentity: Sendable, CustomStringConvertible { // ? Hashable
  /// Type of Router / Interactor at level of Type System
  associatedtype RIBType: Hashable, Sendable, CustomStringConvertible
  /// When the same RIB can logically be different screens, e.g. CatalogScreen when built can be configured as ProductsCatalog, PromoCatalog, GiftsCatalog...
  /// While tachnically it is the same RIB build from the same classes, from the Users and prodcut team perspective they are semantically diferent screens.
  associatedtype SubType = Empty
  /// e.g. ProductDetailsScreen – at runtime several instances of ProductDetailsScreen can exists in RIB tree, RuntimeSpecifier allows to differentiate betwen them.
  associatedtype RuntimeSpecifier = Empty
}

// struct ScreenIdentityKind {
//  static let root = ScreenIdentityKind()
// }
