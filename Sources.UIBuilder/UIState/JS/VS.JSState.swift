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
                configuration)

            context.setObject(actionDispatcher, forKeyedSubscript: "SDK" as NSString)
        }
    }
}

extension VS.JSState {
    func evaluateScripts(
        _ scripts: [String]
    ) {
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

        guard index < path.count - 1 else { return current }
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
        _ type: T.Type,
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
        return T.fromJSValue(result)
    }

    private func invokeMethod<T: JSValueRepresentable>(
        _ type: T.Type,
        path: [String],
        args functionArguments: [any JSValueConvertable] = []
    ) throws(VS.Error) -> T? {
        guard let name = path.last, path.count > 0 else { throw .jsPathToObjectIsEmpty }

        let parent = try findObject(path: path.dropLast())

        guard parent.hasProperty(name) else {
            throw .jsMethodNotFound(path.joined(separator: "."))
        }
        let value: JSValue? = parent.invokeMethod(
            name,
            withArguments: functionArguments.map { $0.toJSValue(in: context) })

        if let value = T.fromJSValue(value) {
            log.debug(
                "method called \(path.joined(separator: ".")) -> \(String(describing: value))")
            return value
        } else {
            log.debug("method called \(path.joined(separator: "."))")
            return nil
        }
    }

    func setValue(
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
            guard case .jsMethodNotFound = error else { throw error }
            if variable.setter != nil {
                log.warn("not found setter \(setter.joined(separator: "."))")
            }
        }

        let parent = try findObject(path: path.dropLast(), createIfNeeded: true)

        parent.setObject(value, forKeyedSubscript: name as NSString)
        log.debug("set variable \(path.joined(separator: ".")) = \(value)")
        objectWillChange.send()
    }

    func execute(
        actions: [VC.Action],
        screenInstance: VS.ScreenInstance
    ) throws(VS.Error) {
        guard !actions.isEmpty else { return }

        for action in actions {
            guard !actionDispatcher.execute(action, in: context) else { continue }
            let object = VS.ActionParameters(screenInstance: screenInstance, params: action.params)
            _ = try invokeMethod(
                Bool.self,
                path: action.pathWithScreenContext(screenInstance.contextPath),
                args: [object])
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
