//
//  AdaptyUIActionHandler.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation

protocol AdaptyUIActionHandler: AnyObject {
    func jsException(_: String)
    func openUrl(url: URL, openIn: VC.Action.WebOpenInParameter)
    func openUrl(stringId: String, openIn: VC.Action.WebOpenInParameter)
    func userCustomAction(id: String)
    func purchaseProduct(productId: String, service: VC.Action.PaymentService, callback: VS.JSAction?)
    func restorePurchases(callback: VS.JSAction?)
    func closeAll()
    func selectProduct(productId: String)

    func openScreen(instance: VS.ScreenInstance, transitionId: String)
    func closeScreen(navigatorId: String, transitionId: String)

    func changeFocus(id: String?)
    func setTimer(id: String, endAt: Date, callback: VS.JSAction?)
    func setTimer(id: String, duration: TimeInterval, behavior: VS.SetTimerBehavior, callback: VS.JSAction?)
    func moveScroll(instanceId: String, kind: VS.ScrollKind, value: VS.ScrollValue)

    func sendAnalyticsEvent(_: VS.AnalyticEvent)
    func sendEvents(instanceId: String?, eventIds: [String])
    func showAppRate()
    func showAlertDialog(params: VS.ShowAlertDialogParameters, callback: VS.JSAction?)
    func showRequestPermission(params: VS.ShowRequestPermissionParameters, callback: VS.JSAction?)
}

extension VS {
    enum SetTimerBehavior: String, Sendable {
        case restart
        case `continue`
        case persisted
        case custom
    }
}

extension VS {
    enum ScrollKind: String, Sendable {
        case content
        case footer
    }

    enum ScrollValue: String, Sendable {
        case start
        case end
    }
}

package extension VS {
    struct AnalyticEvent: Sendable {
        package enum CodingKeys: String, CodingKey {
            case name = "event_type"
            case screenInstanceId = "screen_id"
        }

        package let name: String
        package let params: [String: any Sendable]

        package init(name: String, params: [String: any Sendable]) {
            self.name = name
            self.params = Self.normalizingJSValues(params)
        }

        /// JavaScriptCore bridges JS values to ObjC types (`__NSCFString`, `__NSCFNumber`,
        /// `__NSCFBoolean`), none of which conform to `Encodable`. Encoding such params straight
        /// into the analytics payload fails with `Unsupported non encodable value type`. Convert
        /// them to native Swift values up front — keeping booleans as booleans rather than
        /// collapsing them to 0/1.
        static func normalizingJSValues(_ params: [String: any Sendable]) -> [String: any Sendable] {
            params.compactMapValues(normalizingJSValue)
        }

        /// Returns `nil` to drop the value (JS `null` arrives as `NSNull`, which is not encodable).
        private static func normalizingJSValue(_ value: any Sendable) -> (any Sendable)? {
            switch value {
            case is NSNull:
                return nil
            case let number as NSNumber:
                if CFGetTypeID(number) == CFBooleanGetTypeID() {
                    return number.boolValue
                }
                if let int = Int(exactly: number.doubleValue) {
                    return int
                }
                return number.doubleValue
            case let string as NSString:
                return string as String
            case let dictionary as [String: any Sendable]:
                return normalizingJSValues(dictionary)
            case let array as [any Sendable]:
                return array.compactMap(normalizingJSValue)
            default:
                return value
            }
        }

        package var screenInstanceId: String? {
            (params[CodingKeys.screenInstanceId.rawValue] ?? params["instanceId"]) as? String
        }

        package var isBackend: Bool {
            params["isBackendEvent"] as? Bool ?? true
        }

        package var isCustomer: Bool {
            params["isCustomerEvent"] as? Bool ?? false
        }
    }
}
