//
//  AdaptyResult.swift
//  Adapty
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
        case let .failure(error): return error
        default: return nil
        }
    }
}
