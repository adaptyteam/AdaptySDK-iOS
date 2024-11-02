//
//  ValidateTransactionRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.05.2023
//

import Foundation

private struct ValidateTransactionRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyProfile>

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/purchase/app-store/original-transaction-id/validate/"
    )

    let headers: HTTPHeaders
    let stamp = Log.stamp

    let profileId: String
    let requestSource: RequestSource

    init(profileId: String, requestSource: RequestSource) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
        self.profileId = profileId
        self.requestSource = requestSource
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case originalTransactionId = "original_transaction_id"
        case requestSource = "request_source"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_purchase_app_store_original_transaction_id_validation_result", forKey: .type)
        switch requestSource {
        case let .restore(originalTransactionId):
            var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            try attributesObject.encode(profileId, forKey: .profileId)
            try attributesObject.encode(Adapty.ValidatePurchaseReason.restoreRawString, forKey: .requestSource)
            try attributesObject.encode(originalTransactionId, forKey: .originalTransactionId)
        case let .other(purchasedTransaction, reason):
            try dataObject.encode(purchasedTransaction, forKey: .attributes)
            var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            try attributesObject.encode(profileId, forKey: .profileId)
            try attributesObject.encode(reason.rawString, forKey: .requestSource)
        }
    }

    enum RequestSource: Sendable {
        case restore(String)
        case other(PurchasedTransaction, reason: Adapty.ValidatePurchaseReason)
    }
}

private extension Adapty.ValidatePurchaseReason {
    static let restoreRawString = "restore"
    var rawString: String {
        switch self {
        case .setVariation: "set_variation"
        case .observing: "observing"
        case .purchasing: "purchasing"
        }
    }
}

extension Backend.MainExecutor {
    func syncTransaction(
        profileId: String,
        originalTransactionId: String
    ) async throws -> VH<AdaptyProfile> {
        let request = ValidateTransactionRequest(
            profileId: profileId,
            requestSource: .restore(originalTransactionId)
        )
        let logParams: EventParameters = [
            "original_transaction_id": originalTransactionId,
            "request_source": Adapty.ValidatePurchaseReason.restoreRawString,
        ]
        let response = try await perform(
            request,
            requestName: .validateTransaction,
            logParams: logParams
        )

        return VH(response.body.value, hash: response.headers.getBackendResponseHash())
    }

    func validateTransaction(
        profileId: String,
        purchasedTransaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws -> VH<AdaptyProfile> {
        let request = ValidateTransactionRequest(
            profileId: profileId,
            requestSource: .other(purchasedTransaction, reason: reason)
        )
        let logParams: EventParameters = [
            "product_id": purchasedTransaction.vendorProductId,
            "original_transaction_id": purchasedTransaction.originalTransactionId,
            "transaction_id": purchasedTransaction.transactionId,
            "variation_id": purchasedTransaction.productVariationId,
            "variation_id_persistent": purchasedTransaction.persistentProductVariationId,
            "promotional_offer_id": purchasedTransaction.subscriptionOffer?.id,
            "environment": purchasedTransaction.environment,
            "request_source": reason.rawString,
        ]
        let response = try await perform(
            request,
            requestName: .validateTransaction,
            logParams: logParams
        )

        return VH(response.body.value, hash: response.headers.getBackendResponseHash())
    }
}