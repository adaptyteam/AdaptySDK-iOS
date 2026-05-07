//
//  VS.SDKEvent.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.05.2026.
//

import JavaScriptCore

extension VS {
    enum SDKEvent: Sendable, VC.Value {
        case productLoaded
        case willPurchase(productId: String)
        case didPurchase(productId: String, result: PurchaseResult)
        case willRestorePurchases
        case didRestorePurchases(result: RestorePurchasesResult)
    }
}

extension VS.SDKEvent {
    enum Name: String, VC.Value {
        case productLoaded
        case willPurchase
        case didPurchase
        case willRestorePurchases
        case didRestorePurchases
    }

    var debugString: String {
        switch self {
        case .productLoaded:
            "{ event: \(Name.productLoaded.rawValue) }"
        case let .willPurchase(productId):
            "{ event: \(Name.willPurchase.rawValue), productId:\(productId) }"
        case let .didPurchase(productId, result):
            "{ event: \(Name.didPurchase.rawValue), productId:\(productId), result:\(result.rawValue)}"
        case .willRestorePurchases:
            "{ event: \(Name.willRestorePurchases.rawValue) }"
        case let .didRestorePurchases(result):
            "{ event: \(Name.didRestorePurchases.rawValue), result:\(result.rawValue) }"
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
        let object = JSValue(newObjectIn: context)!

        switch self {
        case .productLoaded:
            object.setObject(Name.productLoaded.toJSValue(in: context), forKeyedSubscript: "name" as NSString)
        case let .willPurchase(productId):
            object.setObject(Name.willPurchase.toJSValue(in: context), forKeyedSubscript: "name" as NSString)
            object.setObject(productId.toJSValue(in: context), forKeyedSubscript: "productId" as NSString)
        case let .didPurchase(productId, result):
            object.setObject(Name.didPurchase.toJSValue(in: context), forKeyedSubscript: "name" as NSString)
            object.setObject(productId.toJSValue(in: context), forKeyedSubscript: "productId" as NSString)
            object.setObject(result.toJSValue(in: context), forKeyedSubscript: "result" as NSString)
        case .willRestorePurchases:
            object.setObject(Name.willRestorePurchases.toJSValue(in: context), forKeyedSubscript: "name" as NSString)
        case let .didRestorePurchases(result):
            object.setObject(Name.didRestorePurchases.toJSValue(in: context), forKeyedSubscript: "name" as NSString)
            object.setObject(result.toJSValue(in: context), forKeyedSubscript: "result" as NSString)
        }
        return object
    }
}

