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
            GetFlow.self,
            GetFlowForDefaultAudience.self,
            PreloadFlows.self,
            PreloadFlowsForDefaultAudience.self,
            GetOnboarding.self,
            GetOnboardingForDefaultAudience.self,
            PreloadOnboardings.self,
            PreloadOnboardingsForDefaultAudience.self,
            GetPaywallProducts.self,
            GetProfile.self,
            Identify.self,
            Logout.self,
            LogShowFlow.self,
            MakePurchase.self,
            MakePromotedPurchase.self,
            OpenWebPaywall.self,
            CreateWebPaywallUrl.self,
            PresentCodeRedemptionSheet.self,
            RestorePurchases.self,
            UpdateExternalAttributionData.self,
            SetIntegrationIdentifier.self,
            ReportTransaction.self,
            UpdateProfile.self,
            SetFallback.self,
            UpdateCollectingRefundDataConsent.self,
            UpdateRefundPreference.self,
            GetCurrentInstallationStatus.self,
            FlowViewDidAnswerPermission.self,
            ObserverPurchaseDidStart.self,
            ObserverPurchaseDidFinish.self,
            ObserverRestoreDidStart.self,
            ObserverRestoreDidFinish.self,
        ]

        #if os(iOS) || os(visionOS)
        if #available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *) {
            allRequests.append(contentsOf: [
                GetPendingStoreMessageTypes.self,
                ShowStoreMessage.self,
            ])
        }
        #endif

        #if canImport(UIKit)
        let adaptyUiRequests: [AdaptyPluginRequest.Type] = [
            AdaptyUICreateFlowView.self,
            AdaptyUIDismissFlowView.self,
            AdaptyUIPresentFlowView.self,

            AdaptyUICreateOnboardingView.self,
            AdaptyUIDismissOnboardingView.self,
            AdaptyUIPresentOnboardingView.self,

            AdaptyUIShowDialog.self,

            AdaptyUIOpenUrl.self,
            AdaptyUIRequestAppReview.self,
        ]
        allRequests.append(contentsOf: adaptyUiRequests)

        #endif

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
    static func register(requests: [AdaptyPluginRequest.Type]) {
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
        Request.allRequests.keys.map(\.self)
    }
}
