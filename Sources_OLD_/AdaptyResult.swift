//
//  AdaptyResult.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public typealias AdaptyResult<Success> = Swift.Result<Success, AdaptyError>

public typealias AdaptyErrorCompletion = (AdaptyError?) -> Void
public typealias AdaptyResultCompletion<Success> = (AdaptyResult<Success>) -> Void

extension Result where Failure == AdaptyError {
    public var error: AdaptyError? {
        switch self {
        case let .failure(error): error
        default: nil
        }
    }

    @inlinable func `do`(_ call: (Success) -> Void) -> Self {
        guard case let .success(value) = self else { return self }
        call(value)
        return self
    }
}

extension Result {
    @inlinable func flatValue<NewSuccess>() -> Result<NewSuccess, Failure>? where Success == NewSuccess? {
        switch self {
        case let .failure(error):
            return .failure(error)
        case let .success(v):
            if let v {
                return .success(v)
            } else {
                return nil
            }
        }
    }
}
