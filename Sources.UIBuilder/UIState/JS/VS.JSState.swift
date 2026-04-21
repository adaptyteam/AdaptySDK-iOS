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
        private let actionDispatcher: JSActionDispatcher
        init(
            name: String = "AdaptyJSState",
            configuration: AdaptyUIConfiguration,
            actionHandler: AdaptyUIActionHandler?,
            isInspectable: Bool
        ) {
            context = JSContext()!

            context.name = name
            if isInspectable, #available(iOS 16.4, macOS 13.3, *) {
                context.isInspectable = true
            }

            let exceptionHandler: @convention(block) (JSContext?, JSValue?) -> Void = { context, value in
                guard let value else {
                    Log.js.warn("JScript exception in context: \(String(describing: context))")
                    return
                }
                Log.js.warn("JScript exception: \(String(describing: value))")
            }
            context.exceptionHandler = exceptionHandler

            actionDispatcher = JSActionDispatcher(
                actionHandler,
                configuration
            )

            context.setObject(actionDispatcher, forKeyedSubscript: "SDK" as NSString)
        }
    }
}

extension VS.JSState {
    func setEnvironmentConstants(_ config: AdaptyUIConfiguration) {
        guard
            let global = context.globalObject,
            let env = config.environmentObject(in: context)
        else { return }

        let objectClass = context.objectForKeyedSubscript("Object")
        objectClass?.invokeMethod("freeze", withArguments: [env])

        #if DEBUG
        global.setObject(env, forKeyedSubscript: "SDKEnv" as NSString)
        #else
        if let objectClass, let descriptor = JSValue(newObjectIn: context) {
            descriptor.setObject(env, forKeyedSubscript: "value" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "writable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "configurable" as NSString)
            descriptor.setObject(false, forKeyedSubscript: "enumerable" as NSString)
            objectClass.invokeMethod("defineProperty", withArguments: [global, "SDKEnv", descriptor])
        }
        #endif
    }

    func evaluateScripts(
        _ scripts: [String]
    ) {
//        for script in scripts {
//            let a = context.evaluateScript(script)
//            print(a)
//            print("----")
//            print(debug(path: "", filter: .withFunctionName))
//        }

        let script = scripts.filter { !$0.isEmpty }.joined(separator: "\n")
        context.evaluateScript(script)
        objectWillChange.send()
    }

    private func findObject(
        path: [String],
        createIfNeeded: Bool = false
    ) throws(VS.Error) -> JSValue {
        guard var current = context.globalObject else {
            throw .jsGlobalObjectNotFound
        }
        guard !path.isEmpty else { return current }

        var index = 0

        while index < path.count {
            let component = path[index]
            guard let value = current.objectForKeyedSubscript(component) else {
                throw .jsObjectNotFound(path.joined(separator: "."))
            }
            guard !value.isUndefined else {
                print("not found \(component) index \(index)")
                break
            }
            guard value.isObject else {
                throw .jsObjectNotFound(path.joined(separator: "."))
            }
            current = value
            index += 1
        }

        guard index < path.count else { return current }
        guard createIfNeeded else {
            throw .jsObjectNotFound(path.joined(separator: "."))
        }

        while index < path.count {
            let component = path[index]
            print("create \(component) index \(index)")

            guard let empty = JSValue(newObjectIn: context) else {
                throw .jsObjectNotFound(path.joined(separator: "."))
            }
            current.setObject(empty, forKeyedSubscript: component as NSString)
            current = empty
            index += 1
        }

        return current
    }

    func getValue<T: JSValueRepresentable>(
        _: T.Type,
        variable: VC.Variable,
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) -> T? {
        let path = variable.pathWithScreenContext(screenInstance.contextPath)
        let name = path.last
        let parent = try findObject(path: path.dropLast())

        let result: JSValue

        if let name {
            guard let value = parent.objectForKeyedSubscript(name) else {
                throw .jsObjectNotFound(path.joined(separator: "."))
            }
            result = value
        } else {
            result = parent
        }

        log.debug("get variable \(path.joined(separator: ".")) = \(result)")

        guard let converter = variable.converter?.asDataBindingConverter else {
            return T.fromJSValue(result)
        }

        do {
            let converted = try converter.readValue(result, in: context)
            log.debug("convert to value: \(converted)")

            return T.fromJSValue(converted)
        } catch {
            log.error("convert \(path.joined(separator: ".")) = \(result) error: \(error) with \(converter)")
            throw error
        }
    }

    private func invokeMethod<T: JSValueRepresentable>(
        _: T.Type,
        path: [String],
        args functionArguments: [any JSValueConvertable] = []
    ) throws(VS.Error) -> T? {
        guard let name = path.last else { throw .jsPathToObjectIsEmpty }

        let parent = try findObject(path: path.dropLast())

        guard parent.hasProperty(name) else {
            throw .jsMethodNotFound(path.joined(separator: "."))
        }

        let value: JSValue? = parent.invokeMethod(
            name,
            withArguments: functionArguments.map { $0.toJSValue(in: context) }
        )

        if let value = T.fromJSValue(value) {
            log.debug(
                "method called \(path.joined(separator: ".")) -> \(String(describing: value))"
            )
            return value
        } else {
            log.debug("method called \(path.joined(separator: "."))")
            return nil
        }
    }

    private func invokeMethod<T: JSValueRepresentable>(
        _: T.Type,
        function: JSValue,
        args functionArguments: [any JSValueConvertable] = []
    ) throws(VS.Error) -> T? {
        let value: JSValue? = function.call(
            withArguments: functionArguments.map { $0.toJSValue(in: context) }
        )

        let name = function.forProperty("name")?.toString() ?? ""
        if let value = T.fromJSValue(value) {
            log.debug(
                "callback \(name) -> \(String(describing: value))"
            )
            return value
        } else {
            log.debug("callback \(name)")
            return nil
        }
    }

    func setValue(
        variable: VC.Variable,
        value: some JSValueConvertable,
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) {
        guard let convertor = variable.converter?.asDataBindingConverter else {
            try setValueWithoutConverter(variable: variable, value: value, screenInstance: screenInstance)
            return
        }

        let converted = try convertor.writeValue(value, in: context)
        log.debug("convert \(value) to: \(converted)")
        try setValueWithoutConverter(variable: variable, value: converted, screenInstance: screenInstance)
    }

    private func setValueWithoutConverter(
        variable: VC.Variable,
        value: some JSValueConvertable,
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) {
        let path = variable.pathWithScreenContext(screenInstance.contextPath)
        guard let name = path.last, path.count > 0 else { throw .jsPathToObjectIsEmpty }

        var setter = path
        setter[setter.count - 1] = variable.setter ?? ("set" + name.capitalizedFirst)

        do {
            let object = VS.SetterParameters(screenInstance: screenInstance, name: name, value: value)
            _ = try invokeMethod(Bool.self, path: setter, args: [object])
            objectWillChange.send()
            return
        } catch {
            switch error {
            case .jsMethodNotFound, .jsObjectNotFound:
                guard variable.setter == nil else {
                    log.warn("not found setter \(setter.joined(separator: "."))")
                    throw error
                }
            default:
                throw error
            }
        }

//        let before = self.debug(path: "", filter: .withoutFunction)
        let parent = try findObject(path: path.dropLast(), createIfNeeded: true)

        parent.setValue(value.toJSValue(in: context), forProperty: name as NSString)
//        let after = self.debug(path: "", filter: .withoutFunction)
        log.debug("set variable \(path.joined(separator: ".")) = \(value)")
        objectWillChange.send()
    }

    func execute(
        action: VS.JSAction,
        params: (some JSValueConvertable)?,
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) {
        let object = VS.ActionParameters(
            screenInstance: screenInstance,
            params: params
        )

        _ = try invokeMethod(
            Bool.self,
            function: action.callback,
            args: [object]
        )

        objectWillChange.send()
    }

    func execute(
        actions: [VC.Action],
        params: [String: any VC.Value]?,
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) {
        guard !actions.isEmpty else { return }

        for action in actions {
            guard !actionDispatcher.fastExecute(action) else { continue }

            var mergedParams = action.params ?? [:]

            if let params {
                for (key, value) in params {
                    mergedParams[key] = VC.AnyValue(value)
                }
            }

            let object = VS.ActionParameters(
                screenInstance: screenInstance,
                params: mergedParams
            )
            _ = try invokeMethod(
                Bool.self,
                path: action.pathWithScreenContext(screenInstance.contextPath),
                args: [object]
            )
        }

        objectWillChange.send()
    }
}

private extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}

// MARK: - Debug

extension VS.JSState {
    func debug(
        path: String,
        filter: VS.DebugFilter
    ) -> String {
        let path = if path.isEmpty { "globalThis" } else { path }

        let script =
            switch filter {
            case .withoutFunction:
                "JSON.stringify(\(path), null, 2)"
            case .withFunctionName:
                "JSON.stringify(\(path), (k, v) => typeof v === 'function' ? `function` : v , 2)"
            case .withFunctionCode:
                "JSON.stringify(\(path), (k, v) => typeof v === 'function' ? v.toString() : v , 2)"
            }

        let result = context.evaluateScript(script)
        return "\(path): \(result?.toString() ?? "unknown")"
    }

    func debug(
        variable: VC.Variable,
        screenInstance: VS.ScreenInstance?,
        filter: VS.DebugFilter
    ) -> String {
        let path: [String] =
            if let screenInstance {
                variable.pathWithScreenContext(screenInstance.contextPath)
            } else {
                variable.path
            }
        return debug(path: path.joined(separator: "."), filter: filter)
    }
}

