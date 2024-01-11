//
//  ValidateReceiptRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct ValidateReceiptRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile>

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/in-apps/apple/receipt/validate/"
    )
    let headers: Headers
    let profileId: String
    let receipt: Data
    let purchaseProductInfo: PurchaseProductInfo?

    init(profileId: String, receipt: Data, purchaseProductInfo: PurchaseProductInfo?) {
        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.receipt = receipt
        self.purchaseProductInfo = purchaseProductInfo
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case receipt = "receipt_encoded"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_inapps_apple_receipt_validation_result", forKey: .type)

        if let purchaseProductInfo = purchaseProductInfo {
            try dataObject.encode(purchaseProductInfo, forKey: .attributes)
        }
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(profileId, forKey: .profileId)
        try attributesObject.encode(receipt, forKey: .receipt)
    }
}

extension HTTPSession {
    func performValidateTransactionRequest(profileId: String,
                                           purchaseProductInfo: PurchaseProductInfo,
                                           withReceipt receipt: Data,
                                           _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        _performValidateReceiptRequest(profileId, receipt, purchaseProductInfo, completion)
    }

    func performValidateReceiptRequest(profileId: String,
                                       receipt: Data,
                                       _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        _performValidateReceiptRequest(profileId, receipt, nil, completion)
    }

    fileprivate func _performValidateReceiptRequest(_ profileId: String,
                                                    _ receipt: Data,
                                                    _ purchaseProductInfo: PurchaseProductInfo?,
                                                    _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        let request = ValidateReceiptRequest(profileId: profileId,
                                             receipt: receipt,
                                             purchaseProductInfo: purchaseProductInfo)
        let logParams: EventParameters? = purchaseProductInfo.map {
            [
                "product_id": .value($0.vendorProductId),
                "transaction_id": .valueOrNil($0.transactionId),
                "variation_id": .valueOrNil($0.productVariationId),
                "variation_id_persistent": .valueOrNil($0.persistentProductVariationId),
                "promotional_offer_id": .valueOrNil($0.promotionalOfferId),
            ]
        }

        perform(request, logName: "validate_receipt", logParams: logParams) { (result: ValidateReceiptRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
