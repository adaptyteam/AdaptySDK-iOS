//
//  JS.Variable.IsEqualConvertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//
import Foundation
import JavaScriptCore

extension VC.Variable.IsEqualConvertor {
    func readValue(_ jsValue: JSValue, in context: JSContext) throws(VS.Error) -> JSValue {
        let rhs = value.toJSValue(in: context)
        let result = jsValue.isEqual(to: rhs)
        return result.toJSValue(in: context)
    }

    func writeValue(_ newValue: some JSValueConvertable, in context: JSContext) throws(VS.Error) -> any JSValueConvertable {
        let boolValue = newValue.toJSValue(in: context).toBool()
        guard !boolValue else { return value }
        if let falseValue { return falseValue }
        return Optional<VC.AnyValue>.none
    }
}
