//
//  VC.Variable.DateTimeConvertor+Executor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation
import JavaScriptCore

extension VC.Variable.DateTimeConvertor: VS.ExecutableConvertor {
    func readValue(_ jsValue: JSValue, in context: JSContext) throws(VS.Error) -> JSValue {
        guard let unixtimestamp = Double.fromJSValue(jsValue) else {
            throw .convertorError("DateTimeConvertor: expected a numeric timestamp")
        }
        let value = Date(timeIntervalSince1970: unixtimestamp / 1000.0)
        switch self {
        case let .format(format):
            let formatter = DateFormatter()
            // TODO: use locale of UIConfiguration           formatter.locale
            formatter.dateFormat = format
            return formatter.string(from: value).toJSValue(in: context)

        case let .styles(date, time):
            let formatter = DateFormatter()
            // TODO: use locale of UIConfiguration            formatter.locale
            formatter.dateStyle = date
            formatter.timeStyle = time
            return formatter.string(from: value).toJSValue(in: context)
        }
    }

    func writeValue(_ newValue: some JSValueConvertable, in context: JSContext) throws(VS.Error) -> any JSValueConvertable {
        throw .convertorError("DateTimeConvertor: ")
    }
}

