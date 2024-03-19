//
//  HTTPCancelable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 14.09.2022.
//

import Foundation

protocol HTTPCancelable {
    func cancel()
}

extension HTTPSession {
    static let emptyCancelable: HTTPCancelable = EmptyCancelable()

    private struct EmptyCancelable: HTTPCancelable {
        func cancel() {}
    }
}

extension URLSessionDataTask: HTTPCancelable {}
