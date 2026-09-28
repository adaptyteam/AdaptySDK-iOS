//
//  VC.DataBindingConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.04.2026.
//
import Foundation
import JavaScriptCore

protocol VSDataBindingConverter {
    func readValue(_: JSValue, in _: JSContext) throws(VS.Error) -> JSValue
    func writeValue(_: some JSValueConvertable, in _: JSContext) throws(VS.Error) -> any JSValueConvertable
}

extension VC.AnyConverter {
    var isDataBindingConverter: Bool {
        wrapped is VSDataBindingConverter
    }

    var asDataBindingConverter: VSDataBindingConverter? {
        wrapped as? VSDataBindingConverter
    }
}
