//
//  Environment+WebKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2024
//

import Foundation

#if canImport(WebKit)
    import WebKit
#endif

private let log = Log.default

extension Environment.Device {
    @AdaptyActor
    private static var _userAgent: String??

    @AdaptyActor
    static var webUserAgent: String? {
        get async {
            if let result = _userAgent {
                return result
            }

            #if canImport(WebKit)
                let result = await WKWebView().value(forKey: "userAgent").flatMap { $0 as? String }
            #else
                let result = String?.none
            #endif

            _userAgent = .some(result)
            return result
        }
    }
}
