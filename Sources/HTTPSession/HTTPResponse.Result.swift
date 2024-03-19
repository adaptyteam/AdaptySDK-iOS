//
//  HTTPResponse.Result.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

extension HTTPResponse {
    typealias Result = Swift.Result<Self, HTTPError>
}

extension Result where Failure == HTTPError {
    var value: Success? {
        switch self {
        case let .success(v): v
        default: nil
        }
    }

    var error: HTTPError? {
        switch self {
        case let .failure(e): e
        default: nil
        }
    }
}
