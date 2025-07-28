//
//  Emptiable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.07.2025.
//

protocol Emptiable {
    var isEmpty: Bool { get }
}

extension Emptiable {
    @inlinable
    var nonEmptyOrNil: Self? { isEmpty ? nil : self }
    @inlinable
    var isNotEmpty: Bool { !isEmpty }
}

extension Optional where Wrapped: Emptiable {
    var nonEmptyOrNil: Self { self?.nonEmptyOrNil }
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !isEmpty }
}
