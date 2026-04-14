//
//  VC.Variable.Convertor.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//
import Foundation
import JavaScriptCore

extension VC.Variable.Converter {
    func readValue(_: JSValue, in _: JSContext) throws(VS.Error) -> JSValue {
        throw .notFoundConvertor(name)
    }

    func writeValue(_: some JSValueConvertable, in _: JSContext) throws(VS.Error) -> any JSValueConvertable {
        throw .notFoundConvertor(name)
    }
}

