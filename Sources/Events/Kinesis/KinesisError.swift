//
//  KinesisError.swift
//  Adapty
//
//  Created by Aleksei Valiano on 10.10.2022.
//

import Foundation

enum KinesisError: Error {
    case missingСredentials(AdaptyError.Source)
    case requestWithoutURL(AdaptyError.Source)
    case requestWithoutHTTPMethod(AdaptyError.Source)
    case urlWithoutHost(AdaptyError.Source)
}

extension KinesisError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .missingСredentials(source):
            return "KinesisError.missingСredentials(\(source))"
        case let .requestWithoutURL(source):
            return "KinesisError.requestWithoutURL(\(source))"
        case let .requestWithoutHTTPMethod(source):
            return "KinesisError.requestWithoutHTTPMethod(\(source))"
        case let .urlWithoutHost(source):
            return "KinesisError.urlWithoutHost(\(source))"
        }
    }
}

extension KinesisError {
    var source: AdaptyError.Source {
        switch self {
        case let .missingСredentials(src),
             let .requestWithoutURL(src),
             let .requestWithoutHTTPMethod(src),
             let .urlWithoutHost(src):
            return src
        }
    }
}

extension KinesisError {
    static func missingСredentials(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .missingСredentials(AdaptyError.Source(file: file,
                                               function: function,
                                               line: line))
    }

    static func requestWithoutURL(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .requestWithoutURL(AdaptyError.Source(file: file,
                                              function: function,
                                              line: line))
    }

    static func requestWithoutHTTPMethod(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .requestWithoutHTTPMethod(AdaptyError.Source(file: file,
                                                     function: function,
                                                     line: line))
    }

    static func urlWithoutHost(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .urlWithoutHost(AdaptyError.Source(file: file,
                                           function: function,
                                           line: line))
    }
}
