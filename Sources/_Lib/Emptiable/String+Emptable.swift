//
//  String+Emptable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.07.2025.
//

extension StringProtocol {
    @inlinable
    var nonEmptyOrNil: Self? { isEmpty ? nil : self }
    @inlinable
    var isNotEmpty: Bool { !isEmpty }
}

extension Optional where Wrapped: StringProtocol {
    @inlinable
    var nonEmptyOrNil: Self { self?.nonEmptyOrNil }
    @inlinable
    var isEmpty: Bool { self?.isEmpty ?? true }
    @inlinable
    var isNotEmpty: Bool { !isEmpty }
    var trimmed: String? { self?.trimmed }
}

extension StringProtocol {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
