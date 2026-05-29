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
