//
//  AdaptyResult.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Result where Failure == AdaptyError {

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
