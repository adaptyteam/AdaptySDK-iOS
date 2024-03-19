//
//  HTTPSession+logSystemEvent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

extension HTTPSession {
    @discardableResult
    final func perform<Request: HTTPRequestWithDecodableResponse>(
        _ request: Request,
        logName: String,
        logStamp: String = Log.stamp,
        logParams: EventParameters? = nil,
        _ completionHandler: @escaping (Request.Result) -> Void
    ) -> HTTPCancelable {
        Adapty.logSystemEvent(AdaptyBackendAPIRequestParameters(methodName: logName, callId: logStamp, params: logParams))
        return perform(request, logStamp: logStamp) { (result: Request.Result) in
            Adapty.logSystemEvent(AdaptyBackendAPIResponseParameters(methodName: logName, callId: logStamp, result))
            completionHandler(result)
        }
    }

    @discardableResult
    final func perform(
        _ request: some HTTPRequest,
        logName: String,
        logStamp: String = Log.stamp,
        logParams: EventParameters? = nil,
        _ completionHandler: @escaping (HTTPEmptyResponse.Result) -> Void
    ) -> HTTPCancelable {
        Adapty.logSystemEvent(AdaptyBackendAPIRequestParameters(methodName: logName, callId: logStamp, params: logParams))
        return perform(request, logStamp: logStamp) { (result: HTTPEmptyResponse.Result) in
            Adapty.logSystemEvent(AdaptyBackendAPIResponseParameters(methodName: logName, callId: logStamp, result))
            completionHandler(result)
        }
    }
}
