//
//  VS.ShowRequestPermissionParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation
import JavaScriptCore

package extension VS {
    struct ShowRequestPermissionParameters {
        let permission: String?
        let customArgs: [String: String]?
    }

    struct ShowRequestPermissionParametersResponse {
        let request: ShowRequestPermissionParameters
        let result: Bool
        let detailResult: String?
    }
}

extension VS.ShowRequestPermissionParametersResponse: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        let object = JSValue(newObjectIn: context)!
        object.setObject(request.permission.toJSValue(in: context), forKeyedSubscript: "permission" as NSString)
        if let customArgs: [String: String] = request.customArgs {
            object.setObject(customArgs.toJSValue(in: context), forKeyedSubscript: "customArgs" as NSString)
        }
        object.setObject(result.toJSValue(in: context), forKeyedSubscript: "result" as NSString)
        object.setObject(detailResult.toJSValue(in: context), forKeyedSubscript: "detailResult" as NSString)
        return object
    }
}

extension VS.ShowRequestPermissionParameters {
    static func fromDictionary(_ dict: [AnyHashable: Any]) -> Self {
        let permission = dict["permission"] as? String

        let customArgs: [String: String]? =
            if let raw = dict["customArgs"] as? [String: Any] {
                raw.compactMapValues{ $0 as? String}
            } else {
                nil
            }

        return .init(
            permission: permission,
            customArgs: customArgs
        )
    }
}

