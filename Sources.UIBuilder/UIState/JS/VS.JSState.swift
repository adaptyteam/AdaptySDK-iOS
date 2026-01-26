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

            actionDispatcher = JSActionDispatcher(actionHandler)

            context.setObject(actionDispatcher, forKeyedSubscript: "SDK" as NSString)
        }
    }
}

extension VS.JSState {
    func evaluateScripts(_ scripts: [String]) {
        let script = scripts.filter { !$0.isEmpty }.joined(separator: "\n")
        context.evaluateScript(script)
        objectWillChange.send()
    }

    private func findObject(rootObject: JSValue?, path: [String]) throws(VS.Error) -> JSValue {
        guard let rootObject = rootObject ?? context.globalObject else {
            throw .jsGlobalObjectNotFound
        }

        var current = rootObject
        for component in path {
            guard let value = current.objectForKeyedSubscript(component), value.isObject
            else {
                throw .jsObjectNotFound(path.joined(separator: "."))
            }
            current = value
        }

        return current
    }

    func getValue<T: JSValueRepresentable>(_ type: T.Type, variable: VC.Variable, screenInstance: VC.ScreenInstance) throws(VS.Error) -> T? {
        let path = variable.pathWithScreenContext(screenInstance.contextPath)
        let name = path.last
        let parent = try findObject(rootObject: nil, path: path.dropLast())

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
        rootObject: JSValue?,
        path: [String],
        args functionArguments: [any JSValueConvertable] = []
    ) throws(VS.Error) -> T? {
        guard let name = path.last, path.count > 0 else { throw .jsPathToObjectIsEmpty }

        let parent = try findObject(rootObject: rootObject, path: path.dropLast())

        guard parent.hasProperty(name) else {
            throw .jsMethodNotFound(path.joined(separator: "."))
        }
        let value: JSValue? = parent.invokeMethod(
            name,
            withArguments: functionArguments.map { $0.toJSValue(in: context) }
        )

        if let value = T.fromJSValue(value) {
            log.debug("method called \(path.joined(separator: ".")) -> \(String(describing: value))")
            return value
        } else {
            log.debug("method called \(path.joined(separator: "."))")
            return nil
        }
    }

    func setValue(
        variable: VC.Variable,
        value: any JSValueConvertable,
        screenInstance: VC.ScreenInstance
    ) throws(VS.Error) {
        let path = variable.pathWithScreenContext(screenInstance.contextPath)
        guard let name = path.last, path.count > 0 else { throw .jsPathToObjectIsEmpty }

        let parent = try findObject(rootObject: nil, path: path.dropLast())

        do {
            var path = path
            path[path.count - 1] = "set" + name.capitalizedFirst
            _ = try invokeMethod(Bool.self, rootObject: nil, path: path, args: [value])
            objectWillChange.send()
            return
        } catch {
            guard case .jsMethodNotFound = error else { throw error }
        }

        parent.setObject(value, forKeyedSubscript: name as NSString)
        log.debug("set variable \(path.joined(separator: ".")) = \(value)")
        objectWillChange.send()
    }

    func execute(actions: [VC.Action], screenInstance: VC.ScreenInstance) throws(VS.Error) {
        guard !actions.isEmpty else { return }
        for action in actions {
            guard !actionDispatcher.execute(action, in: context) else { continue }
            _ = try invokeMethod(Bool.self, rootObject: nil, path: action.pathWithScreenContext(screenInstance.contextPath), args: [action.params])
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
