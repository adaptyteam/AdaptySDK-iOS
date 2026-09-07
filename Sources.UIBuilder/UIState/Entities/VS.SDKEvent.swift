//
//  VS.SDKEvent.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.05.2026.
//

import JavaScriptCore

extension VS {
    enum SDKEvent {
        case productsLoaded(id: String)
        case willPurchase(id: String, productId: String)
        case didPurchase(id: String, productId: String, result: PurchaseResult)
        case willRestorePurchases(id: String)
        case didRestorePurchases(id: String, result: RestorePurchasesResult)
        case appMessage(message: VS.AppMessage)
    }
}

extension VS.SDKEvent {
    enum Name: String {
        case productsLoaded
        case willPurchase
        case didPurchase
        case willRestorePurchases
        case didRestorePurchases
        case appMessage
    }

    var debugString: String {
        switch self {
        case let .productsLoaded(id):
            "{\(id) event: \(Name.productsLoaded.rawValue) }"
        case let .willPurchase(id, productId):
            "{\(id)  event: \(Name.willPurchase.rawValue), productId:\(productId) }"
        case let .didPurchase(id, productId, result):
            "{\(id)  event: \(Name.didPurchase.rawValue), productId:\(productId), result:\(result.rawValue)}"
        case let .willRestorePurchases(id):
            "{\(id)  event: \(Name.willRestorePurchases.rawValue) }"
        case let .didRestorePurchases(id, result):
            "{\(id)  event: \(Name.didRestorePurchases.rawValue), result:\(result.rawValue) }"
        case let .appMessage(message):
            "{\(message.id)  event: \(message.type.rawValue) \(message.debugString)}"
        }
    }
}

extension VS.SDKEvent.Name: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {
        rawValue.toJSValue(in: context)
    }
}

extension VS.SDKEvent: JSValueConvertable {
    func toJSValue(in context: JSContext) -> JSValue {

        switch self {
        case let .productsLoaded(id):
            let object = JSValue(newObjectIn: context)!
            object.setValue(id, forProperty: "id")
            object.setValue(Name.productsLoaded.rawValue, forProperty: "name")
            return object
        case let .willPurchase(id, productId):
            let object = JSValue(newObjectIn: context)!
            object.setValue(id, forProperty: "id")
            object.setValue(Name.willPurchase.rawValue, forProperty: "name")
            object.setValue(productId, forProperty: "productId")
            return object
        case let .didPurchase(id, productId, result):
            let object = JSValue(newObjectIn: context)!
            object.setValue(id, forProperty: "id")
            object.setValue(Name.didPurchase.rawValue, forProperty: "name")
            object.setValue(productId, forProperty: "productId")
            object.setValue(result.rawValue, forProperty: "result")
            return object
        case let .willRestorePurchases(id):
            let object = JSValue(newObjectIn: context)!
            object.setValue(id, forProperty: "id")
            object.setValue(Name.willRestorePurchases.rawValue, forProperty: "name")
            return object
        case let .didRestorePurchases(id, result):
            let object = JSValue(newObjectIn: context)!
            object.setValue(id, forProperty: "id")
            object.setValue(Name.didRestorePurchases.rawValue, forProperty: "name")
            object.setValue(result.rawValue, forProperty: "result")
            return object
        case let .appMessage(message):
            return message.toJSValue(in: context)
        }
    }
}

