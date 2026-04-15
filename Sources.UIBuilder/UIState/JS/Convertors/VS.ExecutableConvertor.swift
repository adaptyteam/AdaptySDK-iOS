//
//  VC.Variable.Convertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//
import Foundation
import JavaScriptCore

extension VS {
    protocol ExecutableConvertor {
        func readValue(_: JSValue, in _: JSContext) throws(VS.Error) -> JSValue
        func writeValue(_: some JSValueConvertable, in _: JSContext) throws(VS.Error) -> any JSValueConvertable
    }
}

