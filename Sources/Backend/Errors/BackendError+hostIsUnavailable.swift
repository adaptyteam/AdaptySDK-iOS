//
//  BackendError+hostIsUnavailable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.11.2025.
//

import Foundation

extension HTTPError {
    var isServerUnavailable: Bool {
        switch self {
        case .perform:
            false
        case .network(_, _, _, let error):
            error.isServerUnavailable
        case .decoding(_, _, let statusCode, _, _, _),
             .backend(_, _, let statusCode, _, _, _):
            switch statusCode {
            case 503, 520, 524, 526:
                true
            default:
                false
            }
        }
    }
}

extension Error {
    var isServerUnavailable: Bool {
        let nsError = self as NSError

        if nsError.domain == NSURLErrorDomain {
            let code = URLError.Code(rawValue: nsError.code)
            switch code {
            case .cannotFindHost, // DNS: ENOTFOUND/NXDOMAIN
                 .cannotConnectToHost, // ECONNREFUSED
                 .timedOut, // ETIMEDOUT,
//                 .networkConnectionLost, // ECONNRESET ??
                 .secureConnectionFailed: // TLS setup failed
                return true
            // SSL
            case URLError.Code(rawValue: -1202), // serverCertificateUntrusted
                 URLError.Code(rawValue: -1205): // serverCertificateHasExpired
                return true
            default:
                break
            }
        }

        if checkPosixErrorDomain(nsError) { return true }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
           checkPosixErrorDomain(underlying)
        {
            return true
        }

        return false

        func checkPosixErrorDomain(_ nsError: NSError) -> Bool {
            guard nsError.domain == NSPOSIXErrorDomain else { return false }
            switch Int32(nsError.code) {
            case ECONNREFUSED,
//               ECONNRESET,
//               ENETUNREACH,
                 EHOSTUNREACH,
                 ETIMEDOUT:
                return true
            default:
                return false
            }
        }
    }
}
