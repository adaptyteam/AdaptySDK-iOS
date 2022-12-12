//
//  InternalAdaptyError.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation
import StoreKit

enum InternalAdaptyError: Error {
    case activateOnceError(AdaptyError.Source)
    case cantMakePayments(AdaptyError.Source)
    case notActivated(AdaptyError.Source)
    case profileWasChanged(AdaptyError.Source)
    case decodingFailed(AdaptyError.Source, String, error: Error)
    case wrongParam(AdaptyError.Source, String)
    case persistingDataError(AdaptyError.Source, String)

    case originalHTTPError(HTTPError)
    case originalEventsError(EventsError)
    case originalSKManagerError(SKManagerError)
}

extension InternalAdaptyError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .activateOnceError(source):
            return "AdaptyError.activateOnceError(\(source))"
        case let .cantMakePayments(source):
            return "AdaptyError.cantMakePayments(\(source))"
        case let .notActivated(source):
            return "AdaptyError.notActivated(\(source))"
        case let .profileWasChanged(source):
            return "AdaptyError.profileWasChanged(\(source))"
        case let .decodingFailed(source, description, error):
            return "AdaptyError.decodingFailed(\(source), \(description), \(error))"
        case let .wrongParam(source, description):
            return "AdaptyError.wrongParam(\(source), \(description))"
        case let .persistingDataError(source, description):
            return "AdaptyError.persistingDataError(\(source), \(description))"

        case let .originalHTTPError(error): return error.description
        case let .originalEventsError(error): return error.description
        case let .originalSKManagerError(error): return error.description
        }
    }
}

extension InternalAdaptyError {
    var source: AdaptyError.Source {
        switch self {
        case let .activateOnceError(src),
             let .cantMakePayments(src),
             let .notActivated(src),
             let .profileWasChanged(src),
             let .decodingFailed(src, _, _),
             let .wrongParam(src, _),
             let .persistingDataError(src, _):
            return src

        case let .originalHTTPError(error):
            return error.source
        case let .originalEventsError(error):
            return error.source
        case let .originalSKManagerError(error):
            return error.source
        }
    }

    var originalError: Error? {
        switch self {
        case let .decodingFailed(_, _, error):
            return error
        case let .originalHTTPError(error):
            return error
        case let .originalEventsError(error):
            return error
        case let .originalSKManagerError(error):
            return error
        default:
            return nil
        }
    }
}

extension InternalAdaptyError: CustomNSError {
    static let errorDomain = AdaptyError.AdaptyErrorDomain

    var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .activateOnceError: return AdaptyError.ErrorCode.activateOnceError
        case .cantMakePayments: return AdaptyError.ErrorCode.cantMakePayments
        case .notActivated: return AdaptyError.ErrorCode.notActivated
        case .profileWasChanged: return AdaptyError.ErrorCode.profileWasChanged
        case .decodingFailed: return AdaptyError.ErrorCode.decodingFailed
        case .wrongParam: return AdaptyError.ErrorCode.wrongParam
        case .persistingDataError: return AdaptyError.ErrorCode.persistingDataError

        case let .originalHTTPError(error): return error.adaptyErrorCode
        case let .originalEventsError(error): return error.adaptyErrorCode
        case let .originalSKManagerError(error): return error.adaptyErrorCode
        }
    }

    var errorCode: Int { adaptyErrorCode.rawValue }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
            AdaptyError.UserInfoKey.source: source.description
        ]

        if let originalError = originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }
}
