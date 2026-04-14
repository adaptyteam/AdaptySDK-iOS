//
//  VC.Variable.MapConvertor+Executor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//

import Foundation
import JavaScriptCore

extension VC.Variable.MapConvertor {
    func readValue(_ jsValue: JSValue, in context: JSContext) throws(VS.Error) -> JSValue {
        guard let index32 = Int32.fromJSValue(jsValue) else {
            throw .convertorError("MapConvertor: expected a integer index")
        }

        let index = Int(index32)

        guard values.indices.contains(index) else {
            throw .convertorError("MapConvertor: index out of range")
        }

        return values[index].toJSValue(in: context)
    }

    func writeValue(_ newValue: some JSValueConvertable, in context: JSContext) throws(VS.Error) -> any JSValueConvertable {
        throw .convertorError("MapConvertor: ")
    }
}

