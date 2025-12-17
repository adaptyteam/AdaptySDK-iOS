//
//  VS.JSState.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation
import JavaScriptCore

private let log = Log.viewState

extension VS {
    final class JSState: ObservableObject {
        private let context: JSContext
        
        init(
            name: String = "AdaptyJSState",
            isInspectable: Bool = false,
            actionHandler: AdaptyUIActionHandler?
        ) {
            context = JSContext()!
            
            context.name = name
            if isInspectable, #available(iOS 16.4, *) {
                context.isInspectable = true
            }
            
            let exceptionHandler: @convention(block) (JSContext?, JSValue?) -> Void = { _, value in
                guard let value else { return }
                Log.js.warn("JScript exception: \(String(describing: value))")
            }
            context.exceptionHandler = exceptionHandler
            
            let bridge = JSActionDispatcher(actionHandler)
            
            context.setObject(bridge, forKeyedSubscript: "SDK" as NSString)
            
            context.evaluateScript(Self.legacyActions)
        }
    }
}

extension VS.JSState {
    func evaluateScripts(_ scripts: [String]) {
        scripts.forEach { context.evaluateScript($0) }
    }
        
    func getValue<T: JSValueRepresentable>(_ type: T.Type, _ key: String) throws(VS.Error) -> T? {
        guard let value = context.objectForKeyedSubscript(key) else {
            throw .jsVariableNotFound(key)
        }
        log.debug("get variable \(key) = \(value)")
        return T.fromJSValue(value)
    }
        
    func callFunction<T: JSValueRepresentable>(
        _ type: T.Type,
        _ functionName: String,
        args functionArguments: [any JSValueRepresentable] = []
    ) throws(VS.Error) -> T? {
        guard let function = context.objectForKeyedSubscript(functionName),
              !function.isUndefined
        else {
            throw .jsFunctionNotFound(functionName)
        }
            
        let value = function.call(
            withArguments: functionArguments.map { $0.toJSValue(in: context) }
        )!
            
        if value.isUndefined {
            log.debug("function called \(functionName)")
        } else {
            log.debug("function called \(functionName) -> \(String(describing: value))")
        }
        objectWillChange.send()
        return T.fromJSValue(value)
    }
        
    func setValue(_ key: String, _ value: any JSValueRepresentable) throws(VS.Error) {
        do {
            _ = try callFunction(Bool.self, "set" + key.capitalizedFirst, args: [value])
            return
        } catch {
            guard case .jsFunctionNotFound = error else { throw error }
        }
            
        context.setObject(value, forKeyedSubscript: key as NSString)
        log.debug("set variable \(key) = \(value)")
        objectWillChange.send()
    }
    
    func execute(actions: [VC.Action]) {}
}

private extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
