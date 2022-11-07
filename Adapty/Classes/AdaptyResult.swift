//
//  AdaptyResult.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public typealias AdaptyResult<Success> = Swift.Result<Success, AdaptyError>

public typealias ErrorCompletion = (AdaptyError?) -> Void
public typealias ResultCompletion<Success> = (AdaptyResult<Success>) -> Void

extension Result where Failure == AdaptyError {
    public var error: AdaptyError? {
        switch self {
        case let .failure(error): return error
        default: return nil
        }
    }
}

extension Result: Encodable where Success: Encodable, Failure == AdaptyError {
    enum CodingKeys: String, CodingKey {
        case success
        case error
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .success(value):
            try container.encode(value, forKey: .success)
        case let .failure(value):
            try container.encode(value, forKey: .error)
        }
    }
}
