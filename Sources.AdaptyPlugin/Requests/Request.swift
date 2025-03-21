//
//  Request.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Foundation

enum Request {
    @MainActor
    fileprivate static var allRequests: [String: AdaptyPluginRequest.Type] = {
        var allRequests: [AdaptyPluginRequest.Type] = [
            GetSDKVersion.self,
            IsActivated.self,
            GetLogLevel.self,
            SetLogLevel.self,
            Activate.self,
            GetPaywall.self,
            GetPaywallForDefaultAudience.self,
            GetPaywallProducts.self,
            GetProfile.self,
            Identify.self,
            Logout.self,
            LogShowOnboarding.self,
            LogShowPaywall.self,
            MakePurchase.self,
            PresentCodeRedemptionSheet.self,
            RestorePurchases.self,
            UpdateAttributionData.self,
            SetIntegrationIdentifier.self,
            ReportTransaction.self,
            UpdateProfile.self,
            SetFallbackPaywalls.self,
            UpdateCollectingRefundDataConsent.self,
            UpdateRefundPreference.self
        ]

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            let adaptyUiRequests: [AdaptyPluginRequest.Type] = [
                AdaptyUICreateView.self,
                AdaptyUIDismissView.self,
                AdaptyUIPresentView.self,
                AdaptyUIShowDialog.self
            ]
            allRequests.append(contentsOf: adaptyUiRequests)
        }

        return Dictionary(allRequests.map { ($0.method, $0) }) { _, last in last }
    }()

    @MainActor
    static func requestType(for method: String) throws -> AdaptyPluginRequest.Type {
        guard let requestType = allRequests[method] else {
            throw AdaptyPluginInternalError.unknownRequest(method)
        }
        return requestType
    }
}

enum Response {}

public extension AdaptyPlugin {
    @MainActor
    static func reqister(requests: [AdaptyPluginRequest.Type]) {
        for request in requests {
            Request.allRequests[request.method] = request
        }
    }

    @MainActor
    static func remove(requests: [String]) {
        for method in requests {
            Request.allRequests.removeValue(forKey: method)
        }
    }

    @MainActor
    static var allRequests: [String] {
        Request.allRequests.keys.map { $0 }
    }
}
