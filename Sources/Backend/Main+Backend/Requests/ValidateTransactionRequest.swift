//
//  ValidateTransactionRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.05.2023
//

import Foundation

private struct ValidateTransactionRequest: BackendEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/purchase/app-store/original-transaction-id/validate/"
    )

    let headers: HTTPHeaders
    let stamp = Log.stamp
    let requestName = BackendRequestName.validateTransaction
    let logParams: EventParameters?

    let userId: AdaptyUserId
    let requestSource: RequestSource

    init(
        userId: AdaptyUserId,
        requestSource: RequestSource,
        logParams: EventParameters
    ) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        self.userId = userId
        self.requestSource = requestSource
        self.logParams = logParams
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case originalTransactionId = "original_transaction_id"
        case transactionId = "transaction_id"
        case paywallVariationId = "variation_id"
        case requestSource = "request_source"

        case vendorProductId = "vendor_product_id"
        case persistentPaywallVariationId = "variation_id_persistent"
        case persistentOnboardingVariationId = "onboarding_variation_id"
        case originalPrice = "original_price"
        case discountPrice = "discount_price"
        case priceLocale = "price_locale"
        case storeCountry = "store_country"
        case promotionalOfferId = "promotional_offer_id"
        case subscriptionOffer = "offer"
        case environment
    }

    enum SubscriptionOfferKeys: String, CodingKey {
        case periodUnit = "period_unit"
        case periodNumberOfUnits = "number_of_units"
        case paymentMode = "type"
        case offerType = "category"
    }

    func encode(to encoder: Encoder) throws {
        var perentContainer = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataContainer = perentContainer.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataContainer.encode("adapty_purchase_app_store_original_transaction_id_validation_result", forKey: .type)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)

        switch requestSource {
        case let .restore(originalTransactionId):
            try container.encode(userId.profileId, forKey: .profileId)
            try container.encode(Adapty.ValidatePurchaseReason.restoreRawString, forKey: .requestSource)
            try container.encode(String(originalTransactionId), forKey: .originalTransactionId)
        case let .report(transactionId, variationId):
            try container.encode(userId.profileId, forKey: .profileId)
            try container.encode(Adapty.ValidatePurchaseReason.reportRawString, forKey: .requestSource)
            try container.encode(transactionId, forKey: .originalTransactionId)
            try container.encode(transactionId, forKey: .transactionId)
            try container.encodeIfPresent(variationId, forKey: .paywallVariationId)
        case let .other(info, payload, reason):
            try container.encode(userId.profileId, forKey: .profileId)
            try container.encode(reason.rawString, forKey: .requestSource)
            try container.encode(String(info.transactionId), forKey: .transactionId)
            try container.encode(String(info.originalTransactionId), forKey: .originalTransactionId)
            try container.encode(info.vendorProductId, forKey: .vendorProductId)
            try container.encodeIfPresent(info.price, forKey: .originalPrice)
            try container.encodeIfPresent(info.subscriptionOffer?.price, forKey: .discountPrice)
            try container.encodeIfPresent(info.priceLocale, forKey: .priceLocale)
            try container.encodeIfPresent(info.storeCountry, forKey: .storeCountry)
            try container.encodeIfPresent(info.subscriptionOffer?.id, forKey: .promotionalOfferId)
            if let offer = info.subscriptionOffer {
                var offerContainer = container.nestedContainer(keyedBy: SubscriptionOfferKeys.self, forKey: .subscriptionOffer)
                try offerContainer.encode(offer.paymentMode, forKey: .paymentMode)
                try offerContainer.encodeIfPresent(offer.period?.unit, forKey: .periodUnit)
                try offerContainer.encodeIfPresent(offer.period?.numberOfUnits, forKey: .periodNumberOfUnits)
                try offerContainer.encode(offer.offerType.rawValue, forKey: .offerType)
            }
            try container.encode(info.environment, forKey: .environment)

            try container.encodeIfPresent(payload.paywallVariationId, forKey: .paywallVariationId)
            try container.encodeIfPresent(payload.persistentPaywallVariationId, forKey: .persistentPaywallVariationId)
            try container.encodeIfPresent(payload.persistentOnboardingVariationId, forKey: .persistentOnboardingVariationId)
        }
    }

    enum RequestSource: Sendable {
        case restore(originalTransactionId: UInt64)
        case report(transactionId: String, variationId: String?)
        case other(PurchasedTransactionInfo, PurchasePayload, reason: Adapty.ValidatePurchaseReason)
    }
}

private typealias ResponseBody = Backend.Response.Data<AdaptyProfile>

private extension Adapty.ValidatePurchaseReason {
    static let restoreRawString = "restore"
    static let reportRawString = "report_transaction"

    var rawString: String {
        switch self {
        case .setVariation: "set_variation"
        case .observing: "observing"
        case .purchasing: "purchasing"
        case .unfinished: "unfinished"
        }
    }
}

extension Backend.MainExecutor {
    func syncTransactionsHistory(
        originalTransactionId: UInt64,
        for userId: AdaptyUserId
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = ValidateTransactionRequest(
            userId: userId,
            requestSource: .restore(originalTransactionId: originalTransactionId),
            logParams: [
                "original_transaction_id": originalTransactionId,
                "request_source": Adapty.ValidatePurchaseReason.restoreRawString,
            ]
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>.decoder)
        return response.body
    }

    func sendTransactionId(
        _ transactionId: String,
        with variationId: String?,
        for userId: AdaptyUserId
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = ValidateTransactionRequest(
            userId: userId,
            requestSource: .report(transactionId: transactionId, variationId: variationId),
            logParams: [
                "transaction_id": transactionId,
                "variation_id": variationId,
                "request_source": Adapty.ValidatePurchaseReason.reportRawString,
            ]
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>.decoder)
        return response.body
    }

    func validateTransaction(
        transactionInfo: PurchasedTransactionInfo,
        payload: PurchasePayload,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = ValidateTransactionRequest(
            userId: payload.userId,
            requestSource: .other(transactionInfo, payload, reason: reason),
            logParams: [
                "product_id": transactionInfo.vendorProductId,
                "original_transaction_id": transactionInfo.originalTransactionId,
                "transaction_id": transactionInfo.transactionId,
                "variation_id": payload.paywallVariationId,
                "variation_id_persistent": payload.persistentPaywallVariationId,
                "onboarding_variation_id": payload.persistentOnboardingVariationId,
                "promotional_offer_id": transactionInfo.subscriptionOffer?.id,
                "environment": transactionInfo.environment,
                "request_source": reason.rawString,
            ]
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>.decoder)
        return response.body
    }
}
